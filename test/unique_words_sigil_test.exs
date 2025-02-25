defmodule UniqueWordsSigilTest do
  use ExUnit.Case

  import Assertions
  import UniqueWordsSigil

  describe "results with default modifier," do
    test "greets the world", do: assert(~u"hello world" === "hello world")
    test "ignores extra spaces", do: assert(~u"hello  world" === "hello world")
    test "ignores newlines", do: assert(~u"hello
      world" === "hello world")
    test "trims spaces", do: assert(~u" hello  world  " === "hello world")
    test "trims newlines", do: assert(~u"
      hello
      world
    " === "hello world")
  end

  describe "results with string modifier," do
    test "greets the world", do: assert(~u"hello world"s === "hello world")
    test "ignores extra spaces", do: assert(~u"hello  world"s === "hello world")
    test "ignores newlines", do: assert(~u"hello
      world"s === "hello world")
    test "trims spaces", do: assert(~u" hello  world  "s === "hello world")
    test "trims newlines", do: assert(~u"
      hello
      world
    "s === "hello world")
  end

  describe "results with list modifier," do
    test "greets the world", do: assert(~u"hello world"l === ["hello", "world"])
    test "ignores extra spaces", do: assert(~u"hello  world"l === ["hello", "world"])
    test "ignores newlines", do: assert(~u"hello
      world"l === ["hello", "world"])
    test "trims spaces", do: assert(~u" hello  world  "l === ["hello", "world"])
    test "trims newlines", do: assert(~u"
      hello
      world
    "l === ["hello", "world"])
  end

  describe "results with charlist modifier," do
    test "greets the world", do: assert(~u"hello world"c === [~c"hello", ~c"world"])
    test "ignores extra spaces", do: assert(~u"hello  world"c === [~c"hello", ~c"world"])
    test "ignores newlines", do: assert(~u"hello
      world"c === [~c"hello", ~c"world"])
    test "trims spaces", do: assert(~u" hello  world  "c === [~c"hello", ~c"world"])
    test "trims newlines", do: assert(~u"
      hello
      world
    "c === [~c"hello", ~c"world"])
  end

  describe "results with atom modifier," do
    test "greets the world", do: assert(~u"hello world"a === [:hello, :world])
    test "ignores extra spaces", do: assert(~u"hello  world"a === [:hello, :world])
    test "ignores newlines", do: assert(~u"hello
      world"a === [:hello, :world])
    test "trims spaces", do: assert(~u" hello  world  "a === [:hello, :world])
    test "trims newlines", do: assert(~u"
      hello
      world
    "a === [:hello, :world])
  end

  describe "raising with default modifier," do
    test "raises at compile time on duplicate words" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: hello", fn ->
        import UniqueWordsSigil
        ~u" hello  hello  "
      end)
    end

    test "raises at compile time on duplicate words with newlines" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        hi world
        "
      end)
    end

    test "raises at compile time on duplicate words with interpolations" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "
      end)
    end
  end

  describe "raising with string modifier," do
    test "raises on duplicate words" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: hello", fn ->
        import UniqueWordsSigil
        ~u" hello  hello  "s
      end)
    end

    test "raises on duplicate words with newlines" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        hi world
        "s
      end)
    end

    test "raises on duplicate words with interpolations" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "s
      end)
    end
  end

  describe "raising with list modifier," do
    test "raises on duplicate words" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: hello", fn ->
        import UniqueWordsSigil
        ~u" hello  hello  "l
      end)
    end

    test "raises on duplicate words with newlines" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        hi world
        "l
      end)
    end

    test "raises on duplicate words with interpolations" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "l
      end)
    end
  end

  describe "raising with charlist modifier," do
    test "raises on duplicate words" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: hello", fn ->
        import UniqueWordsSigil
        ~u" hello  hello  "c
      end)
    end

    test "raises on duplicate words with newlines" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        hi world
        "c
      end)
    end

    test "raises on duplicate words with interpolations" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "c
      end)
    end
  end

  describe "raising with atom modifier," do
    test "raises on duplicate words" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: hello", fn ->
        import UniqueWordsSigil
        ~u" hello  hello  "a
      end)
    end

    test "raises on duplicate words with newlines" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        hi world
        "a
      end)
    end

    test "raises on duplicate words with interpolations" do
      assert_compile_time_raise(ArgumentError, "Duplicate word: world", fn ->
        import UniqueWordsSigil
        ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "a
      end)
    end
  end

  describe "warnings with default modifier," do
    test "warns at compile time on duplicate words" do
      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "w === "hello hello"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "w === "hello hello"
      end)
    end

    test "warns at compile time on duplicate words with newlines" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "w === "hello world hi world"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "w === "hello world hi world"
      end)
    end

    test "warns at compile time on duplicate words with interpolations" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "w === "hello world hello there hi world"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "w === "hello world hello there hi world"
      end)
    end

    test "doesn't warn at all by default when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "w === "hello world hello there hi"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "w === "hello world hello there hi"
      end)
    end

    test "does warn at run time with 'i' when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wi === "hello world hello there hi"
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iw === "hello world hello there hi"
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wi === "hello world hello there hi"
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iw === "hello world hello there hi"
      end)
    end
  end

  describe "warnings with string modifier," do
    test "warns at compile time on duplicate words" do
      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "sw === "hello hello"
      end)

      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "ws === "hello hello"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "sw === "hello hello"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "ws === "hello hello"
      end)
    end

    test "warns at compile time on duplicate words with newlines" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "sw === "hello world hi world"
      end)

      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "ws === "hello world hi world"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "sw === "hello world hi world"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "ws === "hello world hi world"
      end)
    end

    test "warns at compile time on duplicate words with interpolations" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "sw === "hello world hello there hi world"
      end)

      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "ws === "hello world hello there hi world"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "sw === "hello world hello there hi world"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "ws === "hello world hello there hi world"
      end)
    end

    test "doesn't warn at all by default when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "sw === "hello world hello there hi"
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "ws === "hello world hello there hi"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "sw === "hello world hello there hi"
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "ws === "hello world hello there hi"
      end)
    end

    test "does warn at run time with 'i' when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "swi === "hello world hello there hi"
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wis === "hello world hello there hi"
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "isw === "hello world hello there hi"
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iws === "hello world hello there hi"
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wsi === "hello world hello there hi"
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "siw === "hello world hello there hi"
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "swi === "hello world hello there hi"
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wis === "hello world hello there hi"
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "isw === "hello world hello there hi"
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iws === "hello world hello there hi"
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wsi === "hello world hello there hi"
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "siw === "hello world hello there hi"
      end)
    end
  end

  describe "warnings with list modifier," do
    test "warns at compile time on duplicate words" do
      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "lw === ["hello", "hello"]
      end)

      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "wl === ["hello", "hello"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "lw === ["hello", "hello"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "wl === ["hello", "hello"]
      end)
    end

    test "warns at compile time on duplicate words with newlines" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "lw === ["hello", "world", "hi", "world"]
      end)

      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "wl === ["hello", "world", "hi", "world"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "lw === ["hello", "world", "hi", "world"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "wl === ["hello", "world", "hi", "world"]
      end)
    end

    test "warns at compile time on duplicate words with interpolations" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "lw === ["hello", "world", "hello", "there", "hi", "world"]
      end)

      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "wl === ["hello", "world", "hello", "there", "hi", "world"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "lw === ["hello", "world", "hello", "there", "hi", "world"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "wl === ["hello", "world", "hello", "there", "hi", "world"]
      end)
    end

    test "doesn't warn at all by default when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "lw === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wl === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "lw === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wl === ["hello", "world", "hello", "there", "hi"]
      end)
    end

    test "does warn at run time with 'i' when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "lwi === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wil === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "ilw === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iwl === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wli === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "liw === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "lwi === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wil === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "ilw === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iwl === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wli === ["hello", "world", "hello", "there", "hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "liw === ["hello", "world", "hello", "there", "hi"]
      end)
    end
  end

  describe "warnings with charlist modifier," do
    test "warns at compile time on duplicate words" do
      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "cw === [~c"hello", ~c"hello"]
      end)

      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "wc === [~c"hello", ~c"hello"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "cw === [~c"hello", ~c"hello"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "wc === [~c"hello", ~c"hello"]
      end)
    end

    test "warns at compile time on duplicate words with newcines" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "cw === [~c"hello", ~c"world", ~c"hi", ~c"world"]
      end)

      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "wc === [~c"hello", ~c"world", ~c"hi", ~c"world"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "cw === [~c"hello", ~c"world", ~c"hi", ~c"world"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "wc === [~c"hello", ~c"world", ~c"hi", ~c"world"]
      end)
    end

    test "warns at compile time on duplicate words with interpolations" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "cw === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi", ~c"world"]
      end)

      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "wc === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi", ~c"world"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "cw === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi", ~c"world"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "wc === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi", ~c"world"]
      end)
    end

    test "doesn't warn at all by default when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "cw === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wc === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "cw === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wc === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)
    end

    test "does warn at run time with 'i' when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "cwi === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wic === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "icw === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iwc === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wci === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "ciw === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "cwi === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wic === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "icw === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iwc === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wci === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "ciw === [~c"hello", ~c"world", ~c"hello", ~c"there", ~c"hi"]
      end)
    end
  end

  describe "warnings with atom modifier," do
    test "warns at compile time on duplicate words" do
      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "aw === [:hello, :hello]
      end)

      assert_compile_time_io("Duplicate word: hello\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  hello  "wa === [:hello, :hello]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "aw === [:hello, :hello]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  hello  "wa === [:hello, :hello]
      end)
    end

    test "warns at compile time on duplicate words with newaines" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "aw === [:hello, :world, :hi, :world]
      end)

      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        hi world
        "wa === [:hello, :world, :hi, :world]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "aw === [:hello, :world, :hi, :world]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        hi world
        "wa === [:hello, :world, :hi, :world]
      end)
    end

    test "warns at compile time on duplicate words with interpolations" do
      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "aw === [:hello, :world, :hello, :there, :hi, :world]
      end)

      assert_compile_time_io("Duplicate word: world\n", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "wa === [:hello, :world, :hello, :there, :hi, :world]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "aw === [:hello, :world, :hello, :there, :hi, :world]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi world
        "wa === [:hello, :world, :hello, :there, :hi, :world]
      end)
    end

    test "doesn't warn at all by default when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "aw === [:hello, :world, :hello, :there, :hi]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wa === [:hello, :world, :hello, :there, :hi]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "aw === [:hello, :world, :hello, :there, :hi]
      end)

      assert_run_time_io("", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wa === [:hello, :world, :hello, :there, :hi]
      end)
    end

    test "does warn at run time with 'i' when interpolations contain duplicates" do
      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "awi === [:hello, :world, :hello, :there, :hi]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wia === [:hello, :world, :hello, :there, :hi]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iaw === [:hello, :world, :hello, :there, :hi]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iwa === [:hello, :world, :hello, :there, :hi]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wai === [:hello, :world, :hello, :there, :hi]
      end)

      assert_compile_time_io("", fn ->
        use ExUnit.Case
        import UniqueWordsSigil

        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "aiw === [:hello, :world, :hello, :there, :hi]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "awi === [:hello, :world, :hello, :there, :hi]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wia === [:hello, :world, :hello, :there, :hi]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iaw === [:hello, :world, :hello, :there, :hi]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "iwa === [:hello, :world, :hello, :there, :hi]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "wai === [:hello, :world, :hello, :there, :hi]
      end)

      assert_run_time_io("Duplicate word: hello\n", fn ->
        assert ~u" hello  world
        #{"hello " <> "there"}
        hi
        "aiw === [:hello, :world, :hello, :there, :hi]
      end)
    end
  end
end
