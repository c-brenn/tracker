defmodule Tracker.Util do
  alias Vial.Set

  def track(state, pid, name, value) do
    key = {pid, name}
    if Set.member?(state.set, key) do
      {:error, :already_tracked}
    else
      Process.link(pid)
      :ets.insert(state.pids, {pid, name})
      new_state = %{state| set: Set.add(state.set, key, value)}
      {:ok, new_state}
    end
  end

  def untrack(state, pid, name) do
    key = {pid, name}
    Process.unlink(pid)
    :ets.delete_object(state.pids, {pid, name})
    %{state| set: Set.remove(state.set, key)}
  end

  def untrack_all(state, pid) do
    keys_to_remove = :ets.lookup(state.pids, pid)
    Process.unlink(pid)
    set = remove_all(state.set, keys_to_remove)
    %{state| set: set}
  end

  def list(table, name) do
    match_pattern = {{:_,name},:_,:_}
    :ets.match_object(table, match_pattern)
  end

  defp remove_all(set, keys) do
    Enum.reduce(keys, set, fn(key, acc) -> Set.remove(acc, key) end)
  end
end
