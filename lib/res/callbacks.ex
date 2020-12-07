defmodule Res.Callbacks do
  require Logger

  def testEnter do
    Logger.info("Entered")
  end

  def testLeave do
    Logger.info("Left")
  end

  def run(callbacks) when is_list(callbacks) do
    Enum.each(callbacks, &Res.Callbacks.apply_callback/1)
  end

  def run(_), do: nil

  def apply_callback(callback) do
    apply(__MODULE__, String.to_existing_atom(callback), [])
  end
end
