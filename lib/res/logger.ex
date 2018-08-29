defmodule Res.Logger do
  @moduledoc """
  Protocol behavior for logging transitions
  """

  @callback log(from :: String.t(), to :: String.t()) :: :ok
end
