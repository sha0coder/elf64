/*
	This code extract the symbols from the dynsym section.
	like: readelf --dyn-syms /bin/ls

	~/s/e/examples ❯❯❯ ./symbols /bin/ls
	0) 
	1) __ctype_toupper_loc
	2) getenv
	3) sigprocmask
	4) __snprintf_chk
	5) raise
	6) abort
	7) __errno_location
	8) strncmp
	9) _ITM_deregisterTMCloneTable
	10) localtime_r
	11) _exit
	12) strcpy
	13) __fpending
	14) isatty
	15) sigaction
	...
	136) malloc
	137) stdout
	138) program_name


*/


import sha0coder_v.elf64
import os 

if os.args.len < 2 {
	arg0 := os.args[0]
	println('example: $arg0 /bin/ls')
	exit(1)
}

filename := os.args[1]

e64 := elf64.load(filename)
syms := e64.get_symbols()

for i, sym in syms {
	sym_name := e64.get_shstrtab_offset(int(sym.st_name))
	println('$i) $sym_name')
}
