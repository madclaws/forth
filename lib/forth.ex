defmodule Forth do
  @moduledoc """
  Documentation for `Forth`.
  """

  # TODO: typedoc
  @type t :: %__MODULE__{
          stack: list(integer()),
          custom_words: map()
        }

  defstruct stack: [], custom_words: %{}

  @spec new :: __MODULE__.t()
  def new do
    %__MODULE__{}
  end

  @spec stack(__MODULE__.t()) :: list(integer())
  def stack(%__MODULE__{stack: stack}), do: stack

  @doc """

  NOTE: Stack pushes are prepended than appended for faster and easier list manipulations.
  After the evaluation, the stack list is reversed.
  """
  @spec eval(__MODULE__.t(), String.t()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def eval(%__MODULE__{} = forth, input) do
    String.split(input)
    |> Enum.reduce_while(forth, fn data, forth ->
      case eval_token(forth, data) do
        %__MODULE__{} = res -> {:cont, res}
        res -> {:halt, {:error, res}}
      end
    end)
    |> case do
      %__MODULE__{} = res ->
        {:ok, %{res | stack: Enum.reverse(res.stack)}}

      err ->
        err
    end
  end

  @spec eval_token(__MODULE__.t(), token :: String.t()) :: list(integer()) | String.t()
  defp eval_token(%__MODULE__{stack: stack} = forth, token) do
    cond do
      number?(token) ->
        %{forth | stack: [String.to_integer(token) | stack]}

      true ->
        eval_word(forth, String.downcase(token))
    end
  end

  # numbers should be noe or more ascii digits
  @spec number?(String.t()) :: boolean()
  defp number?(num) do
    String.to_charlist(num)
    |> Enum.all?(fn digit -> digit >= 48 and digit <= 57 end)
  end

  # TODO: Add the required stack size check
  @spec eval_word(__MODULE__.t(), String.t()) :: stack :: __MODULE__.t() | String.t()
  defp eval_word(%__MODULE__{stack: stack} = forth, token) when token in ["+", "-", "/", "*"] do
    with [_ | _] = stack <- eval_arithmetic(token, stack) do
      %{forth | stack: stack}
    end
  end

  defp eval_word(%__MODULE__{stack: []}, "dup"),
    do: "Not enough elements in stack for operaiton: DUP"

  defp eval_word(%__MODULE__{stack: [a | _]} = forth, "dup") do
    %{forth | stack: [a | forth.stack]}
  end

  defp eval_word(%__MODULE__{stack: []}, "drop"),
    do: "Not enough elements in stack for operaiton: DROP"

  defp eval_word(%__MODULE__{stack: [_ | t]} = forth, "drop") do
    %{forth | stack: t}
  end

  defp eval_word(%__MODULE__{stack: [b, a | _]} = forth, "swap") do
    %{
      forth
      | stack:
          List.replace_at(forth.stack, 0, a)
          |> List.replace_at(1, b)
    }
  end

  defp eval_word(_forth, "swap"), do: "Not enough elements in stack for operaiton: SWAP"

  defp eval_word(%__MODULE__{stack: [_b, a | _]} = forth, "over") do
    %{forth | stack: [a | forth.stack]}
  end

  defp eval_word(_forth, "over"), do: "Not enough elements in stack for operaiton: OVER"

  defp eval_word(%__MODULE__{} = forth, ":") do
  end

  defp eval_word(_, _), do: "No OP defined"

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
