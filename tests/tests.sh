#!/bin/bash
# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2004-2008 Jean Privat <jean@pryen.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This shell script compile, run and verify Nit program files

# Set lang do default to avoid failed tests because of locale
export LANG=C

usage()
{
	e=`basename "$0"`
	cat<<END
Usage: $e [options] modulenames
-o option   Pass option to nitc
-v          Verbose (show tests steps)
-h          This help
END
}

# As argument: the pattern used for the file
function process_result()
{
	# Result
	pattern=$1
	SAV=""
	FAIL=""
	SOSO=""
	if [ -r "sav/$pattern.sav" ]; then
		diff -u "out/$pattern.res" "sav/$pattern.sav" > "out/$pattern.diff.sav.log"
		if [ "$?" == 0 ]; then
			SAV=OK
		else
			SAV=NOK
		fi
		sed '/[Ww]arning/d;/[Ee]rror/d' "out/$pattern.res" > "out/$pattern.res2"
		sed '/[Ww]arning/d;/[Ee]rror/d' "sav/$pattern.sav" > "out/$pattern.sav2"
		grep '[Ee]rror' "out/$pattern.res" >/dev/null && echo "Error" >> "out/$pattern.res2"
		grep '[Ee]rror' "sav/$pattern.sav" >/dev/null && echo "Error" >> "out/$pattern.sav2"
		diff -u "out/$pattern.res2" "out/$pattern.sav2" > "out/$pattern.diff.sav2.log"
		if [ "$?" == 0 ]; then
			SOSO=OK
		else
			SOSO=NOK
		fi
	fi
	if [ -r "sav/$pattern.fail" ]; then
		diff -u "out/$pattern.res" "sav/$pattern.fail" > "out/$pattern.diff.fail.log"
		if [ "$?" == 0 ]; then
			FAIL=OK
		else
			FAIL=NOK
		fi
	fi
	if [ "x$SAV" = "xOK" ]; then
		if [ "x$FAIL" = "x" ]; then
			echo "[ok] out/$pattern.res"
		else
			echo "[ok] out/$pattern.res - but sav/$pattern.fail remains!"
		fi
		ok="$ok $pattern"
	elif [ "x$FAIL" = "xOK" ]; then
		echo "[fail] out/$pattern.res"
		ok="$ok $pattern"
	elif [ "x$SOSO" = "xOK" ]; then
		echo "[soso] out/$pattern.res sav/$pattern.sav"
		ok="$ok $pattern"
	elif [ "x$SAV" = "xNOK" ]; then
		echo "[======= fail out/$pattern.res sav/$pattern.sav =======]"
		nok="$nok $pattern"
		echo "$ii" >> "$ERRLIST"
	elif [ "x$FAIL" = "xNOK" ]; then
		echo "[======= changed out/$pattern.res sav/$pattern.fail ======]"
		nok="$nok $pattern"
		echo "$ii" >> "$ERRLIST"
	else
		echo "[=== no sav ===] out/$pattern.res"
		nos="$nos $pattern"
	fi
}

find_nitc()
{
	recent=`ls -t ../src/nitc ../src/nitc_[0-9] ../bin/nitc ../c_src/nitc 2>/dev/null | head -1`
	if [[ "x$recent" == "x" ]]; then
		echo 'Could not find nitc, aborting'
		exit 1
	fi
	echo 'Using nitc from: '$recent
	NITC=$recent
}

make_alts0()
{
	ii="$1"
	xalt="$2"
	fs=""
	for alt in `sed -n "s/.*#!*\($xalt[0-9]*\)#.*/\1/p" "$ii" | sort -u`; do
		f=`basename "$ii" .nit`
		d=`dirname "$ii"`
		ff="$f"
		i="$ii"

		if [ "x$alt" != "x" ]; then
			test -d alt || mkdir -p alt
			i="alt/${f}_$alt.nit"
			ff="${ff}_$alt"
			sed "s/#$alt#//g;/#!$alt#/d" "$ii" > "$i"
		fi
		ff="$ff$MARK"
		fs="$fs $i"
	done
	echo "$fs"
}
make_alts()
{
	ii="$1"
	fs="$1"
	for xalt in `sed -n 's/.*#!*\([0-9]*alt\)[0-9]*#.*/\1/p' "$ii" | sort -u`; do
		fs2=""
		for f in $fs; do
			fs2="$fs2 `make_alts0 $f $xalt`"
		done
		fs="$fs $fs2"
	done
	echo "$fs"
}

# The default nitc compiler
[ -z "$NITC" ] && find_nitc

# Set NIT_DIR if needed
[ -z "$NIT_DIR" ] && export NIT_DIR=..

verbose=false
stop=false
while [ $stop = false ]; do
	case $1 in
		-o) OPT="$OPT $2"; shift; shift;;
		-v) verbose=true; shift;;
		-h) usage; exit;;
		*) stop=true
	esac
done

# Mark to distinguish files among tests
# MARK=

# File where error tests are outputed
# Old ERRLIST is backuped
ERRLIST=${ERRLIST:-errlist}
ERRLIST_TARGET=$ERRLIST

if [ $# = 0 ]; then
	usage;
	exit
fi

# Initiate new ERRLIST
if [ "x$ERRLIST" = "x" ]; then
	ERRLIST=/dev=null
else
	ERRLIST=$ERRLIST.tmp
	> "$ERRLIST"
fi

ok=""
nok=""

# CLEAN the out directory
rm -rf out/ 2>/dev/null
mkdir out 2>/dev/null

for ii in "$@"; do
	if [ ! -f $ii ]; then
		echo "File '$ii' does not exist."
		continue
	fi

	tmp=${ii/../AA}
	if [ "x$tmp" = "x$ii" ]; then
		includes="-I . -I ../lib/standard -I ../lib/standard/collection -I alt"
	else
		includes="-I alt"
	fi

	f=`basename "$ii" .nit`
	for i in `make_alts $ii`; do
		bf=`basename $i .nit`
		ff="out/$bf"
		echo -n "=> $bf: "

		if [ -f "$f.inputs" ]; then
			inputs="$f.inputs"
		else
			inputs=/dev/null
		fi

		# Compile
		if [ "x$verbose" = "xtrue" ]; then
			echo ""
			echo $NITC --no-color $OPT -o "$ff.bin" "$i" "$includes"
		fi
		$NITC --no-color $OPT -o "$ff.bin" "$i" $includes <"$inputs" 2> "$ff.cmp.err" > "$ff.compile.log"
		ERR=$?
		if [ "x$verbose" = "xtrue" ]; then
			cat "$ff.compile.log"
			cat >&2 "$ff.cmp.err"
		fi
		egrep '^[A-Z0-9_]*$' "$ff.compile.log" > "$ff.res"
		if [ "$ERR" != 0 ]; then
			echo -n "! "
			cat "$ff.cmp.err" "$ff.compile.log" > "$ff.res"
			process_result $bf
		elif [ -x "./$ff.bin" ]; then
			cp "$ff.cmp.err" "$ff.res"
			echo -n ". "
			# Execute
			args=""
			if [ "x$verbose" = "xtrue" ]; then
				echo ""
				echo "NIT_NO_STACK=1 ./$ff.bin" $args
			fi
			NIT_NO_STACK=1 "./$ff.bin" $args < "$inputs" >> "$ff.res" 2>"$ff.err"
			if [ "x$verbose" = "xtrue" ]; then
				cat "$ff.res"
				cat >&2 "$ff.err"
			fi
			if [ -f "$ff.write" ]; then
				cat "$ff.write" >> "$ff.res"
			elif [ -d "$ff.write" ]; then
				LANG=C /bin/ls -F $ff.write >> "$ff.res"
			fi
			if [ -s "$ff.err" ]; then
				cat "$ff.err" >> "$ff.res"
			fi
			process_result $bf

			if [ -f "$f.args" ]; then
				fargs=$f.args
				cptr=0
				while read line; do
					((cptr=cptr+1))
					args="$line"
					bff=$bf"_args"$cptr
					fff=$ff"_args"$cptr
					rm -rf "$fff.res" "$fff.err" "$fff.write" 2> /dev/null
					if [ "x$verbose" = "xtrue" ]; then
						echo ""
						echo "NIT_NO_STACK=1 ./$ff.bin" $args
					fi
					echo -n "==> args #"$cptr " "
					sh -c "NIT_NO_STACK=1 ./$ff.bin  ''$args < $inputs > $fff.res 2>$fff.err"
					if [ "x$verbose" = "xtrue" ]; then
						cat "$fff.res"
						cat >&2 "$fff.err"
					fi
					if [ -f "$fff.write" ]; then
						cat "$fff.write" >> "$fff.res"
					elif [ -d "$fff.write" ]; then
						LANG=C /bin/ls -F $fff.write >> "$fff.res"
					fi
					if [ -s "$fff.err" ]; then
						cat "$fff.err" >> "$fff.res"
					fi
					process_result $bff
				done < $fargs
			fi
		else
			echo -n "! "
			cat "$ff.cmp.err" "$ff.compile.log" > "$ff.res"
			#echo "Compilation error" > "$ff.res"
			process_result $bf
		fi
	done
done

echo "ok: " `echo $ok | wc -w` "/" `echo $ok $nok $nos | wc -w`

if [ -n "$nok" ]; then
	echo "fail: $nok"
	echo "There were $(echo $nok | wc -w) errors ! (see file $ERRLIST)"
fi
if [ -n "$nos" ]; then
	echo "no sav: $nos"
fi

# write $ERRLIST
if [ "x$ERRLIST" != "x" ]; then
	if [ -x "$ERRLIST_TARGET" ]; then
		mv "$ERRLIST_TARGET" "${ERRLIST_TARGET}.bak"
	fi
	mv $ERRLIST $ERRLIST_TARGET
fi

if [ -n "$nok" ]; then
	exit 1
else
	exit 0
fi
