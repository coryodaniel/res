defmodule Res.Logger.Stdout do
  @behaviour Res.Logger

  def log(from, to) do
    IO.puts("Transitioned from #{from} to #{to}")
  end
end
