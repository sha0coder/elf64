/*
	This code extract the linked libs from the dynamic section.
	like: readelf --dynamic /bin/ls | grep NEEDED


	~/s/e/examples ❯❯❯ ./linked_libs /bin/bash
	0) libtinfo.so.6
	1) libdl.so.2
	2) libc.so.6

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
dyns := e64.get_dynamic()

for i, dyn in dyns {
	if dyn.d_tag == elf64.dt_needed {
		libname := e64.get_shstrtab_offset(int(dyn.d_val))
		println('$i) $libname')
	}
}
