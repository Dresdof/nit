#ifndef __STRING_NIT_H
#define __STRING_NIT_H
/* This file is part of NIT ( http://www.nitlanguage.org ).
 *
 * Copyright 2004-2008 Jean Privat <jean@pryen.org>
 *
 * This file is free software, which comes along with NIT.  This software is
 * distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without  even  the implied warranty of  MERCHANTABILITY or  FITNESS FOR A 
 * PARTICULAR PURPOSE.  You can modify it is you want,  provided this header
 * is kept unaltered, and a notification of the changes is added.
 * You  are  allowed  to  redistribute it and sell it, alone or is a part of
 * another product.
 */

#include <string._nitni.h>

#define kernel_Sys_Sys_native_argc_0(self) (glob_argc)
#define kernel_Sys_Sys_native_argv_1(self, p0) (glob_argv[(p0)])
float String_to_f___impl( String recv );

#endif
