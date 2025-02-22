ExUnit.start(trace: true)
ExUnit.configure(colors: [enabled: true])

defmodule Assertions do
  @moduledoc """
  Sources & references for this module:
  https://elixirforum.com/t/testing-macro-exception/7105/2
  https://github.com/OvermindDL1/typed_elixir/blob/master/test/test_helper.ex
  """
  use ExUnit.Case

  import ExUnit.CaptureIO

  defmodule DidNotRaise, do: defstruct(message: nil)

  defmacro assert_compile_time_raise(expected_exception, expected_message, func) do
    actual_exception =
      try do
        Code.eval_quoted(func)
        %DidNotRaise{}
      rescue
        e -> e
      end

    quote do
      assert unquote(actual_exception.__struct__) === unquote(expected_exception)
      assert unquote(actual_exception.message) === unquote(expected_message)
    end
  end

  defmacro assert_compile_time_io(expected_io, func) do
    actual_io = capture_io(fn -> Code.eval_quoted(func) end)

    quote do
      assert unquote(actual_io) === unquote(expected_io)
    end
  end

  def assert_run_time_io(expected_io, func) do
    actual_io = capture_io(func)
    assert actual_io === expected_io
  end
end
