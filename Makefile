build:
	gcc -o hello_ps hello_ps.c     -DMODELDIR=\"`pkg-config --variable=modeldir pocketsphinx`\"     `pkg-config --cflags --libs pocketsphinx sphinxbase`
