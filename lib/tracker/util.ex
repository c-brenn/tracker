defmodule Tracker.Util do
  alias Vial.Set

  def track(set, pid, name, value) do
    key = {pid, name}
    if Set.member?(set, key) do
      {:error, :already_tracked}
    else
      {:ok, Set.add(set, key, value)}
    end
  end

  def untrack(set, pid, name) do
    key = {pid, name}
    Set.remove(set, key)
  end

  def list(table, name) do
    match_pattern = {{:_,name},:_,:_}
    :ets.match_object(table, match_pattern)
  end
end
