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
	
	assert tag == elf64.dt_needed


	shs := ls.get_shstrtab()

	libname := ls.get_shstrtab_offset(int(dynamics[0].d_val))
	println(libname)

	assert libname.contains('.so')

	syms := ls.get_symbols()

	for i, sym in syms {
		println('$i) value: $sym.st_value.hex()')
	}

	// save modifications in structures
	ls.save() // save elf header
	ls.save_programs(p)
	ls.save_sections(s)
	ls.save_dynamics(dynamics)
	ls.save_shstrtab(shs)
	ls.save_symbols(syms)
}
