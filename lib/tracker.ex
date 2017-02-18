defmodule Tracker do
  alias __MODULE__
  alias Vial.Set
  use GenServer

  defstruct [:set, :pids]

  def track(tracker, pid, name, value \\ %{}) do
    GenServer.call({tracker, node(pid)}, {:track, pid, name, value})
  end

  def untrack(tracker, pid, name) do
    GenServer.call({tracker, node(pid)}, {:untrack, pid, name})
  end

  def list(tracker, name) do
    GenServer.call(tracker, :table)
    |> Tracker.Util.list(name)
  end

  # GenServer API

  def start_link(topic) do
    GenServer.start_link(__MODULE__, [], name: topic)
  end

  def init([]) do
    Process.flag(:trap_exit, true)

    actor = Node.self
    set = Set.new(actor)
    pids = :ets.new(:pids, [:bag, :private])

    {:ok, %Tracker{set: set, pids: pids}}
  end

  def handle_call({:track, pid, name, value}, _from, state) do
    case Tracker.Util.track(state, pid, name, value) do
        {:ok, new_state} ->
          {:reply, :ok, new_state}
        {:error, :already_tracked} ->
          {:reply, {:error, {:already_tracked, pid, name}}, state}
    end
  end

  def handle_call({:untrack, pid, name}, _from, state) do
    {:reply, :ok, Tracker.Util.untrack(state, pid, name)}
  end

  def handle_call(:table, _from, state) do
    {:reply, state.set.table, state}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    {:noreply, Tracker.Util.untrack_all(state, pid)}
  end
end
