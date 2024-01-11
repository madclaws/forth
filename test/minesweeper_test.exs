defmodule MinesweeperTest do
  use ExUnit.Case

  @tag :mine
  test "board 1" do
    assert Minesweeper.count_mines("""
           ·*·*·
           ··*··
           ··*··
           ·····
           """) == "1*3*1\n13*31\n.2*2.\n.111."
  end

  @tag :mine
  test "board 2" do
    assert Minesweeper.count_mines("""
           ***
           ***
           ***
           """) == "***\n***\n***"
  end
end
