defmodule Res.Logger.Memory do
  @moduledoc """
  An in-memory event store. Useful for debugging and testing.
  """

  @behaviour Res.Logger
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def list do
    Agent.get(__MODULE__, & &1)
  end

  def clear do
    Agent.update(__MODULE__, fn _msgs -> [] end)
  end

  def log(from, to) do
    msg = %{from: from, to: to}
    Agent.update(__MODULE__, fn msgs -> msgs ++ [msg] end)
    :ok
  end
end
