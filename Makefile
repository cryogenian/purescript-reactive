all: lib test

lib:
	mkdir -p js/Data/
	psc src/Data/Reactive.purs.hs \
	  -o js/Data/Reactive.js \
	  -e js/Data/Reactive.e.purs.hs \
	  --module Data.Reactive --tco --magic-do

test:
	psc src/Data/Reactive.purs.hs examples/test.purs.hs \
	  -o js/test.js \
	  --main --module Main --tco --magic-do
