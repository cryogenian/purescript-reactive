all: lib test

lib:
	mkdir -p js/Control/
	psc src/Control/Reactive.purs.hs \
	  -o js/Control/Reactive.js \
	  -e js/Control/Reactive.e.purs.hs \
	  --module Control.Reactive --tco --magic-do

test:
	psc src/Control/Reactive.purs.hs examples/test.purs.hs \
	  -o js/test.js \
	  --main --module Main --tco --magic-do
