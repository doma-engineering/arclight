defmodule Arclight.InviteTest do
  @moduledoc """
  Tests of invite logic and that authed endpoints work
  """
  use Plug.Test
  use ExUnit.Case, async: true

  use DoAuth.TestFixtures, [:crypto]
  alias DoAuth.{Invite, Credential}
  alias Uptight.Result
  alias Arclight.RouterAuthDemo, as: Router

  alias Uptight.Base, as: B

  describe "invite system is built such that" do
    test "fulfillments grant access to authenticated API" do
      granted = Invite.grant_root_invite() |> Result.from_ok()
      kp1_bin = signing_key_fixture(Enum.random(5..8))
      kp1 = kp1_bin |> map(&B.safe!/1)
      fulfilled = Invite.fulfill(kp1[:public], granted) |> Result.from_ok()

      payload =
        Credential.present_credential_map!(
          # TODO: Everything should use Base.Urlsafe.t
          kp1_bin,
          fulfilled
        )

      resp = post(payload)

      assert resp.status == 200
      assert resp.resp_body == "Welcome to DoAuth"
    end

    test "filfillment can not be skipped" do
      granted = Invite.grant_root_invite() |> Result.from_ok()
      kp1_bin = signing_key_fixture(13)
      _kp1 = kp1_bin |> map(&B.safe!/1)

      payload =
        Credential.present_credential_map!(
          kp1_bin,
          granted
        )

      resp = post(payload)
      refute resp.status == 200
    end

    test "the server doesn't just accept any valid presentation" do
      kp1_bin = signing_key_fixture(13)
      kp1 = kp1_bin |> map(&B.safe!/1)

      payload =
        Credential.present_credential_map!(
          kp1_bin,
          Credential.mk_credential!(kp1_bin, %{
            "holder" => kp1[:public].encoded,
            "kind" => "fulfill",
            "invite" => "beep",
            "presentation" => "boop"
          })
        )

      resp = post(payload)
      refute resp.status == 200
    end

    # TODO: Move this stuff into a simple test convenience module
    defp post(payload),
      do:
        conn(:post, "/", payload |> Jason.encode!())
        |> put_req_header("content-type", "application/json")
        |> Router.call([])

    ## TODO: Implement "Clubhouse" invite system
    # test "invites can be chained" do
    # end
  end
end
