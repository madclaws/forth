defmodule MinesweeperTest do
  use ExUnit.Case

  @tag :mine
  test "mapping board" do
    Minesweeper.count_mines("""
    ·*·*·
    ··*··
    ··*··
    ·····
    """)
  end
end
