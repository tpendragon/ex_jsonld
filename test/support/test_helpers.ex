defmodule ExJSONLD.TestHelpers do
  def load_fixture(fixture_name) do
    {:ok, content} = File.read("test/fixtures/#{fixture_name}")
    content
  end

  def load_json_fixture(fixture_name) do
    fixture_name
      |> load_fixture
      |> Poison.decode!
  end

  def load_compact_test(number) do
    {
      load_json_fixture("compaction/compact-#{number}-in.jsonld"),
      load_json_fixture("compaction/compact-#{number}-context.jsonld"),
      load_json_fixture("compaction/compact-#{number}-out.jsonld")
    }
  end
end
