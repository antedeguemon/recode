defmodule Recode.Task.MultiLinePipes do
  @moduledoc false
  use Recode.Task, correct: true, check: false

  alias Recode.AST
  alias Recode.Task.MultiLinePipes
  alias Rewrite.Source
  alias Sourceror.Zipper

  @impl Recode.Task
  def run(source, _opts) do
    zipper =
      source
      |> Source.ast()
      |> Zipper.zip()
      |> Zipper.traverse(&traverse/1)

    Source.update(source, MultiLinePipes, ast: Zipper.root(zipper))
  end

  defp traverse({{:|>, map_meta, _ast}, _zipper_meta} = zipper) do
    multiline? = AST.multiline?(map_meta)
    child_node = Zipper.down(zipper)

    case {multiline?, Zipper.node(child_node)} do
      {false, {:|>, _, _}} ->
        Zipper.update(zipper, &to_multi_line(&1, 1))

      {_, _} ->
        zipper
    end
  end

  defp traverse(zipper) do
    zipper
  end

  defp to_multi_line({op, meta, ast}, lines_to_add) do
    current_closing_line = meta[:closing][:line] || meta[:line]
    updated_closing_line = current_closing_line + lines_to_add
    updated_newlines = lines_to_add

    updated_meta =
      meta
      |> Keyword.put(:closing, line: updated_closing_line)
      |> Keyword.put(:newlines, updated_newlines)

    {op, updated_meta, ast}
  end
end
