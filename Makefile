WASM_CC=wasm32-unknown-unknown-wasm-clang
WASM_OPTFLAGS=-O3 -flto -DWASM
WASM_LINKER_FLAGS=-Wl,-z,stack-size=524288,--allow-undefined,--no-threads,--stack-first,--no-entry,--export=main,--export=dummy,--export-all
SFCC=awsm

PROJECT_ROOT=.
FE_FOLDER=$(PROJECT_ROOT)/thirdparty/sphinxbase/src/libsphinxbase/fe
FEAT_FOLDER=$(PROJECT_ROOT)/thirdparty/sphinxbase/src/libsphinxbase/feat
UTIL_FOLDER=$(PROJECT_ROOT)/thirdparty/sphinxbase/src/libsphinxbase/util
LM_FOLDER=$(PROJECT_ROOT)/thirdparty/sphinxbase/src/libsphinxbase/lm

SPHINXBASE_INCLUDE=-I$(FE_FOLDER) -I$(FEAT_FOLDER) -I$(LM_FOLDER) -I$(UTIL_FOLDER) -I$(PROJECT_ROOT)/thirdparty/sphinxbase/include/
POCKETSPHINX_INCLUDE=-I$(PROJECT_ROOT)/thirdparty/pocketsphinx/src/libpocketsphinx -I$(PROJECT_ROOT)/thirdparty/pocketsphinx/include 

FE_SRCS := $(FE_FOLDER)/fe_interface.c $(FE_FOLDER)/fe_sigproc.c $(FE_FOLDER)/fe_warp_affine.c $(FE_FOLDER)/fe_warp.c $(FE_FOLDER)/fe_warp_inverse_linear.c $(FE_FOLDER)/fe_warp_piecewise_linear.c $(FE_FOLDER)/fixlog.c $(FE_FOLDER)/fe_noise.c $(FE_FOLDER)/fe_prespch_buf.c

FEAT_SRCS=$(FEAT_FOLDER)/agc.c $(FEAT_FOLDER)/cmn.c $(FEAT_FOLDER)/cmn_live.c $(FEAT_FOLDER)/feat.c $(FEAT_FOLDER)/lda.c

UTIL_SRCS=$(UTIL_FOLDER)/bio.c $(UTIL_FOLDER)/bitvec.c $(UTIL_FOLDER)/case.c $(UTIL_FOLDER)/ckd_alloc.c $(UTIL_FOLDER)/cmd_ln.c $(UTIL_FOLDER)/dtoa.c $(UTIL_FOLDER)/err.c $(UTIL_FOLDER)/errno.c $(UTIL_FOLDER)/f2c_lite.c $(UTIL_FOLDER)/filename.c $(UTIL_FOLDER)/genrand.c $(UTIL_FOLDER)/glist.c $(UTIL_FOLDER)/hash_table.c $(UTIL_FOLDER)/heap.c $(UTIL_FOLDER)/listelem_alloc.c $(UTIL_FOLDER)/logmath.c $(UTIL_FOLDER)/matrix.c $(UTIL_FOLDER)/mmio.c $(UTIL_FOLDER)/pio.c $(UTIL_FOLDER)/profile.c $(UTIL_FOLDER)/sbthread.c $(UTIL_FOLDER)/strfuncs.c $(UTIL_FOLDER)/bitarr.c $(UTIL_FOLDER)/priority_queue.c
LM_SRCS=$(LM_FOLDER)/fsg_model.c $(LM_FOLDER)/jsgf.c $(LM_FOLDER)/jsgf_parser.c $(LM_FOLDER)/jsgf_scanner.c $(LM_FOLDER)/ngrams_raw.c $(LM_FOLDER)/lm_trie.c $(LM_FOLDER)/lm_trie_quant.c $(LM_FOLDER)/ngram_model_set.c $(LM_FOLDER)/ngram_model_trie.c $(LM_FOLDER)/ngram_model.c

POCKETSPHINX_FOLDER=$(PROJECT_ROOT)/thirdparty/pocketsphinx/src/libpocketsphinx

POCKETSPHINX_SRCS=$(POCKETSPHINX_FOLDER)/acmod.c $(POCKETSPHINX_FOLDER)/bin_mdef.c $(POCKETSPHINX_FOLDER)/blkarray_list.c $(POCKETSPHINX_FOLDER)/dict.c $(POCKETSPHINX_FOLDER)/dict2pid.c $(POCKETSPHINX_FOLDER)/fsg_history.c $(POCKETSPHINX_FOLDER)/fsg_lextree.c $(POCKETSPHINX_FOLDER)/fsg_search.c $(POCKETSPHINX_FOLDER)/hmm.c $(POCKETSPHINX_FOLDER)/mdef.c $(POCKETSPHINX_FOLDER)/ms_gauden.c $(POCKETSPHINX_FOLDER)/ms_mgau.c $(POCKETSPHINX_FOLDER)/ms_senone.c $(POCKETSPHINX_FOLDER)/ngram_search.c $(POCKETSPHINX_FOLDER)/ngram_search_fwdtree.c $(POCKETSPHINX_FOLDER)/ngram_search_fwdflat.c $(POCKETSPHINX_FOLDER)/phone_loop_search.c $(POCKETSPHINX_FOLDER)/pocketsphinx.c $(POCKETSPHINX_FOLDER)/ps_lattice.c $(POCKETSPHINX_FOLDER)/ps_mllr.c $(POCKETSPHINX_FOLDER)/ptm_mgau.c $(POCKETSPHINX_FOLDER)/s2_semi_mgau.c $(POCKETSPHINX_FOLDER)/tmat.c $(POCKETSPHINX_FOLDER)/vector.c $(POCKETSPHINX_FOLDER)/kws_search.c $(POCKETSPHINX_FOLDER)/kws_detections.c $(POCKETSPHINX_FOLDER)/allphone_search.c $(POCKETSPHINX_FOLDER)/ps_alignment.c $(POCKETSPHINX_FOLDER)/state_align_search.c

POCKETSPHINX_BC := $(POCKETSPHINX_SRCS:.c=.bc)

FLAGS=-Oz

SPHINXBASE_SRCS := $(FE_SRCS) $(FEAT_SRCS) $(LM_SRCS) $(UTIL_SRCS)
SPHINXBASE_BC := $(SPHINXBASE_SRCS:.c=.bc)

SRCS=$(POCKETSPHINX_SRCS) $(FE_SRCS) $(FEAT_SRCS) $(LM_SRCS) $(UTIL_SRCS) hello_ps.c

CC = clang

.PHONY: sphinxbase pocketsphinx clean

all: build

sphinxbase:
	cd /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase && ./autogen.sh
	cd /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase && ./configure --enable-static
	make -C /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase
	make -C /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase check
	make -C /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase install
	make -C /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase clean

pocketsphinx: sphinxbase
	cd /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx && ./autogen.sh
	cd /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx && ./configure
	make -C /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx
	make -C /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx check
	make -C /sledge/runtime/tests/speechtotext/thirdparty/pocketsphinx install
	make -C /sledge/runtime/tests/speechtotext/thirdparty/sphinxbase clean

clean:
	@rm -rf tmp

hello_ps:
	$(CC) --target=x86_64-pc-linux-gnu $(SPHINXBASE_INCLUDE) $(POCKETSPHINX_INCLUDE) \
	-DHAVE_UNISTD_H -DMODELDIR=\"`pkg-config --variable=modeldir pocketsphinx`\" \
	-lpthread -lm -I/usr/local/include -L/usr/local/lib -o hello_ps $(POCKETSPHINX_SRCS) $(SPHINXBASE_SRCS) hello_ps.c

hello_ps.wasm:
	$(WASM_CC) \
	$(WASM_OPTFLAGS) \
	-lm \
	$(WASM_LINKER_FLAGS) \
	--target=wasm32-unknown-unknown-wasm \
	-nostartfiles \
	$(SPHINXBASE_INCLUDE) $(POCKETSPHINX_INCLUDE) \
	-DHAVE_UNISTD_H -DMODELDIR=\"`pkg-config --variable=modeldir pocketsphinx`\" \
	-o hello_ps.wasm \
	hello_ps.c /sledge/awsm/code_benches/dummy.c $(SPHINXBASE_SRCS) $(POCKETSPHINX_SRCS)

hello_ps.bc: hello_ps.wasm
	$(SFCC) --inline-constant-globals --runtime-globals hello_ps.wasm -o hello_ps.bc
	# -DMODELDIR=\"`pkg-config --variable=modeldir pocketsphinx`\" \

hello_ps_wasm.so: hello_ps.bc
	$(CC) --shared -fPIC -O3 -flto -DUSE_MEM_VM -I/sledge/runtime//include/ \
	tmp/hello_ps.bc /sledge/runtime//compiletime/instr.c /sledge/runtime//compiletime/memory/64bit_nix.c \
	-o tmp/hello_ps_wasm.so

install: hello_ps_wasm.so
	cp tmp/hello_ps_wasm.so /sledge/runtime/bin/hello_ps_wasm.so
