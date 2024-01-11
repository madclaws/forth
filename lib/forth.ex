defmodule Forth do
  @moduledoc """
  Documentation for `Forth`.
  """

  # TODO: typedoc
  @type t :: %__MODULE__{
          stack: list(integer())
        }

  defstruct stack: []

  @spec new :: __MODULE__.t()
  def new do
    %__MODULE__{}
  end

  @spec stack(__MODULE__.t()) :: list(integer())
  def stack(%__MODULE__{stack: stack}), do: stack

  @spec eval(__MODULE__.t(), String.t()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def eval(%__MODULE__{stack: stack}, input) do
    String.split(input)
    |> Enum.reduce_while(stack, fn data, stack ->
      case eval_token(stack, data) do
        res when is_binary(res) -> {:halt, {:error, res}}
        res -> {:cont, res}
      end
    end)
    |> case do
      res when is_list(res) ->
        {:ok, %__MODULE__{stack: Enum.reverse(res)}}

      err ->
        err
    end
  end

  @spec eval_token(stack :: list(), token :: String.t()) :: list(integer()) | String.t()
  defp eval_token(stack, token) do
    cond do
      number?(token) ->
        [String.to_integer(token) | stack]

      true ->
        eval_word(stack, token)
    end
  end

  # numbers should be noe or more ascii digits
  @spec number?(String.t()) :: boolean()
  defp number?(num) do
    String.to_charlist(num)
    |> Enum.all?(fn digit -> digit >= 48 and digit <= 57 end)
  end

  # TODO: Add the required stack size check
  @spec eval_word(list(integer()), String.t()) :: stack :: list(integer()) | String.t()
  defp eval_word(stack, token) do
    IO.inspect(stack)

    case token do
      token when token in ["+", "-", "/", "*"] -> eval_arithmetic(token, stack)
      "DUP" -> stack
      "DROP" -> stack
      "SWAP" -> stack
      "OVER" -> stack
    end
  end

  @spec eval_arithmetic(String.t(), list(integer())) :: list(integer()) | String.t()
  defp eval_arithmetic(operation, stack) when length(stack) >= 2 do
    [b, a | _] = stack

    # TODO: A chance to optimize below redundant code
    case operation do
      "+" ->
        List.delete_at(stack, 0)
        |> List.replace_at(0, a + b)
      "-" ->
        List.delete_at(stack, 0)
        |> List.replace_at(0, a - b)
      "*" ->
        List.delete_at(stack, 0)
        |> List.replace_at(0, a * b)
      "/" ->
        if b == 0 do
          "Division by zero is invalid"
        else
          List.delete_at(stack, 0)
          |> List.replace_at(0, div(a, b))
        end
    end
  end

  defp eval_arithmetic(operation, _),
    do: "Not enough elements in stack for operation: #{operation}"
end
