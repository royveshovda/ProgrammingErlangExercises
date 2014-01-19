.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

MODS =  
        
ERL = erl -boot start_clean 

all:	compile

compile: ${MODS:%=%.beam}

clean:	
	rm -rf *.beam erl_crash.dump
