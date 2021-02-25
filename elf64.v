module elf64

import os
import encoding.binary

pub const (
	ei_nident = 16
	elf64_hdr_sz = 64
	elf64_phdr_sz = 48
	elf64_shdr_sz = 64
	elf64_dyn_sz = 16

	// Elf64_Dyn dt_tag constants
	dt_null = 0 				/* Marks end of dynamic section */
	dt_needed = 1				/* Name of needed library */
	dt_pltrelsz = 2				/* Size in bytes of PLT relocs */
	dt_pltgot = 3				/* Processor defined value */
	dt_hash = 4					/* Address of symbol hash table */
	dt_strtab = 5				/* Address of string table */
	dt_symtab = 6				/* Address of symbol table */
	dt_rela = 7					/* Address of Rela relocs */
	dt_relasz = 8				/* Total size of Rela relocs */
	dt_relaent = 9				/* Size of one Rela reloc */
	dt_strsz = 10				/* Size of string table */
	dt_syment = 11				/* Size of one symbol table entry */
	dt_init = 12				/* Address of init function */
	dt_fini = 13				/* Address of termination function */
	dt_soname = 14 				/* Name of shared object */
	dt_rpath = 15				/* Library search path (deprecated) */
	dt_symbolic = 16			/* Start symbol search here */
	dt_rel = 17					/* Address of Rel relocs */
	dt_relsz = 18				/* Total size of Rel relocs */
	dt_relent = 19				/* Size of one Rel reloc */
	dt_pltrel = 20				/* Type of reloc in PLT */
	dt_debug = 21				/* For debugging; unspecified */
	dt_textrel = 22				/* Reloc might modify .text */
	dt_jmprel = 23				/* Address of PLT relocs */
	dt_bind_now = 24			/* Process relocations of object */
	dt_init_array = 25			/* Array with addresses of init fct */
	dt_fini_array = 26			/* Array with addresses of fini fct */
	dt_init_arraysz = 27		/* Size in bytes of DT_INIT_ARRAY */
	dt_fini_arraysz = 28		/* Size in bytes of DT_FINI_ARRAY */
	dt_runpath = 29				/* Library search path */
	dt_flags = 30				/* Flags for the object being loaded */
)

pub struct Elf64_hdr {
pub mut:
	filename string
	e_ident []byte
	e_type u16
	e_machine u16
	e_version u32
	e_entry u64
	e_phoff u64
	e_shoff u64
	e_flags u32
	e_ehsize u16
	e_phentsize u16
	e_phnum u16
	e_shentsize u16
	e_shnum u16 
	e_shstrndx u16
}

pub struct Elf64_Phdr {
pub mut:
	p_type u32
	p_flags u32 
	p_offset u64
	p_vaddr u64
	p_paddr u64
	p_filesz u64 
	p_memsz u64 
}

pub struct Elf64_Shdr {
pub mut:
	sh_name u32
	sh_type u32
	sh_flags u64
	sh_addr u64
	sh_offset u64 
	sh_size u64 
	sh_link u32 
	sh_info u32 
	sh_addralign u64 
	sh_entsize u64
}

pub struct Elf64_Sym {
pub mut:
	st_name u32 
	st_info byte 
	st_other byte 
	st_shndx u16
	st_value u64 
	st_size u64
}

pub struct Elf64_Rel {
pub mut:
	r_offset u64 
	r_info u64
}

pub struct Elf64_Rela {
pub mut:
	r_offset u64
	r_info u64
	r_addend u64
}

pub struct Elf64_Dyn {
pub mut:
	d_tag u64
	d_val u64
}


  
pub fn load(filename string) Elf64_hdr {
	mut e64 := Elf64_hdr{}
	e64.filename = filename

	mut f := os.open(filename) or { panic("filename not valid") }
	buff := f.read_bytes(elf64_hdr_sz)
	f.close()

	e64.e_ident = buff[0..16]
	e64.e_type = binary.little_endian_u16(buff[16..18])
	e64.e_machine = binary.little_endian_u16(buff[18..20])
	e64.e_version = binary.little_endian_u32(buff[20..24])
	e64.e_entry = binary.little_endian_u64(buff[24..32])
	e64.e_phoff = binary.little_endian_u64(buff[32..40])
	e64.e_shoff = binary.little_endian_u64(buff[40..48])
	e64.e_flags = binary.little_endian_u32(buff[48..52])
	e64.e_ehsize = binary.little_endian_u16(buff[52..54])
	e64.e_phentsize = binary.little_endian_u16(buff[54..56])
	e64.e_phnum = binary.little_endian_u16(buff[56..58])
	e64.e_shentsize = binary.little_endian_u16(buff[58..60])
	e64.e_shnum = binary.little_endian_u16(buff[60..62])
	e64.e_shstrndx = binary.little_endian_u16(buff[62..64])

	return e64
}

pub fn (mut e64 Elf64_hdr) set_filename(filename string) {
	e64.filename = filename 
}

pub fn (e64 Elf64_hdr) get_programs() []Elf64_Phdr {
	mut phdrs := []Elf64_Phdr{}
	mut f := os.open(e64.filename) or { panic("filename not valid") }
	mut off := e64.e_phoff

	for _ in 0..e64.e_phnum {
		buff := f.read_bytes_at(elf64_phdr_sz, int(off))

		mut p := Elf64_Phdr{}
		p.p_type = binary.little_endian_u32(buff[0..4])
		p.p_flags = binary.little_endian_u32(buff[4..8])
		p.p_offset = binary.little_endian_u64(buff[8..16])
		p.p_vaddr = binary.little_endian_u64(buff[16..24]) 
		p.p_paddr = binary.little_endian_u64(buff[24..32]) 
		p.p_filesz = binary.little_endian_u64(buff[32..40]) 
		p.p_memsz = binary.little_endian_u64(buff[40..48])

		phdrs << p
		off += elf64_phdr_sz
	}

	f.close()
	return phdrs
}

pub fn (e64 Elf64_hdr) get_sections() []Elf64_Shdr {
	mut shdrs := []Elf64_Shdr{}
	mut f := os.open(e64.filename) or { panic("filename not valid") }
	mut off := e64.e_shoff

	for _ in 0..e64.e_shnum {
		buff := f.read_bytes_at(elf64_shdr_sz, int(off))

		mut s := Elf64_Shdr{}
		s.sh_name = binary.little_endian_u32(buff[0..4])
		s.sh_type = binary.little_endian_u32(buff[4..8])
		s.sh_flags = binary.little_endian_u64(buff[8..16])  
		s.sh_addr = binary.little_endian_u64(buff[16..24]) 
		s.sh_offset = binary.little_endian_u64(buff[24..32]) 
		s.sh_size = binary.little_endian_u64(buff[32..40]) 
		s.sh_link = binary.little_endian_u32(buff[40..44]) 
		s.sh_info = binary.little_endian_u32(buff[44..48]) 
		s.sh_addralign = binary.little_endian_u64(buff[48..56]) 
		s.sh_entsize = binary.little_endian_u64(buff[56..64])

		shdrs << s
		off += elf64_shdr_sz
	}

	f.close()
	return shdrs
}

pub fn (e64 Elf64_hdr) get_dyn_section() ?Elf64_Shdr {
	sections := e64.get_sections()

	for section in sections {
		if section.sh_type == 6 {
			return section
		}
	}
	return error('Dyn section not found!')
}

pub fn (e64 Elf64_hdr) get_shstrtab_section() ?Elf64_Shdr {
	sections := e64.get_sections()

	for section in sections {
		if section.sh_type == 3 {
			return section
		}
	}
	return error('Shstrtab section not found!')
}

pub fn (e64 Elf64_hdr) get_dynamic() []Elf64_Dyn {
	mut dyns := []Elf64_Dyn{}
	dyn_section := e64.get_dyn_section() or { panic("Not Dyn section") }
	mut f := os.open(e64.filename) or { panic("filename not valid") }
	mut off := dyn_section.sh_offset

	for {
		mut dyn := Elf64_Dyn{}
		buff := f.read_bytes_at(int(dyn_section.sh_entsize), int(off))
		dyn.d_tag = binary.little_endian_u64(buff[0..8])
		dyn.d_val = binary.little_endian_u64(buff[8..16])

		dyns << dyn

		if dyn.d_tag == dt_null { break }
		
		off += dyn_section.sh_entsize
	}

	f.close()
	return dyns
}

pub fn (e64 Elf64_hdr) get_shstrtab() []byte {
	shstrtab_section := e64.get_shstrtab_section() or { panic('no shstrtab section') }
	mut f := os.open(e64.filename) or { panic('filename not valid') }
	shs := f.read_bytes_at(int(shstrtab_section.sh_size), int(shstrtab_section.sh_offset))
	f.close()
	return shs
}

struct RawElf {
mut:
	sz int
	buff []byte
}

fn (mut r RawElf) load(filename string) {
	r.sz = os.file_size(filename)
	mut f := os.open(filename) or { panic('cant load the file') }
	r.buff = f.read_bytes(r.sz)
	f.close()
}

fn (mut r RawElf) save(filename string) {
	mut f := os.open_file(filename, 'w+', 0755) or { panic('cant save to file $filename') }
	f.write_to(0, r.buff) or { panic('cant save the data') }
	f.close()
}

   
pub fn (e64 Elf64_hdr) save() {
	mut raw := &RawElf{}
	raw.load(e64.filename)

	for i in 0..ei_nident {
		raw.buff[i] = e64.e_ident[i]
	}
 
	binary.little_endian_put_u16(mut raw.buff[16..18], e64.e_type)
	binary.little_endian_put_u16(mut raw.buff[18..20], e64.e_machine)
	binary.little_endian_put_u32(mut raw.buff[20..24], e64.e_version)
	binary.little_endian_put_u64(mut raw.buff[24..32], e64.e_entry)
	binary.little_endian_put_u64(mut raw.buff[32..40], e64.e_phoff)
	binary.little_endian_put_u64(mut raw.buff[40..48], e64.e_shoff)
	binary.little_endian_put_u32(mut raw.buff[48..52], e64.e_flags)
	binary.little_endian_put_u16(mut raw.buff[52..54], e64.e_ehsize)
	binary.little_endian_put_u16(mut raw.buff[54..56], e64.e_phentsize)
	binary.little_endian_put_u16(mut raw.buff[56..58], e64.e_phnum)
	binary.little_endian_put_u16(mut raw.buff[58..60], e64.e_shentsize)
	binary.little_endian_put_u16(mut raw.buff[60..62], e64.e_shnum)
	binary.little_endian_put_u16(mut raw.buff[62..64], e64.e_shstrndx)

	raw.save(e64.filename)
}

pub fn (e64 Elf64_hdr) save_programs(programs []Elf64_Phdr) {
	mut raw := &RawElf{}
	raw.load(e64.filename)

	mut off := e64.e_phoff
	for p in programs {
		binary.little_endian_put_u32(mut raw.buff[off..off+4], p.p_type)
		binary.little_endian_put_u32(mut raw.buff[off+4..off+8], p.p_flags)
		binary.little_endian_put_u64(mut raw.buff[off+8..off+16], p.p_offset)
		binary.little_endian_put_u64(mut raw.buff[off+16..off+24], p.p_vaddr)
		binary.little_endian_put_u64(mut raw.buff[off+24..off+32], p.p_paddr)
		binary.little_endian_put_u64(mut raw.buff[off+32..off+40], p.p_filesz)
		binary.little_endian_put_u64(mut raw.buff[off+40..off+48], p.p_memsz)
		off += elf64_phdr_sz
	}

	raw.save(e64.filename)
}

pub fn (e64 Elf64_hdr) save_sections(sections []Elf64_Shdr) {
	mut raw := &RawElf{}
	raw.load(e64.filename)

	mut off := e64.e_shoff
	for s in sections {
		binary.little_endian_put_u32(mut raw.buff[off..off+4], s.sh_name)
		binary.little_endian_put_u32(mut raw.buff[off+4..off+8], s.sh_type)
		binary.little_endian_put_u64(mut raw.buff[off+8..off+16], s.sh_flags)
		binary.little_endian_put_u64(mut raw.buff[off+16..off+24], s.sh_addr)
		binary.little_endian_put_u64(mut raw.buff[off+24..off+32], s.sh_offset)
		binary.little_endian_put_u64(mut raw.buff[off+32..off+40], s.sh_size)
		binary.little_endian_put_u32(mut raw.buff[off+40..off+44], s.sh_link)
		binary.little_endian_put_u32(mut raw.buff[off+44..off+48], s.sh_info)
		binary.little_endian_put_u64(mut raw.buff[off+48..off+56], s.sh_addralign)
		binary.little_endian_put_u64(mut raw.buff[off+56..off+64], s.sh_entsize)
		off += elf64_shdr_sz
	}

	raw.save(e64.filename)
}

pub fn (e64 Elf64_hdr) save_dynamics(dynamics []Elf64_Dyn) {
	dyn_section := e64.get_dyn_section() or { panic("Not Dyn section") }

	mut off := dyn_section.sh_offset
	mut raw := &RawElf{}
	raw.load(e64.filename)

	for d in dynamics {
		binary.little_endian_put_u64(mut raw.buff[off..off+8], d.d_tag)
		binary.little_endian_put_u64(mut raw.buff[off+8..off+16], d.d_val)
		off += dyn_section.sh_entsize
	}

	raw.save(e64.filename)
}

pub fn (e64 Elf64_hdr) save_shstrtab(shstrtab []byte) {
	shs_section := e64.get_shstrtab_section() or { panic("No shstrtab section") }

	mut off := int(shs_section.sh_offset)
	mut raw := &RawElf{}
	raw.load(e64.filename)

	for i in 0..shstrtab.len {
		raw.buff[off + i] = shstrtab[i]
	}

	raw.save(e64.filename)	
}
