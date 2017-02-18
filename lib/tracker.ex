defmodule Tracker do
  alias __MODULE__
  alias Vial.Set
  use GenServer

  def track(tracker, pid, name, value \\ %{}) do
    GenServer.call(tracker, {:track, pid, name, value})
  end

  def untrack(tracker, pid, name) do
    GenServer.call(tracker, {:untrack, pid, name})
  end

  def list(tracker, name) do
    GenServer.call(tracker, :table)
    |> Tracker.Util.list(name)
  end

  # GenServer API

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    set = Set.new(name)
    {:ok, set}
  end

  def handle_call({:track, pid, name, value}, _from, set) do
    case Tracker.Util.track(set, pid, name, value) do
        {:ok, new_set} ->
          {:reply, :ok, new_set}
        {:error, :already_tracked} ->
          {:reply, {:error, {:already_tracked, pid, name}}, set}
    end
  end

  def handle_call({:untrack, pid, name}, _from, set) do
    {:reply, :ok, Tracker.Util.untrack(set, pid, name)}
  end

  def handle_call(:table, _from, set) do
    {:reply, set.table, set}
  end
end
