defmodule Minesweeper do
  @moduledoc """
  Minesweeper
  https://exercism.org/tracks/elixir/exercises/minesweeper
  """

  @spec count_mines(String.t()) :: String.t()
  def count_mines(board) do
    # represent board as a 2d matrix
    IO.inspect(board)

    {_, grid} =
      String.trim(board, "\n")
      |> String.split("\n")
      |> Enum.reduce({0, %{}}, fn row, grid_info ->
        {row_index, grid} = grid_info
        inner_grid = create_inner_grid(row)
        {row_index + 1, Map.put(grid, row_index, inner_grid)}
      end)
      |> IO.inspect()

    rows = Map.keys(grid) |> Enum.count()
    cols = Map.keys(grid[0]) |> Enum.count()

    # iterate through the grid, and for each element
    # if its empty (.), then count the surrounding mine
    # just print for it now

    Enum.reduce(0..rows - 1, %{}, fn row, counted_grid ->
      counted_grid = put_in counted_grid[row], %{}
      Enum.reduce(0..cols - 1, counted_grid, fn col, counted_grid ->
        IO.inspect(grid[row][col], label: :elem)
        if grid[row][col] == " " do
          sum = mines_up(0, row, col, grid, rows, cols)
          |> mines_down(row, col, grid, rows, cols)
          |> mines_left(row, col, grid, rows, cols)
          |> mines_right(row, col, grid, rows, cols)
          |> mines_l_diagonal_up(row, col, grid, rows, cols)
          |> mines_l_diagonal_down(row, col, grid, rows, cols)
          |> mines_r_diagonal_up(row, col, grid, rows, cols)
          |> mines_r_diagonal_down(row, col, grid, rows, cols)
          put_in counted_grid[row][col], sum
        else
          put_in counted_grid[row][col], "*"
        end
      end)
    end)
    |> IO.inspect()

    # render final board


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

  # can pack it in map later for reducing params
  defp mines_up(current_count, row, col, grid, _t_rows, _t_cols) when row - 1 >= 0 do
    if grid[row - 1][col] == "*", do: current_count + 1, else: current_count
  end
  defp mines_up(current_count, _, _, _, _, _), do: current_count

  defp mines_down(current_count, row, col, grid, t_row, _t_cols) when row + 1 <= t_row - 1 do
    if grid[row + 1][col] == "*", do: current_count + 1, else: current_count
  end
  defp mines_down(current_count, _, _, _, _, _), do: current_count

  defp mines_left(current_count, row, col, grid, _t_row, _t_cols) when col - 1 >= 0 do
    if grid[row][col - 1] == "*", do: current_count + 1, else: current_count
  end

  defp mines_left(current_count, _, _, _, _, _), do: current_count

  defp mines_right(current_count, row, col, grid, _t_row, t_cols) when col + 1 <= t_cols - 1 do
    if grid[row][col + 1] == "*", do: current_count + 1, else: current_count
  end

  defp mines_right(current_count, _, _, _, _, _), do: current_count

  defp mines_l_diagonal_up(current_count, row, col, grid, _t_rows, _t_cols) when row - 1 >= 0 and col - 1 >= 0 do
    if grid[row - 1][col - 1] == "*", do: current_count + 1, else: current_count
  end
  defp mines_l_diagonal_up(current_count, _, _, _, _, _), do: current_count

  defp mines_l_diagonal_down(current_count, row, col, grid, t_rows, _t_cols) when row + 1 <= t_rows - 1 and col - 1 >= 0 do
    if grid[row + 1][col - 1] == "*", do: current_count + 1, else: current_count
  end
  defp mines_l_diagonal_down(current_count, _, _, _, _, _), do: current_count

  defp mines_r_diagonal_up(current_count, row, col, grid, _t_rows, t_cols) when row - 1 >= 0 and col + 1 <= t_cols - 1 do
    if grid[row - 1][col + 1] == "*", do: current_count + 1, else: current_count
  end
  defp mines_r_diagonal_up(current_count, _, _, _, _, _), do: current_count

  defp mines_r_diagonal_down(current_count, row, col, grid, t_rows, t_cols) when row + 1 <= t_rows - 1 and col + 1 <= t_cols - 1 do
    if grid[row + 1][col + 1] == "*", do: current_count + 1, else: current_count
  end
  defp mines_r_diagonal_down(current_count, _, _, _, _, _), do: current_count

end
