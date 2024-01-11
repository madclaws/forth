defmodule ForthTest do
  use ExUnit.Case
  doctest Forth

  # TODO: handling of extra spaces in eval?

  test "empty stack" do
    assert Forth.new() |> Forth.stack() == []
  end

  test "addition, success" do
    assert {:ok, %{stack: [3]}} = Forth.new()
    |> Forth.eval("1 2 +")
  end

  test "addition, failed" do
    assert {:error, _} = Forth.new()
    |> Forth.eval("1 +")
  end

  test "subtraction, success" do
    assert {:ok, %{stack: [-8]}} = Forth.new()
    |> Forth.eval("2 10 -")
  end

  test "subtraction, failed" do
    assert {:error, _} = Forth.new()
    |> Forth.eval("10 -")
  end

  test "multiplication, success" do
    assert {:ok, %{stack: [40]}} = Forth.new()
    |> Forth.eval("20 2 *")
  end

  test "multiplication, failed" do
    assert {:error, _} = Forth.new()
    |> Forth.eval("20 *")
  end

  test "division, success" do
    assert {:ok, %{stack: [10]}} = Forth.new()
    |> Forth.eval("20 2 /")
  end

  test "division, failed" do
    assert {:error, "Division by zero is invalid"} = Forth.new()
    |> Forth.eval("20 0 /")
  end

  test "multiple arithmetic operations" do
    assert {:ok, %{stack: [-10]}} = Forth.new()
    |> Forth.eval("10 20 + 40 -")

    assert {:ok, %{stack: [2]}} = Forth.new()
    |> Forth.eval("2 4 + 3 /")

    assert {:ok, %{stack: [5]}} = Forth.new()
    |> Forth.eval("10 20 * 40 /")

    assert {:error, _} = Forth.new()
    |> Forth.eval("10 20 * 0 /")
  end
end
