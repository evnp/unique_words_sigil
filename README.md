# Unique-Words Sigil

**~u sigil** - unique-word strings, lists, HTML classes, checked at compile time

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

Interactive Elixir (1.18.2) - press Ctrl+C to exit (type h() ENTER for help)

iex :: import UniqueWordsSigil
UniqueWordsSigil

iex :: ~u" hello  world "  # Whitespace trimmed, extra space & newlines ignored:
"hello world"

iex :: ~u" hello  world hello  again"  # Duplicate words prevented:
** (ArgumentError) Duplicate word: hello
    (unique_words_sigil 0.1.0) expanding macro: UniqueWordsSigil.sigil_u/2
    iex:20: (file)

iex :: ~u" hello  world hello  again"w  # Duplicate words warned:
warning: Duplicate word: hello
  iex:2: (file)
"hello world hello again"

iex :: {~u" hello  world "l, ~u" hello  world "a, ~u" hello  world "c}  # Modifiers:
{["hello", "world"], [:hello, :world], [~c"hello", ~c"world"]}
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

`~u` is ideal for HTML classes used with templating systems such as [github.com/mhanberg/temple](https://github.com/mhanberg/temple):
```elixir
div class: ~u"flex items-center flex" do                # -> Duplicate word: flex
  p class: ~u"text-lg font-bold text-gray-800 text-lg"  # -> Duplicate word: text-lg
end                                                     #    ~~~~~~~~~~~~~~~~~~~~~~~
```

`~u` works well with interpolation and multi-line strings, for effortless splitting of HTML classes onto multiple lines to make templates more readable:

[!IMPORTANT]
Interpolations WILL NOT be checked for uniqueness, since they aren't known at compile-time.

```elixir
a href: ~p"/link/url"
  class: ~u"flex items-center h-8 text-sm pl-8 pr-3
    # {if(@active, do: ~u"bg-slate-300", else: ~u"hover:bg-slate-300")}
    items-center text-blue-800"  # -> Duplicate word: items-center
do                               #    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  "Click this link!"
end
```

# License

MIT

