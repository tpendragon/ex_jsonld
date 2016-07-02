require IEx
defmodule ExJSONLD.Compactor do
  def compact([jsonld], contexts), do: compact(jsonld, contexts)
  def compact(jsonld = [_ | _], contexts), do: Enum.map(jsonld, &compact(&1, contexts))
  def compact(jsonld, context = %{"@context" => (contexts = %{})}) do
    compact(jsonld, contexts)
    |> Map.merge(context)
    |> compact
  end
  def compact(jsonld, contexts) do
    jsonld
      |> Enum.map(&replace_terms(&1, contexts))
      |> Enum.into(%{})
      |> Map.drop([nil])
  end

  def compact(map) when map_size(map) == 1, do: %{}
  def compact(map = %{"@id" => _}) when map_size(map) == 2, do: %{}
  def compact(map), do: map

  defp replace_terms(term = %{}, contexts = %{}) do
    compact(term, contexts)
  end
  defp replace_terms({key, value}, contexts = %{}) do
    transform = find_transform(key, contexts)
    {key_transform(key, transform), value_transform(value, transform, contexts)}
    |> cleanup
  end
  defp key_transform("@id", _), do: "@id"
  defp key_transform("@type", _), do: "@type"
  defp key_transform("@language", _), do: "@language"
  defp key_transform("@value", _), do: "@value"
  defp key_transform("@list", _), do: "@list"
  defp key_transform("@set", _), do: "@set"
  defp key_transform(term, {key, value}) when term == value, do: key
  defp key_transform(term, {key, %{"@id" => id}}) when term == id, do: key
  defp key_transform(term = "http" <> _, _), do: term
  defp key_transform(_, {nil, nil}), do: nil
  defp key_transform(_, _), do: nil

  defp find_transform(key, contexts = %{}) do
    contexts
    |> Enum.find({nil, nil}, &find_transform(key, &1))
  end
  defp find_transform(term, {_key, value}) when value == term, do: true
  defp find_transform(term, {_key, %{"@id" => id}}) when id == term do
    true
  end
  defp find_transform(_, _), do: false

  defp value_transform([nil], transform, contexts) do
    value_transform([], transform, contexts)
  end
  defp value_transform([value], transform, contexts) do
    value_transform(value, transform, contexts)
  end
  defp value_transform(value, {_, %{"@container" => "@set"}}, _contexts) do
    set_transform(value)
  end
  defp value_transform(value, {_, %{"@container" => "@list"}}, _contexts) do
    set_transform(value)
  end
  defp value_transform(value, _transform, contexts) do
    value_transform(value, contexts)
  end
  defp value_transform(%{"@set" => list}, _), do: set_transform(list)
  defp value_transform(%{"@list" => list}, _) do
    %{"@list" => set_transform(list)}
  end
  defp value_transform(value = %{}, contexts = %{}) do
    compact(value, contexts)
  end
  defp value_transform(value, contexts = %{}) do
    value_transform = find_transform(value, contexts)
    value_transform(value, value_transform)
  end
  defp value_transform(value, {key, transform_value}) 
    when value == transform_value do
      key
    end
  defp value_transform(value, _), do: value

  defp set_transform([]), do: []
  defp set_transform([nil]), do: []
  defp set_transform([nil | rest]), do: set_transform(rest)
  defp set_transform(%{"@list" => list}), do: list
  defp set_transform(%{"@set" => list}), do: list
  defp set_transform(value), do: [value]

  defp cleanup({_, nil}), do: {nil, nil}
  defp cleanup(term), do: term
end
