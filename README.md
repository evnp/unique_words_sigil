# Unique-Words Sigil

***`~u`*** **sigil ·** unique-word strings, lists, HTML classes, checked at compile time

Ideal for HTML classes used with templating systems such as [Temple](https://github.com/mhanberg/temple):

```elixir
div class: ~u"flex items-center flex" do # (CompilerError) Duplicate word: flex
  p class: ~u"text-lg font-bold
              text-gray text-lg"  # ────── (CompilerError) Duplicate word: text-lg
  do          #            └───── Effortless multiline classes promote readability
    "Hello world"
  end
end
```

## Installation

Add `unique_words_sigil` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:unique_words_sigil, "~> 0.1.0"}
  ]
end
```
then
```
mix deps.get
```
Start up a repl:
```elixir
$ iex -S mix

iex> import UniqueWordsSigil

iex> ~u" hello  world "
"hello world"  # Whitespace trimmed, extra space & newlines ignored.

iex> ~u" hello  world hello  again"
** (ArgumentError) Duplicate word: hello  # Duplicate words prevented ⚔️

iex> {~u" hello  world "l, ~u" hello  world "a, ~u" hello  world "c}
{["hello", "world"], [:hello, :world], [~c"hello", ~c"world"]}
# String lists, atoms, charlists, oh my! (parity with ~w sigil)
```

## Usage

```elixir
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

***`~u`*** works well with interpolation and multi-line strings:

```elixir
a href: ~p"/link/url"
  class: ~u"flex items-center h-8 text-sm pl-8 pr-3
    #{if(@active, do: ~u"bg-slate", else: ~u"hover:bg-slate")}
    items-center text-blue"  # ────── Duplicate word: items-center
do  #          └─ Effortless multiline classes promote readability
  "Hello world"
end
```
[!IMPORTANT]
By default, interpolations WON'T be uniqueness-checked, since they aren't known at compile-time.

***`i`*** modifier may be added to check uniqueness of interpolated sections at runtime:
```
~u" hi hello \#{"h" <> "i"}"i -> (RuntimeError) Duplicate word: hi
```
Interpolation uniqueness-checking is disabled unless ***`i`*** modifier is set to avoid
unintended runtime overhead.

When `Mix.env() == :prod`, interpolation uniqueness-checking will ALWAYS be disabled
even when ***`i`*** modifier is set (this behavior caters to the most common use-case).

# License

MIT

