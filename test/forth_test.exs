defmodule ForthTest do
  use ExUnit.Case
  doctest Forth

  test "greets the world" do
    assert Forth.hello() == :world
  end
end
