defmodule Arclight.TofuTest do
  # credo:disable-for-this-file
  use Plug.Test
  use ExUnit.Case, async: true

  alias Uptight.Result

  alias Arclight.RouterPublic, as: Router

  alias DoAuth.Crypto

  describe "TOFU endpoint" do
    test "works" do
      {200, _, _} = get("/tofu")
    end

    test "returns a credential that has the PK" do
      {_, _, res} = get("/tofu")
      %{public: pk} = Crypto.server_keypair64()
      me = res |> Jason.decode!() |> Map.get("credentialSubject") |> Map.get("me")
      assert me == pk
    end

    test "returns a valid credential" do
      {_, _, res} = get("/tofu")
      cred_map = res |> Jason.decode!()
      assert Crypto.verify_map(cred_map) |> Result.is_ok?()
    end
  end

  defp get(e), do: conn(:get, e) |> Router.call([]) |> Plug.Test.sent_resp()
end
