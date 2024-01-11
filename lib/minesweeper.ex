defmodule Minesweeper do
  @moduledoc """
  Minesweeper
  https://exercism.org/tracks/elixir/exercises/minesweeper
  """

  @doc """
  Given a string board, returns the string but the mine count for the empty spaces
  """
  @spec count_mines(String.t()) :: String.t()
  def count_mines(board) do
    # represent board as a 2d matrix
    grid = create_2d_grid(board)

    total_rows = Map.keys(grid) |> Enum.count()
    total_cols = Map.keys(grid[0]) |> Enum.count()

    # iterate through the 2d grid and add the mine count
    Enum.reduce(0..(total_rows - 1), "", fn row, counted_grid ->
      counted_grid = counted_grid <> "\n"

      Enum.reduce(0..(total_cols - 1), counted_grid, fn col, counted_grid ->
        size = %{rows: total_rows, cols: total_cols}

        if grid[row][col] == " " do
          nearby_mine(0, row, col, grid, size, :up)
          |> nearby_mine(row, col, grid, size, :down)
          |> nearby_mine(row, col, grid, size, :left)
          |> nearby_mine(row, col, grid, size, :right)
          |> nearby_mine(row, col, grid, size, :leftup)
          |> nearby_mine(row, col, grid, size, :leftdown)
          |> nearby_mine(row, col, grid, size, :rightup)
          |> nearby_mine(row, col, grid, size, :rightdown)
          |> append_mine_count(counted_grid)
        else
          "#{counted_grid}*"
        end
      end)
    end)
    |> String.trim_leading("\n")
  end

  @spec create_2d_grid(String.t()) :: map()
  defp create_2d_grid(board) do
    {_, grid} =
      String.trim(board, "\n")
      |> String.split("\n")
      |> Enum.reduce({0, %{}}, fn row, grid_info ->
        {row_index, grid} = grid_info
        inner_grid = create_inner_grid(row)
        {row_index + 1, Map.put(grid, row_index, inner_grid)}
      end)

    grid
  end

  @spec create_inner_grid(String.t()) :: map()
  defp create_inner_grid(row) do
    String.split(row, "")
    |> trim_list()
    |> Enum.reduce({0, %{}}, fn elem, inner_grid_info ->
      {index, grid} = inner_grid_info
      elem = if elem == "*", do: "*", else: " "
      {index + 1, Map.put(grid, index, elem)}
    end)
    |> then(fn {_, inner_grid} -> inner_grid end)
  end

  defp trim_list([_ | t]) do
    List.delete_at(t, -1)
  end

  @spec nearby_mine(
          integer(),
          integer(),
          integer(),
          map(),
          map(),
          :up | :down | :left | :right | :leftup | :leftdown | :rightup | :rightdown
        ) :: integer()
  defp nearby_mine(current_count, row, col, grid, _size, :up) when row - 1 >= 0 do
    if grid[row - 1][col] == "*", do: current_count + 1, else: current_count
  end

  defp nearby_mine(current_count, row, col, grid, %{rows: rows}, :down)
       when row + 1 <= rows - 1 do
    if grid[row + 1][col] == "*", do: current_count + 1, else: current_count
  end

  defp nearby_mine(current_count, row, col, grid, _size, :left) when col - 1 >= 0 do
    if grid[row][col - 1] == "*", do: current_count + 1, else: current_count
  end

  defp nearby_mine(current_count, row, col, grid, %{cols: cols}, :right)
       when col + 1 <= cols - 1 do
    if grid[row][col + 1] == "*", do: current_count + 1, else: current_count
  end

  defp nearby_mine(current_count, row, col, grid, _size, :leftup)
       when row - 1 >= 0 and col - 1 >= 0 do
    if grid[row - 1][col - 1] == "*", do: current_count + 1, else: current_count
  end

  defp nearby_mine(current_count, row, col, grid, %{rows: rows}, :leftdown)
       when row + 1 <= rows - 1 and col - 1 >= 0 do
    if grid[row + 1][col - 1] == "*", do: current_count + 1, else: current_count
  end

  defp nearby_mine(current_count, row, col, grid, %{cols: cols}, :rightup)
       when row - 1 >= 0 and col + 1 <= cols - 1 do
    if grid[row - 1][col + 1] == "*", do: current_count + 1, else: current_count
  end

  defp nearby_mine(current_count, row, col, grid, %{rows: rows, cols: cols}, :rightdown)
       when row + 1 <= rows - 1 and col + 1 <= cols - 1 do
    if grid[row + 1][col + 1] == "*", do: current_count + 1, else: current_count
  end

  defp nearby_mine(current_count, _, _, _, _, _), do: current_count

  defp append_mine_count(0, counted_grid), do: "#{counted_grid}."
  defp append_mine_count(sum, counted_grid), do: "#{counted_grid}#{to_string(sum)}"
end
