defmodule UniqueWordsSigil do
  @moduledoc """
  ~u sigil - unique-word strings, lists, HTML classes, checked at compile time
  ----------------------------------------------------------------------------

  Examples:
  ---------
  ~u"hello world"      -> "hello world"
  ~u" hello  world "   -> "hello world"  # whitespace is trimmed and "collapsed"
  ~u" hello  world "l  -> ["hello", "world"]
  ~u" hello  world "a  -> [:hello", :world]
  ~u" hello  world "c  -> [~c"hello", ~c"world"]
  ~u" hi     hi    "   -> [Compiler Error] Duplicate word: hi
  ~u" hi-hi  hi-hi "w  -> "hi-hi hi-hi"        [Compiler Warning] Duplicate word: hi-hi
  ~u" hi     hi    "wl -> ["hi", "hi"]         [Compiler Warning] Duplicate word: hi
  ~u" hi-hi  hi-hi "aw -> [:"hi-hi", :"hi-hi"] [Compiler Warning] Duplicate word: hi-hi
  ~u" hi     hi    "cw -> [~c"hi", ~c"hi"]     [Compiler Warning] Duplicate word: hi
                                                                  ~~~~~~~~~~~~~~~~~~

  Ideal for HTML classes used with templating systems eg. github.com/mhanberg/temple:
  -----------------------------------------------------------------------------------
  div class: "flex items-center flex" do                # -> Duplicate word: flex
    p class: "text-lg font-bold text-gray-800 text-lg"  # -> Duplicate word: text-lg
  end                                                        ~~~~~~~~~~~~~~~~~~~~~~~

  Works well with interpolation and multi-line strings:
  -----------------------------------------------------
  CAVEAT: interpolated sections WILL NOT be checked for uniqueness,
          since they aren't known at compile-time.
  ------------------------------------------------
  a href: ~p"/link/url"
    class: ~u"flex items-center h-8 text-sm pl-8 pr-3
      # {if(@active, do: ~u"bg-slate-300", else: ~u"hover:bg-slate-300")}
      items-center text-blue-800"  # -> Duplicate word: items-center
  do                                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    "Click this link!"
  end
  """

  defmacro sigil_u(term, mod)

  defmacro sigil_u({:<<>>, _meta, [str]}, mod) when is_binary(str) do
    unescaped = :elixir_interpolation.unescape_string(str)

    {duplicate_word, _} = check_unique_words(unescaped, %MapSet{})

    if duplicate_word do
      message = "Duplicate word: #{duplicate_word}"

      if ?w in mod do
        IO.warn(message, Macro.Env.stacktrace(__CALLER__))
      else
        raise message
      end
    end

    handle_modifiers(unescaped, mod)
  end

  defmacro sigil_u({:<<>>, meta, tokens}, mod) do
    {tokens, duplicate_word, _word_set} = Enum.reduce_while(
      tokens,
      {[], false, %MapSet{}},
      fn token, {tokens, _duplicate_word, word_set} ->
        if not is_binary(token) do
          {:cont, {[token | tokens], false, word_set}}
        else
          unescaped = :elixir_interpolation.unescape_string(token)

          {duplicate_word, word_set} = check_unique_words(unescaped, word_set)

          if duplicate_word do
            {:halt, {[unescaped | tokens], duplicate_word, word_set}}
          else
            {:cont, {[unescaped | tokens], false, word_set}}
          end
        end
      end
    )

    if duplicate_word do
      message = "Duplicate word: #{duplicate_word}"

      if ?w in mod do
        IO.warn(message, Macro.Env.stacktrace(__CALLER__))
      else
        raise message
      end
    end

    # Reverse tokens here so that we can use more-efficient list-prepend ops above:
    {:<<>>, meta, Enum.reverse(tokens)}
    |> handle_modifiers(mod)
  end

  defmacro valid_modifiers, do: ~w[s l a c w sw lw aw cw ws wl wa wc]c

  defmacro invalid_modifiers_message do
    "~u sigil modifier(s) must be one of: #{valid_modifiers() |> Enum.join(", ")}"
  end

  defp handle_modifiers(_str, mod)
      when mod != [] and mod not in valid_modifiers() do
    raise ArgumentError, invalid_modifiers_message()
  end

  defp handle_modifiers(str, mod) when is_binary(str) do
    cond do
      mod == [] or mod in ~w[s w sw ws]c ->
        collapse_whitespace(str)
      mod in ~w[l lw wl]c ->
        String.split(str)
      mod in ~w[a aw wa]c ->
        Enum.map(String.split(str), &String.to_atom/1)
      mod in ~w[c cw wc]c ->
        Enum.map(String.split(str), &String.to_charlist/1)
      true ->
        raise ArgumentError, invalid_modifiers_message()
    end
  end

  defp handle_modifiers(str, mod) do
    cond do
      mod == [] or mod in ~w[s w sw ws]c ->
        quote(do: collapse_whitespace(unquote(str)))
      mod in ~w[l lw wl]c ->
        quote(do: String.split(unquote(str)))
      mod in ~w[a aw wa]c ->
        quote(do: Enum.map(String.split(unquote(str)), &String.to_atom/1))
      mod in ~w[c cw wc]c ->
        quote(do: Enum.map(String.split(unquote(str)), &String.to_charlist/1))
      true ->
        raise ArgumentError, invalid_modifiers_message()
    end
  end

  defp check_unique_words(str, word_set) do
    Enum.reduce_while(String.split(str), {false, word_set}, fn word, {_, word_set} ->
      if MapSet.member?(word_set, word) do
        {:halt, {word, word_set}}
      else
        {:cont, {false, MapSet.put(word_set, word)}}
      end
    end)
  end

  defp collapse_whitespace(str) do
    # Replace any runs of whitespace with a single space:
    str = String.replace(str, ~r/\s+/, " ")

    first = String.at(str, 0)
    last = String.at(str, -1)

    # Remove possible leading and trailing single-spaces from string:
    # (use binary char replacement instead of String.trim for performace purposes)
    str = cond do
      first == " " && last == " " ->
        <<_head::binary-1,rest::binary-size(byte_size(str)-2),_tail::binary-1>> = str
        rest
      first == " " ->
        <<_head::binary-1,rest::binary-size(byte_size(str)-1)>> = str
        rest
      last == " " ->
        <<rest::binary-size(byte_size(str)-1),_tail::binary-1>> = str
        rest
      true ->
        str
    end

    str
  end
end
