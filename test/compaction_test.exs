require IEx
defmodule CompactionTest do
  use ExJSONLD.Case, async: true

  test "drop free-floating nodes" do
    {jsonld, context, output} = load_compact_test("0001")

    assert ExJSONLD.compact(jsonld, context) == output
  end

  test "basic term and value compaction" do
    {jsonld, context, output} = load_compact_test("0002")

    assert ExJSONLD.compact(jsonld, context) == output
  end

  test "drop null and unmapped properties" do
    {jsonld, context, output} = load_compact_test("0003")

    assert ExJSONLD.compact(jsonld, context) == output
  end

  test "optimize @set, keep empty arrays" do
    {jsonld, context, output} = load_compact_test("0004")

    assert ExJSONLD.compact(jsonld, context) == output
  end

  test "@type and prefix compaction" do
    {jsonld, context, output} = load_compact_test("0005")

    assert ExJSONLD.compact(jsonld, context) == output
  end
end
