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
  end

  @spec create_inner_grid(String.t()) :: map()
  defp create_inner_grid(row) do
    String.split(row, "")
    |> trim_list()
    |> Enum.reduce({0, %{}}, fn elem, inner_grid_info ->
      {index, grid} = inner_grid_info
      {index + 1, Map.put(grid, index, elem)}
    end)
    |> then(fn {_, inner_grid} -> inner_grid end)
  end

  defp trim_list([_ | t]) do
    List.delete_at(t, -1)
  end
end
