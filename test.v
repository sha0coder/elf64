import elf64 

fn main() {
	println("loading an elf")
	ls := elf64.load('/bin/ls')
}

