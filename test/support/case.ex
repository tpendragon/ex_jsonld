defmodule ExJSONLD.Case do
  use ExUnit.CaseTemplate
  using do
    quote do
      import ExJSONLD.TestHelpers
    end
  end
end
