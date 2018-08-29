# Res

There are two state machine libraries you should probably check out, but this is a pretty straight forward implementation of a functional state machine without dependencies.

* gen_fsm
* machinery

## To run

```
brew install elixir

mix deps.get # build dependencies

mix docs # builds documentation for this project
open doc/index.html
open doc/Res.Machine.html
open doc/Res.State.html

mix test
```

This is a simple example of dynamically create-able state machines.

It supports:

* creating state machines in JSON (priv/example.json)
* transitions
* tracking errors on transitions
* pluggable transition logger (very simple: stdout, memory) Set to memory

It doesn't support:

* callbacks
* named transition (currently open => reserved, instead of passing a verb like "book" to book the room)
* validating states/transition names (if you have a state named "open" but put a transition to value of "opne")

Run this script to simulate a state for a single room:

```shell
iex -S mix
```

`mix` is the build tool
`iex` is the repl

In the context above you are loading the build tool (which compile the app) into a repl for you to interact with it.

```elixir
Res.Logger.Memory.start_link() # This will start the memory store
machine = Res.Machine.parse("priv/example.json")

state = Res.Machine.init(machine)
IO.puts state.current_state

{:ok, state} = Res.Machine.transition(state, machine, "reserved")
IO.puts state.current_state

{:ok, state} = Res.Machine.transition(state, machine, "in use")
IO.puts state.current_state
IO.puts state.previous_state

# This will fail
{:error, state} = Res.Machine.transition(state, machine, "reserved")

IO.puts state.current_state
IO.puts state.error
IO.puts Res.State.valid?(state)

Res.Logger.Memory.list()
```
