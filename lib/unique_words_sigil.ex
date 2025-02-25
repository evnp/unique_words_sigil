defmodule UniqueWordsSigil do
  @moduledoc """
  ~u Sigil
  --------
  Unique-word strings, lists, HTML classes, checked at compile time.

  Examples
  --------
  ```
  ~u"hello world"      -> "hello world"
  ~u" hello  world "   -> "hello world"  # whitespace is trimmed and "collapsed"
  ~u" hello  world "l  -> ["hello", "world"]
  ~u" hello  world "a  -> [:hello, :world]
  ~u" hello  world "c  -> [~c"hello", ~c"world"]
  ~u" hi     hi    "   -> (ArgumentError) Duplicate word: hi
  ~u" hi-hi  hi-hi "w  -> "hi-hi hi-hi"        Warning: Duplicate word: hi-hi
  ~u" hi     hi    "wl -> ["hi", "hi"]         Warning: Duplicate word: hi
  ~u" hi-hi  hi-hi "aw -> [:"hi-hi", :"hi-hi"] Warning: Duplicate word: hi-hi
  ~u" hi     hi    "cw -> [~c"hi", ~c"hi"]     Warning: Duplicate word: hi
                                                        ~~~~~~~~~~~~~~~~~~
  ```

  ~u is ideal for HTML classes used with templating systems such as
  Temple (https://github.com/mhanberg/temple):
  ```
  div class: ~u"flex items-center flex" do # (CompilerError) Duplicate word: flex
    p class: ~u"text-lg font-bold
                text-gray text-lg"  # ────── (CompilerError) Duplicate word: text-lg
    do                  #    └───── Effortless multiline classes promote readability
      "Hello world"     #          (~u automatically strips whitespace and newlines)
    end
  end
  ```

  ~u also works well with string interpolation:
  ```
  a href: ~p"/link/url"
    class: ~u"flex items-center h-8 text-sm pl-8 pr-3
      \#{if(@active, do: ~u"bg-slate", else: ~u"hover:bg-slate")}
      items-center text-blue"      # Duplicate word: items-center
  do
    "Link text"
  end
  ```

  CAVEAT: Being unknown during compilation, interpolations WON'T be uniqueness-checked by default.

  `i` modifier may be added to check uniqueness of interpolated sections at runtime:
  ```
  ~u" hi hello \#{"h" <> "i"}"i -> (RuntimeError) Duplicate word: hi
  ```
  Interpolation uniqueness-checking is disabled unless ***`i`*** modifier is set to
  to avoid unintended runtime overhead.

  When `Mix.env() == :prod`, interpolation uniqueness-checking will ALWAYS be disabled
  even when ***`i`*** modifier is set (this caters to the most common use-case).
  """

  defmacro sigil_u(term, mod)

  defmacro sigil_u({:<<>>, _meta, [str]}, mod) when is_binary(str) do
    # ~u Sigil implementation used when entire sigil value is known at compile time, eg.
    # ~u"Hello World" NOT ~u"Hello #{"Wor" <> "ld"}"

    unescaped = :elixir_interpolation.unescape_string(str)

    {duplicate_word, _} = check_unique(unescaped, %MapSet{})

    if duplicate_word do
      message = "Duplicate word: #{duplicate_word}"

      if ?w in mod do
        if Mix.env() == :test do
          IO.puts(message)
        else
          IO.warn(message, Macro.Env.stacktrace(__CALLER__))
        end
      else
        raise ArgumentError, message
      end
    end

    handle_modifiers(unescaped, mod)
  end

  defmacro sigil_u({:<<>>, meta, tokens}, mod) do
    # ~u Sigil implementation used when interpolations are present which can only be
    # known at runtime, eg. ~u"Hello #{"Wor" <> "ld"}" NOT ~u"Hello World"

    {tokens, duplicate_word, _word_set} =
      Enum.reduce_while(
        tokens,
        {[], nil, %MapSet{}},
        fn token, {tokens, _duplicate_word, word_set} ->
          if not is_binary(token) do
            {:cont, {[token | tokens], nil, word_set}}
          else
            unescaped = :elixir_interpolation.unescape_string(token)

            {duplicate_word, word_set} = check_unique(unescaped, word_set)

            if duplicate_word do
              {:halt, {[unescaped | tokens], duplicate_word, word_set}}
            else
              {:cont, {[unescaped | tokens], nil, word_set}}
            end
          end
        end
      )

    if duplicate_word do
      message = "Duplicate word: #{duplicate_word}"

      if ?w in mod do
        if Mix.env() == :test do
          IO.puts(message)
        else
          IO.warn(message, Macro.Env.stacktrace(__CALLER__))
        end
      else
        raise ArgumentError, message
      end
    end

    # Reverse tokens here so that we can use more-efficient list-prepend ops above:
    {:<<>>, meta, Enum.reverse(tokens)}
    |> handle_modifiers(mod)
  end

  defmacro valid_modifiers, do: ~w[
    s l a c w i
    sw lw aw cw ws wl wa wc
    si li ai ci is il ia ic
    iw wi
    swi wsi isw iws siw wis
    lwi wli ilw iwl liw wil
    awi wai iaw iwa aiw wia
    cwi wci icw iwc ciw wic
  ]c

  defmacro invalid_modifiers_message(mod) do
    valid = valid_modifiers() |> Enum.join(" ")

    quote do
      "~u(...)#{unquote(mod)} sigil modifiers must be one of: #{unquote(valid)}"
    end
  end

  defp handle_modifiers(_str, mod)
       when mod != [] and mod not in valid_modifiers() do
    raise ArgumentError, invalid_modifiers_message(mod)
  end

  defp handle_modifiers(str, mod) when is_binary(str) do
    cond do
      mod == [] or mod in ~w[s w i sw ws si is wi iw swi wsi isw iws siw wis]c ->
        collapse_whitespace(str)

      mod in ~w[l lw wl li il lwi wli ilw iwl liw wil]c ->
        String.split(str)

      mod in ~w[a aw wa ai ia awi wai iaw iwa aiw wia]c ->
        Enum.map(String.split(str), &String.to_atom/1)

      mod in ~w[c cw wc ci ic cwi wci icw iwc ciw wic]c ->
        Enum.map(String.split(str), &String.to_charlist/1)

      true ->
        raise ArgumentError, invalid_modifiers_message(mod)
    end
  end

  defp handle_modifiers(tokens, mod) do
    cond do
      mod == [] or mod in ~w[s w i sw ws si is wi iw swi wsi isw iws siw wis]c ->
        quote(do: collapse_whitespace(maybe_check_unique(unquote(tokens), unquote(mod))))

      mod in ~w[l lw wl li il lwi wli ilw iwl liw wil]c ->
        quote(do: String.split(maybe_check_unique(unquote(tokens), unquote(mod))))

      mod in ~w[a aw wa ai ia awi wai iaw iwa aiw wia]c ->
        quote(
          do:
            Enum.map(
              String.split(maybe_check_unique(unquote(tokens), unquote(mod))),
              &String.to_atom/1
            )
        )

      mod in ~w[c cw wc ci ic cwi wci icw iwc ciw wic]c ->
        quote(
          do:
            Enum.map(
              String.split(maybe_check_unique(unquote(tokens), unquote(mod))),
              &String.to_charlist/1
            )
        )

      true ->
        raise ArgumentError, invalid_modifiers_message(mod)
    end
  end

  def check_unique(str, word_set) do
    # Ensure that all words in str are unique; if not, return a duplicate_word value.
    # Also return a set of words representing all words that were encountered.
    # Return format is a tuple: {duplicate_word, word_set} (duplicate_word may be nil)

    Enum.reduce_while(String.split(str), {nil, word_set}, fn word, {_, word_set} ->
      if MapSet.member?(word_set, word) do
        {:halt, {word, word_set}}
      else
        {:cont, {nil, MapSet.put(word_set, word)}}
      end
    end)
  end

  def maybe_check_unique(str, mod) do
    if ?i in mod and Mix.env() != :prod do
      {duplicate_word, _} = check_unique(str, %MapSet{})

      if duplicate_word do
        message = "Duplicate word: #{duplicate_word}"

        if ?w in mod do
          if Mix.env() == :test do
            IO.puts(message)
          else
            IO.warn(message)
          end
        else
          raise RuntimeError, message
        end
      end
    end

    str
  end

  def collapse_whitespace(str) do
    # Replace any runs of whitespace with a single space:
    str = String.replace(str, ~r/\s+/, " ")

    first = String.at(str, 0)
    last = String.at(str, -1)

    # Remove possible leading and trailing single-spaces from string:
    # (use binary char replacement instead of String.trim for performace purposes)
    str =
      cond do
        first == " " && last == " " ->
          <<_head::binary-1, rest::binary-size(byte_size(str) - 2), _tail::binary-1>> = str
          rest

        first == " " ->
          <<_head::binary-1, rest::binary-size(byte_size(str) - 1)>> = str
          rest

        last == " " ->
          <<rest::binary-size(byte_size(str) - 1), _tail::binary-1>> = str
          rest

        true ->
          str
      end

    str
  end
end
