.PHONY: build
build:
	docker run --rm -it -v ${PWD}:/app -w /app elixir mix deps.get

.PHONY: test
test:
	docker run --rm -it -v ${PWD}:/app -w /app elixir mix test

.PHONY: format
format:
	docker run --rm -it -v ${PWD}:/app -w /app elixir mix format 

.PHONY: iex
iex:
	docker run --rm -it -v ${PWD}:/app -w /app elixir iex -S mix