defmodule Res.Machine do
  @moduledoc """
  Handles creating dynamic machines
  """
  defstruct [:initial_state, :states, :transitions]
  @logger Res.Logger.Memory

  @doc """
  Parses a JSON file to a state `Res.Machine`

  ## Examples
      iex> Res.Machine.parse("priv/test.json")
      %Res.Machine{
         initial_state: "open",
         states: ["open", "reserved", "in use"],
         transitions: %{
           "in use" => ["open"],
           "open" => ["reserved"],
           "reserved" => ["in use", "open"]
         }
       }
  """
  def parse(file) do
    with {:ok, contents} <- File.read(file), {:ok, machine} <- Poison.decode(contents) do
      %Res.Machine{
        initial_state: machine["initial_state"],
        states: machine["states"],
        transitions: cast_transitions_to_list(machine["transitions"])
      }
    else
      _ -> IO.puts("Invalid JSON")
    end
  end

  @doc """
  Initializes default state

  ## Examples
      iex> machine = Res.Machine.parse("priv/test.json")
      iex> state = Res.Machine.init(machine)
      %Res.State{current_state: "open", previous_state: nil, error: nil}
  """
  def init(%Res.Machine{} = machine), do: Res.State.init(machine.initial_state)

  @doc """
  Transitions a machine

  ## Examples
      iex> machine = Res.Machine.parse("priv/example.json")
      iex> state = Res.Machine.init(machine)
      iex> {:ok, state} = Res.Machine.transition(state, machine, "reserved")
      iex> state.current_state
      "reserved"

      iex> machine = Res.Machine.parse("priv/example.json")
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
        transition_to
      ) do
    with true <- Enum.member?(machine.transitions[current], transition_to) do
      @logger.log(current, transition_to)
      state = Res.State.transition(state, transition_to)
      {:ok, state}
    else
      _ -> {:error, Res.State.invalid(state, transition_to)}
    end
  end

  defp cast_transitions_to_list(transitions = %{}) do
    Enum.reduce(transitions, %{}, fn {trans_key, trans_values}, formatted_transitions ->
      Map.put(formatted_transitions, trans_key, cast_to_list(trans_values))
    end)
  end

  defp cast_to_list(values) when is_list(values), do: values
  defp cast_to_list(value), do: [value]
end
