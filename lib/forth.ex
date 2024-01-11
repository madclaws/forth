defmodule Forth do
  @moduledoc """
  Documentation for `Forth`.
  """

  # TODO: typedoc
  @type t :: %__MODULE__{
          stack: list(integer()),
          custom_words: map(),
          tokens: list(String.t())
        }

  defstruct stack: [], custom_words: %{}, tokens: []

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
    %{forth | tokens: String.split(input) |> Enum.map(&String.downcase/1)}
    |> eval_token()
    |> case do
      %__MODULE__{} = res ->
        {:ok, %{res | stack: Enum.reverse(res.stack)}}

      err ->
        {:error, err}
    end
  end

  @spec eval_token(__MODULE__.t() | String.t()) :: stack :: __MODULE__.t() | String.t()
  defp eval_token(error) when is_binary(error), do: error

  defp eval_token(%__MODULE__{stack: _stack, tokens: []} = forth), do: forth

  defp eval_token(%__MODULE__{stack: stack, tokens: [token | rest]} = forth)
       when token in ["+", "-", "/", "*"] do
    case eval_arithmetic(token, stack) do
      [_ | _] = stack ->
        eval_token(%{forth | stack: stack, tokens: rest})

      err ->
        eval_token(err)
    end
  end

  defp eval_token(%__MODULE__{stack: [], tokens: ["dup" | _]}),
    do: eval_token("Not enough elements in stack for operaiton: DUP")

  defp eval_token(%__MODULE__{stack: [a | _], tokens: ["dup" | rest]} = forth) do
    eval_token(%{forth | stack: [a | forth.stack], tokens: rest})
  end

  defp eval_token(%__MODULE__{stack: [], tokens: ["drop" | _]}),
    do: eval_token("Not enough elements in stack for operaiton: DROP")

  defp eval_token(%__MODULE__{stack: [_ | t], tokens: ["drop" | rest]} = forth) do
    eval_token(%{forth | stack: t, tokens: rest})
  end

  defp eval_token(%__MODULE__{stack: [b, a | _], tokens: ["swap" | rest]} = forth) do
    eval_token(%{
      forth
      | stack:
          List.replace_at(forth.stack, 0, a)
          |> List.replace_at(1, b),
        tokens: rest
    })
  end

  defp eval_token(%__MODULE__{tokens: ["swap" | _]}),
    do: eval_token("Not enough elements in stack for operaiton: SWAP")

  defp eval_token(%__MODULE__{stack: [_b, a | _], tokens: ["over" | rest]} = forth) do
    eval_token(%{forth | stack: [a | forth.stack], tokens: rest})
  end

  defp eval_token(%__MODULE__{tokens: ["over" | _]}),
    do: eval_token("Not enough elements in stack for operaiton: OVER")

  defp eval_token(%__MODULE__{stack: stack, tokens: [token | rest]} = forth) do
    cond do
      number?(token) ->
        eval_token(%{forth | stack: [String.to_integer(token) | stack], tokens: rest})

      true ->
        eval_token("No OP defined")
    end
  end

  # numbers should be noe or more ascii digits
  @spec number?(String.t()) :: boolean()
  defp number?(num) do
    String.to_charlist(num)
    |> Enum.all?(fn digit -> digit >= 48 and digit <= 57 end)
  end

  # TODO: Add the required stack size check

  # defp eval_token(%__MODULE__{} = forth, ":") do
  #   # start of word definition.
  #   # we basically have to peek until the semicolon
  # end

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
