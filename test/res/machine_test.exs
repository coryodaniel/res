defmodule Res.MachineTest do
  # There are no tests here because we use the documentation to build the tests for Machine
  use ExUnit.Case
  import ExUnit.CaptureLog
  doctest Res.Machine

  test "it doesnt run calllbacks if they are not configured" do
    machine = Res.Machine.parse("priv/test.json")
    state = Res.Machine.init(machine)
    assert capture_log([level: :info], fn ->
      {:ok, _} = Res.Machine.transition(state, machine, "reserved")
    end) == ""
  end

  test "runs on_leave calllbacks" do
    machine = Res.Machine.parse("priv/test.json")
    state = Res.Machine.init(machine)
    {:ok, state} = Res.Machine.transition(state, machine, "reserved")

    assert capture_log([level: :info], fn ->
      {:ok, _} = Res.Machine.transition(state, machine, "in use")
    end) =~ "Left"
  end

  test "runs on_enter calllbacks" do
    machine = Res.Machine.parse("priv/test.json")
    state = Res.Machine.init(machine)
    {:ok, state} = Res.Machine.transition(state, machine, "reserved")

    assert capture_log([level: :info], fn ->
      {:ok, _} = Res.Machine.transition(state, machine, "in use")
    end) =~ "Entered"
  end

  test "handles named transitions" do
    machine = Res.Machine.parse("priv/test.json")
    state = Res.Machine.init(machine)
    {:ok, state} = Res.Machine.transition(state, machine, "reserved")
    {:ok, state} = Res.Machine.transition(state, machine, "claim")

    assert state.current_state == "in use"
  end

  test "named transitions must observe valid transitions" do
    machine = Res.Machine.parse("priv/test.json")
    state = Res.Machine.init(machine)
    assert {:error, _} = Res.Machine.transition(state, machine, "claim")
  end
end
