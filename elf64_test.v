import elf64 
import os

fn test_elf64() {
	println("loading an elf")

	os.cp('/bin/ls','/tmp/ls') or { assert 1==2 }

	mut ls := elf64.load('/tmp/ls')

	assert ls.e_ident[1] == `E`
	assert ls.e_ident[2] == `L`
	assert ls.e_ident[3] == `F`

	println('ident: $ls.e_ident')
	println('type: $ls.e_type')
	println('machine: $ls.e_machine')
	println('version: $ls.e_version')
	println('entry: 0x$ls.e_entry.hex()')
	println('phoff: 0x$ls.e_phoff.hex()')
	println('shoff: 0x$ls.e_shoff.hex()')
	println('flags: $ls.e_flags')
	println('ehsize: $ls.e_ehsize')
	println('phentsize: $ls.e_phentsize')
	println('phnum: $ls.e_phnum')
	println('shentsize: $ls.e_shentsize')
	println('shnum: $ls.e_shnum')
	println('shstrndx: $ls.e_shstrndx')

	println('\nPrograms:')
	p := ls.get_programs()
	for i, prog in p {
		println('$i) p_type: $prog.p_type')
	} 

	println('\nSections:')
	s := ls.get_sections()
	for i, sect in s {
		println('$i) sh_name: $sect.sh_name ')
	}

	dynamics := ls.get_dynamic()

	tag := dynamics[0].d_tag
	first_lib_off := dynamics[0].d_val
	println('first library to be loaded is in offset: $first_lib_off and tag: $tag')

	assert tag == elf64.dt_needed


	shs := ls.get_shstrtab()


	mut libname := []byte{}
	for i in dynamics[0].d_val..shs.len {
		if shs[i] == 0 { break }
		libname << shs[i]
	}

	slibname := string(libname)
	println(slibname)

	assert slibname.contains('.so')

	// modifications
	//ls.e_ident[1] = `J`
	ls.save()

	assert 1==1
}

