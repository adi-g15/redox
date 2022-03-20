build/filesystem.bin: filesystem.toml build/bootloader build/kernel prefix
	cargo build --manifest-path cookbook/Cargo.toml --release
	cargo build --manifest-path installer/Cargo.toml --release
	cargo build --manifest-path redoxfs/Cargo.toml --release
	-$(FUMOUNT) build/filesystem/ || true
	rm -rf $@  $@.partial build/filesystem/
	dd if=/dev/zero of=$@.partial bs=1M count="$(FILESYSTEM_SIZE)"
	redoxfs/target/release/redoxfs-mkfs $@.partial
	mkdir -p build/filesystem/
	redoxfs/target/release/redoxfs-mount $@.partial build/filesystem/
	cp filesystem.toml build/bootloader /build/kernel build/filesystem/
	cp -r $(ROOT)/$(PREFIX_INSTALL)/$(TARGET)/include build/filesystem/include
	cp -r $(ROOT)/$(PREFIX_INSTALL)/$(TARGET)/lib build/filesystem/lib
	$(INSTALLER) -c $< build/filesystem/
	sync
	-$(FUMOUNT) build/filesystem/ || true
	rm -rf build/filesystem/
	mv $@.partial $@

mount: FORCE
	mkdir -p build/filesystem/
	cargo build --manifest-path redoxfs/Cargo.toml --release --bin redoxfs-mount
	redoxfs/target/release/redoxfs-mount build/harddrive.bin build/filesystem/

mount_extra: FORCE
	mkdir -p build/filesystem/
	cargo build --manifest-path redoxfs/Cargo.toml --release --bin redoxfs-mount
	redoxfs/target/release/redoxfs-mount build/extra.bin build/filesystem/

unmount: FORCE
	sync
	-$(FUMOUNT) build/filesystem/ || true
	rm -rf build/filesystem/
