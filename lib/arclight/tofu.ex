defmodule Arclight.Tofu do
  @moduledoc """
  Web endpoint for a DoAuth server to introduce itself.
  """
  import Plug.Conn

  alias DoAuth.Credential
  alias DoAuth.Crypto

  @spec whoami(Plug.Conn.t()) :: Plug.Conn.t()
  def whoami(conn) do
    res =
      Credential.transact_with_keypair_from_payload_map!(
        Crypto.server_keypair(),
        %{
          "me" => Crypto.server_keypair64() |> Map.get(:public)
        },
        persist: true
      )

    send_resp(conn, 200, res |> Jason.encode!())
  end
end
