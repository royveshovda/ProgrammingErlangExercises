.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

ERL = erl -noshell

MODS = ex12

all:	compile

compile: ${MODS:%=%.beam}

clean:	
	rm -rf *.beam erl_crash.dump
