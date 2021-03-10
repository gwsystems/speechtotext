WASMCC=wasm32-unknown-unknown-wasm-clang
OPTFLAGS=-O3 -flto
SFCC=awsm

.PHONY: sphinxbase pocketsphinx clean

all: build

sphinxbase:
	cd /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase && ./autogen.sh
	cd /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase && ./configure
	make -C /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase
	make -C /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase check
	make -C /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase install

pocketsphinx: sphinxbase
	cd /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx && ./autogen.sh
	cd /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx && ./configure
	make -C /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx
	make -C /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx check
	make -C /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx install

clean:
	@rm -rf tmp

build: pocketsphinx
	gcc -o hello_ps hello_ps.c     -DMODELDIR=\"`pkg-config --variable=modeldir pocketsphinx`\"     `pkg-config --cflags --libs pocketsphinx sphinxbase`
build-wasm:
	mkdir -p tmp
	$(WASMCC) \
	-DWASM \
	-lm \
	-Wl,-z,stack-size=524288,--allow-undefined,--no-threads,--stack-first,--no-entry,--export-all,--export=main,--export=dummy \
	-nostartfiles \
	$(OPTFLAGS) \
	-DMODELDIR=\"`pkg-config --variable=modeldir pocketsphinx`\" \
	-I/usr/local/include -I/usr/local/include/sphinxbase -I/usr/local/include/pocketsphinx -I/usr/local/include -I/usr/local/include/sphinxbase \
	-L/usr/local/lib \
	-o tmp/hello_ps.wasm \
	hello_ps.c /sledge/awsm/code_benches/dummy.c


	$(SFCC) --inline-constant-globals --runtime-globals hello_ps.wasm -o tmp/hello_ps.bc

	clang --shared -fPIC -O3 -flto -DUSE_MEM_VM -I/sledge/runtime//include/ -lpocketsphinx -lsphinxbase -lsphinxad -lpthread \
	tmp/hello_ps.bc /sledge/runtime//compiletime/instr.c /sledge/runtime//compiletime/memory/64bit_nix.c \
	-DMODELDIR=\"`pkg-config --variable=modeldir pocketsphinx`\" \
	`pkg-config --cflags --libs pocketsphinx sphinxbase` \
	-o tmp/hello_ps_wasm.so

	cp tmp/hello_ps_wasm.so /sledge/runtime/bin/hello_ps_wasm.so

