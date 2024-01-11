defmodule Forth do
  @moduledoc """
  Basic forth evaluator
  https://exercism.org/tracks/elixir/exercises/forth
  """

  @typedoc """
  stack - List of integers
  custom_words - A map of user defined words and its values (values as a list)
  tokens - List of tokens from the eval input
  """
  @type t :: %__MODULE__{
          stack: list(integer()),
          custom_words: map(),
          tokens: list(String.t())
        }

  defstruct stack: [], custom_words: %{}, tokens: []

  @doc """
  Creates an empty forth struct
  """
  @spec new :: __MODULE__.t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Returns the current stack with given forth struct
  """
  @spec stack(__MODULE__.t()) :: list(integer())
  def stack(%__MODULE__{stack: stack}), do: stack

  @doc """
  Evaluate the input with the given forth struct

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

  defp eval_token(%__MODULE__{stack: stack, tokens: [token | next]} = forth)
       when token in ["+", "-", "/", "*"] do
    case eval_arithmetic(token, stack) do
      [_ | _] = stack ->
        eval_token(%{forth | stack: stack, tokens: next})

      err ->
        eval_token(err)
    end
  end

  defp eval_token(%__MODULE__{stack: [], tokens: ["dup" | _]}),
    do: eval_token("Not enough elements in stack for operaiton: DUP")

  defp eval_token(%__MODULE__{stack: [a | _], tokens: ["dup" | next]} = forth) do
    eval_token(%{forth | stack: [a | forth.stack], tokens: next})
  end

  defp eval_token(%__MODULE__{stack: [], tokens: ["drop" | _]}),
    do: eval_token("Not enough elements in stack for operaiton: DROP")

  defp eval_token(%__MODULE__{stack: [_ | t], tokens: ["drop" | next]} = forth) do
    eval_token(%{forth | stack: t, tokens: next})
  end

  defp eval_token(%__MODULE__{stack: [b, a | _], tokens: ["swap" | next]} = forth) do
    eval_token(%{
      forth
      | stack:
          List.replace_at(forth.stack, 0, a)
          |> List.replace_at(1, b),
        tokens: next
    })
  end

  defp eval_token(%__MODULE__{tokens: ["swap" | _]}),
    do: eval_token("Not enough elements in stack for operaiton: SWAP")

  defp eval_token(%__MODULE__{stack: [_b, a | _], tokens: ["over" | next]} = forth) do
    eval_token(%{forth | stack: [a | forth.stack], tokens: next})
  end

  defp eval_token(%__MODULE__{tokens: ["over" | _]}),
    do: eval_token("Not enough elements in stack for operaiton: OVER")

  defp eval_token(%__MODULE__{tokens: [":" | next]} = forth) do
    # collecting tokens just before semicolon
    custom_def_tokens =
      Enum.reduce_while(next, [], fn next_token, custom_def ->
        if next_token == ";" do
          {:halt, custom_def}
        else
          {:cont, custom_def ++ [next_token]}
        end
      end)

    cond do
      custom_def_tokens == next ->
        eval_token("Ending semicolon not found for custom word definition")

      Enum.empty?(custom_def_tokens) ->
        eval_token("Empty definition")

      true ->
        [custom_word_name | definitions] = custom_def_tokens

        eval_token(%{
          forth
          | custom_words: add_custom_words(forth.custom_words, custom_word_name, definitions),
            # taking the tokens after the `;`
            tokens:
              Enum.slice(
                next,
                # including the `;`
                Enum.count(custom_def_tokens) + 1,
                Enum.count(next) - Enum.count(custom_def_tokens) + 1
              )
        })
    end
  end

  defp eval_token(%__MODULE__{stack: stack, tokens: [token | next]} = forth) do
    cond do
      number?(token) ->
        eval_token(%{forth | stack: [String.to_integer(token) | stack], tokens: next})

      custom_word?(forth, token) ->
        eval_token(%{forth | tokens: forth.custom_words[token] ++ next})

      true ->
        eval_token("No Operation defined")
    end
  end

  # numbers should be one or more ascii digits
  @spec number?(String.t()) :: boolean()
  defp number?(num) do
    String.to_charlist(num)
    |> Enum.all?(fn digit -> digit >= 48 and digit <= 57 end)
  end

  @spec eval_arithmetic(String.t(), list(integer())) :: list(integer()) | String.t()
  defp eval_arithmetic(operation, stack) when length(stack) >= 2 do
    [b, a | _] = stack

    case operation do
      "+" ->
        a + b

      "-" ->
        a - b

      "*" ->
        a * b

      "/" when b == 0 ->
        "Division by zero is invalid"

      "/" when b > 0 ->
        div(a, b)
    end
    |> case do
      result when is_binary(result) ->
        result

      result ->
        List.delete_at(stack, 0)
        |> List.replace_at(0, result)
    end
  end

  defp eval_arithmetic(operation, _),
    do: "Not enough elements in stack for operation: #{operation}"

  defp custom_word?(%__MODULE__{} = forth, token) do
    Map.has_key?(forth.custom_words, token)
  end

  defp add_custom_words(custom_words, custom_word_name, definitions) do
    case Enum.find_index(definitions, fn token -> token == custom_word_name end) do
      nil ->
        definitions

      # inlining the redundant token to avoid infinite loop
      index ->
        List.replace_at(definitions, index, custom_words[custom_word_name]) |> List.flatten()
    end
    |> then(&Map.put(custom_words, String.downcase(custom_word_name), &1))
  end
end
