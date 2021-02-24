x86_64_kernel_source := $(shell find src/impl/kernel -name *.c)
x86_64_kernel_object := $(patsubst src/impl/kernel/%.c, build/kernel/%.o, $(x86_64_kernel_source))

x86_64_c_source := $(shell find src/impl/x86_64 -name *.c)
x86_64_c_object := $(patsubst src/impl/x86_64/%.c, build/x86_64/%.o, $(x86_64_c_source))

x86_64_asm_source := $(shell find src/impl/x86_64 -name *.asm)
x86_64_asm_object := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source))

x86_64_object := $(x86_64_c_object) $(x86_64_asm_object)

$(x86_64_kernel_object): build/kernel/%.o : src/impl/kernel/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I src/intf -ffreestanding $(patsubst build/kernel/%.o, src/impl/kernel/%.c, $@) -o $@

$(x86_64_c_object): build/x86_64/%.o : src/impl/x86_64/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I src/intf -ffreestanding $(patsubst build/x86_64/%.o, src/impl/x86_64/%.c, $@) -o $@

$(x86_64_asm_object): build/x86_64/%.o : src/impl/x86_64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/x86_64/%.o, src/impl/x86_64/%.asm, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(x86_64_kernel_object) $(x86_64_object)
	mkdir -p dist/x86_64 && .
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(x86_64_kernel_object) $(x86_64_object)
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso

.PHONY: copy-iso
copy-iso:
	cp dist/x86_64/kernel.iso /mnt/c/Users/Nicolas/Documents/kernel/kernel.iso
