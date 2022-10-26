defmodule Recode.Task.MultiLinePipesTest do
  use RecodeCase

  alias Recode.Task.MultiLinePipes

  defp run(code, opts \\ []) do
    code
    |> source()
    |> run_task({MultiLinePipes, opts})
  end

  test "multiple pipes in single line" do
    code = """
    value |> func_1() |> func_2()
    """

    expected = """
    value
    |> func_1()
    |> func_2()
    """

    assert run(code).code == expected
  end

  test "multiple pipes in multiple lines" do
    code = """
    value
    |> func_1()
    |> func_2()
    """

    expected = """
    value
    |> func_1()
    |> func_2()
    """

    assert run(code).code == expected
  end

  test "single pipe in single line" do
    code = """
    value |> func_1()
    """

    expected = """
    value |> func_1()
    """

    assert run(code).code == expected
  end

  test "single pipe in multiple lines" do
    code = """
    value
    |> func_1()
    """

    expected = """
    value
    |> func_1()
    """

    assert run(code).code == expected
  end
end
