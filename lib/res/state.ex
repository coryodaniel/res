defmodule Res.State do
  @moduledoc """
  Represents the current state of a machine
  """
  defstruct [:current_state, :previous_state, :error]

  @doc """
  Initializes a state

  ## Examples
      iex> Res.State.init("hello")
      %Res.State{current_state: "hello", previous_state: nil, error: nil}
  """
  def init(initial_state), do: %Res.State{current_state: initial_state}

  @doc """
  Updates the `current_state`
  ## Examples
      iex> state = Res.State.init("hello")
      iex> Res.State.transition(state, "bye")
      %Res.State{current_state: "bye", error: nil, previous_state: "hello"}
  """
  def transition(%Res.State{current_state: transition_from} = state, transitioned_to) do
    %Res.State{
      state
      | error: nil,
        current_state: transitioned_to,
        previous_state: transition_from
    }
  end

  @doc """
  Marks a state transitions as invalid
  ## Examples
      iex> state = Res.State.init("hello")
      iex> Res.State.invalid(state, "ohhai")
      %Res.State{current_state: "hello", error: "Cannot transition from 'hello' to 'ohhai'", previous_state: nil}
  """
  def invalid(%Res.State{current_state: current_state} = state, invalid_state) do
    %Res.State{state | error: "Cannot transition from '#{current_state}' to '#{invalid_state}'"}
  end

  @doc """
  Helper to check if a state is invalid
  ## Examples
      iex> state = %Res.State{error: "Blah"}
      iex> Res.State.valid?(state)
      false

      iex> state = %Res.State{error: nil}
      iex> Res.State.valid?(state)
      true
  """
  def valid?(%Res.State{error: err}), do: err == nil
  def invalid?(%Res.State{} = state), do: !valid?(state)
end
