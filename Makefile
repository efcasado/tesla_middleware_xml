.PHONY: all deps compile format test docs shell publish clean

ifndef NODOCKER
SHELL := BASH_ENV=.rc /bin/bash --noprofile
endif

all: compile check test docs

deps:
	mix deps.get
	mix deps.compile

compile: deps
	mix compile

format:
	mix format

check:
	mix format --check-formatted

test:
	mix test

docs:
	mix docs

shell: compile
	iex -S mix

publish: deps
	mix local.hex --force
	mix hex.publish --yes

clean:
	mix clean --all
	mix deps.clean --all
