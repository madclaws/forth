defmodule ForthTest do
  use ExUnit.Case
  doctest Forth

  # TODO: handling of extra spaces in eval?

  test "empty stack" do
    assert Forth.new() |> Forth.stack() == []
  end

  test "addition, success" do
    assert {:ok, %{stack: [3]}} =
             Forth.new()
             |> Forth.eval("1 2 +")
  end

  test "addition, failed" do
    assert {:error, _} =
             Forth.new()
             |> Forth.eval("1 +")
  end

  test "subtraction, success" do
    assert {:ok, %{stack: [-8]}} =
             Forth.new()
             |> Forth.eval("2 10 -")
  end

  test "subtraction, failed" do
    assert {:error, _} =
             Forth.new()
             |> Forth.eval("10 -")
  end

  test "multiplication, success" do
    assert {:ok, %{stack: [40]}} =
             Forth.new()
             |> Forth.eval("20 2 *")
  end

  test "multiplication, failed" do
    assert {:error, _} =
             Forth.new()
             |> Forth.eval("20 *")
  end

  test "division, success" do
    assert {:ok, %{stack: [10]}} =
             Forth.new()
             |> Forth.eval("20 2 /")
  end

  @tag :bug
  test "division, failed" do
    assert {:error, "Division by zero is invalid"} =
             Forth.new()
             |> Forth.eval("20 0 /")
  end

  test "multiple arithmetic operations" do
    assert {:ok, %{stack: [-10]}} =
             Forth.new()
             |> Forth.eval("10 20 + 40 -")

    assert {:ok, %{stack: [2]}} =
             Forth.new()
             |> Forth.eval("2 4 + 3 /")

    assert {:ok, %{stack: [5]}} =
             Forth.new()
             |> Forth.eval("10 20 * 40 /")

    assert {:error, _} =
             Forth.new()
             |> Forth.eval("10 20 * 0 /")
  end

  test "DUP operations" do
    assert {:ok, %{stack: [1, 1]}} =
             Forth.new()
             |> Forth.eval("1 DUP")

    assert {:ok, %{stack: [10, 30, 30]}} =
             Forth.new()
             |> Forth.eval("10 30 dup")

    assert {:ok, %{stack: [10, 10, 10, 10]}} =
             Forth.new()
             |> Forth.eval("10 DUP dup DUp")

    # dup failed
    assert {:error, "Not enough elements in stack for operaiton: DUP"} =
             Forth.new()
             |> Forth.eval("DUP")
  end

  test "DROP operations" do
    assert {:ok, %{stack: []}} =
             Forth.new()
             |> Forth.eval("1 drop")

    assert {:ok, %{stack: [10]}} =
             Forth.new()
             |> Forth.eval("10 20 30 40 DROP DROP drop")

    # drop failed
    assert {:error, "Not enough elements in stack for operaiton: DROP"} =
             Forth.new()
             |> Forth.eval("10 20 DROP DROP drop")
  end

  test "SWAP operations" do
    assert {:ok, %{stack: [2, 1]}} =
             Forth.new()
             |> Forth.eval("1 2 swap")

    assert {:ok, %{stack: [10, 20, 40, 30]}} =
             Forth.new()
             |> Forth.eval("10 20 30 40 SWAP")

    assert {:ok, %{stack: [20, 30, 40, 10]}} =
             Forth.new()
             |> Forth.eval("10 20 swap 30 swap 40 swap")

    # swap failed
    assert {:error, "Not enough elements in stack for operaiton: SWAP"} =
             Forth.new()
             |> Forth.eval("10 swap swap SWAP")
  end

  test "OVER operations" do
    assert {:ok, %{stack: [20, 30, 20]}} =
             Forth.new()
             |> Forth.eval("20 30 over")

    assert {:ok, %{stack: [10, 20, 10, 20, 10]}} =
             Forth.new()
             |> Forth.eval("10 20 over Over OVEr")

    # over failed
    assert {:error, "Not enough elements in stack for operaiton: OVER"} =
             Forth.new()
             |> Forth.eval("10 over")
  end
end
