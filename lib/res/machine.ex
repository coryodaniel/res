defmodule Res.Machine do
  @moduledoc """
  Handles creating dynamic machines
  """
  defstruct [:initial_state, :states, :valid_transitions, :named_transitions]
  @logger Res.Logger.Memory
  alias Res.Callbacks

  @doc """
  Parses a JSON file to a state `Res.Machine`

  ## Examples
      iex> Res.Machine.parse("priv/test.json")
      %Res.Machine{
        initial_state: "open",
        states: %{
          "open" => nil,
          "reserved" => %{
            "on_leave" => ["testLeave"]
          },
          "in use" => %{
            "on_enter" => ["testEnter"]
          }
        },
        valid_transitions: %{
          "in use" => ["open"],
          "open" => ["reserved"],
          "reserved" => ["in use", "open"]
        },
        named_transitions: %{
          "claim" => %{
            "to" => "in use"
          }
        }
      }
  """
  def parse(file) do
    with {:ok, contents} <- File.read(file), {:ok, machine} <- Jason.decode(contents) do
      %Res.Machine{
        initial_state: machine["initial_state"],
        states: machine["states"],
        valid_transitions: cast_transitions_to_list(machine["valid_transitions"]),
        named_transitions: machine["named_transitions"]
      }
    else
      _ -> IO.puts("Invalid JSON")
    end
  end

  @doc """
  Initializes default state

  ## Examples
      iex> machine = Res.Machine.parse("priv/test.json")
      iex> _ = Res.Machine.init(machine)
      %Res.State{current_state: "open", previous_state: nil, error: nil}
  """
  def init(%Res.Machine{} = machine), do: Res.State.init(machine.initial_state)

  @doc """
  Transitions a machine

  ## Examples
      iex> machine = Res.Machine.parse("priv/test.json")
      iex> state = Res.Machine.init(machine)
      iex> {:ok, state} = Res.Machine.transition(state, machine, "reserved")
      iex> state.current_state
      "reserved"

      iex> machine = Res.Machine.parse("priv/test.json")
      iex> state = Res.Machine.init(machine)
      iex> {:ok, state} = Res.Machine.transition(state, machine, "reserved")
      iex> {:ok, state} = Res.Machine.transition(state, machine, "in use")
      iex> {:error, state} = Res.Machine.transition(state, machine, "reserved")
      iex> state.error
      "Cannot transition from 'in use' to 'reserved'"
  """
  def transition(
        %Res.State{current_state: current} = state,
        %Res.Machine{} = machine,
        transition
      ) do
    with {:ok, transition_to} <- valid_transition_check(transition, machine, current) do
      @logger.log(current, transition_to)
      Callbacks.run(machine.states[current]["on_leave"])
      state = Res.State.transition(state, transition_to)
      Callbacks.run(machine.states[state.current_state]["on_enter"])
      {:ok, state}
    else
      {:error, transition_to} -> {:error, Res.State.invalid(state, transition_to)}
    end
  end

  defp cast_transitions_to_list(transitions = %{}) do
    Enum.reduce(transitions, %{}, fn {trans_key, trans_values}, formatted_transitions ->
      Map.put(formatted_transitions, trans_key, cast_to_list(trans_values))
    end)
  end

  defp cast_to_list(values) when is_list(values), do: values
  defp cast_to_list(value), do: [value]

  defp valid_transition_check(transition, machine, current) do
    transition_to = destination_state_from_named_transition(transition, machine)
    if(Enum.member?(machine.valid_transitions[current], transition_to)) do
      {:ok, transition_to}
    else
      {:error, transition_to}
    end
  end

  defp destination_state_from_named_transition(transition, machine) do
    with %{"to" => transition_to} <- Map.get(machine.named_transitions, transition) do
      transition_to
    else
      _ -> transition
    end
  end
end
