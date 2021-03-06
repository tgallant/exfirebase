Code.require_file "test_helper.exs", __DIR__

defmodule ExFirebase.DictTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock
  alias ExFirebase.Dict

  setup_all do
    ExFirebase.set_url("https://example-test.firebaseio.com/")
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  @dict1 Enum.into([{"-J29m_688gi0nqXtK5sr", %{"a" => "1", "b" => "2"}}], HashDict.new)

  test "get single posted object" do
    use_cassette "get_objects", custom: true do
      assert(Dict.get("objects") == @dict1)
    end
  end

  test "post object" do
    use_cassette "get_objects_post", custom: true do
      assert(Dict.post("objects_post", [{"a","1"}, {"b", "2"}]) == {"-J29m_688gi0nqXtK5sr", [{"a", "1"}, {"b", "2"}]})
    end
  end

  test "update posted object" do
    use_cassette "get_objects_post_patch", custom: true do
      assert(Dict.patch("objects", "-J30m_688gi0nqXtK5sr", [{"c","3"}, {"d", "4"}]) == {"-J30m_688gi0nqXtK5sr", [{"c","3"}, {"d", "4"}]})
    end
  end

  test "delete posted object" do
    use_cassette "get_objects_post_delete", custom: true do
      assert(Dict.delete("objects", "-J31m_688gi0nqXtK5sr") == [])
    end
  end
end

defmodule ExFirebase.Dict.RecordsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock
  alias ExFirebase.Dict
  import ExFirebase.Records
  import ExFirebase.Dict.Records

  defmodule NoIdDummy do
    defstruct a: nil, b: nil, c: nil, d: nil
  end
  defmodule Dummy do
    defstruct id: nil, a: nil, b: nil, c: nil, d: nil
  end

  setup_all do
    ExFirebase.set_url("https://example-test.firebaseio.com/")
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "get records" do
    use_cassette "get_objects", custom: true do
      assert(Dict.Records.get("objects", Dummy) == [%Dummy{id: "-J29m_688gi0nqXtK5sr", a: "1", b: "2"}])
    end
  end

  test "get a record" do
    use_cassette "get_objects3", custom: true do
      assert(Dict.Records.get("objects", "-J29m_688gi0nqXtK5sr", Dummy) ==
        %Dummy{id: "-J29m_688gi0nqXtK5sr", a: "1", b: "2"}
      )
    end
  end

  test "post a record" do
    use_cassette "get_objects_post", custom: true do
      assert(Dict.Records.post("objects_post", %Dummy{a: "1", b: "2"}) ==
               %Dummy{id: "-J29m_688gi0nqXtK5sr", a: "1", b: "2"})
    end
  end

  test "update a record" do
    use_cassette "get_objects_post_patch", custom: true do
      rec = %Dummy{id: "-J30m_688gi0nqXtK5sr", c: "3", d: "4"}
      assert(Dict.Records.patch("objects", rec) == rec)
    end
  end

  test "delete a record" do
    use_cassette "get_objects_post_delete", custom: true do
      assert(Dict.Records.delete("objects", %Dummy{id: "-J31m_688gi0nqXtK5sr", c: "3", d: "4"}) == [])
    end
  end

  test "get records dict without id field throws error" do
    assert_raise RuntimeError, fn ->
      use_cassette "get_objects", custom: true do
        Dict.Records.get("objects", NoIdDummy)
      end
    end
  end

  test "updating a record with nil id throws error" do
    assert_raise RuntimeError, fn ->
      use_cassette "get_objects_post_patch", custom: true do
        Dict.Records.patch("objects", %Dummy{id: nil, c: "3", d: "4"})
      end
    end
  end
end
