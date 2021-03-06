/* This C header file is generated by NIT to compile modules and programs that requires ../lib/standard/symbol. */
#ifndef standard___symbol_sep
#define standard___symbol_sep
#include "standard___string._sep.h"
#include <nit_common.h>

extern const classtable_elt_t VFT_standard___symbol___Symbol[];
extern const char *LOCATE_standard___symbol;
extern const int SFT_standard___symbol[];
#define CALL_standard___symbol___String___to_symbol(recv) ((standard___symbol___String___to_symbol_t)CALL((recv), (SFT_standard___symbol[0] + 0)))
#define ID_standard___symbol___Symbol (SFT_standard___symbol[1])
#define COLOR_standard___symbol___Symbol (SFT_standard___symbol[2])
#define ATTR_standard___symbol___Symbol____string(recv) ATTR(recv, (SFT_standard___symbol[3] + 0))
#define INIT_TABLE_POS_standard___symbol___Symbol (SFT_standard___symbol[4] + 0)
#define CALL_standard___symbol___Symbol___init(recv) ((standard___symbol___Symbol___init_t)CALL((recv), (SFT_standard___symbol[4] + 1)))
static const char * const LOCATE_standard___symbol___String___to_symbol = "symbol::String::to_symbol";
val_t standard___symbol___String___to_symbol(val_t p0);
typedef val_t (*standard___symbol___String___to_symbol_t)(val_t p0);
val_t NEW_String_standard___string___String___from_cstring(val_t p0);
val_t NEW_String_standard___string___String___with_native(val_t p0, val_t p1);
static const char * const LOCATE_standard___symbol___Symbol___to_s = "symbol::Symbol::(string::Object::to_s)";
val_t standard___symbol___Symbol___to_s(val_t p0);
typedef val_t (*standard___symbol___Symbol___to_s_t)(val_t p0);
static const char * const LOCATE_standard___symbol___Symbol___init = "symbol::Symbol::init";
void standard___symbol___Symbol___init(val_t p0, val_t p1, int* init_table);
typedef void (*standard___symbol___Symbol___init_t)(val_t p0, val_t p1, int* init_table);
val_t NEW_Symbol_standard___symbol___Symbol___init(val_t p0);
#endif
