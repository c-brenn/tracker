defmodule TrackerTest do
  use ExUnit.Case, async: true

  def new_pid, do: spawn(fn -> :timer.sleep(:infinity) end)

  describe "track" do
    test "it adds the given pid to the given topic" do
      {:ok, _} = Tracker.start_link(:tracker)
      pid = new_pid()

     :ok = Tracker.track(:tracker, pid, :name)

      assert [{{^pid, :name},_,_}] = Tracker.list(:tracker, :name)
    end

    test "it does not re-track pids in a topic" do
      {:ok, _} = Tracker.start_link(:tracker)
      pid = new_pid()

      :ok = Tracker.track(:tracker, pid, :name)

      assert Tracker.track(:tracker, pid, :name) ==
        {:error, {:already_tracked, pid, :name}}
    end
  end

  describe "untrack" do
    test "it removes the pid from the topic" do
      {:ok, _} = Tracker.start_link(:tracker)
      pid = new_pid()

      :ok = Tracker.track(:tracker, pid, :name)
      :ok = Tracker.untrack(:tracker, pid, :name)

      assert Tracker.list(:tracker, :name) == []
    end
  end

  describe "links" do
    test "tracked processes are linked and are untracked when they die" do
      {:ok, _} = Tracker.start_link(:tracker)
      dead = new_pid()
      alive = new_pid()

      :ok = Tracker.track(:tracker, dead, :name)
      :ok = Tracker.track(:tracker, alive, :name)
      :ok = Tracker.track(:tracker, dead, :name1)

      Process.exit(dead, :die)

      assert [{{^alive, :name},_,_}] = Tracker.list(:tracker, :name)
      assert [] == Tracker.list(:tracker, :name1)
    end
  end
end
