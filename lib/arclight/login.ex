defmodule Arclight.Login do
  @moduledoc """
  A login counterpart of the simple DoAuth AAA system.
  Expects JSON body to be extracted, doesn't require captcha.
  """

  use Plug.Builder

  alias DoAuth.Crypto

  alias Uptight.Result
  alias Uptight.Base, as: B

  import DynHacks, only: [r_m: 2]

  plug(Web.ExtractJsonBody)
  plug(:login)

  @spec login(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def login(conn, _opts) do
    case Result.new(fn ->
           cred = conn.assigns[:json_body]["credential"]
           vpk = cred["proof"]["verificationMethod"]
           me = cred["credentialSubject"]["me"]

           %{"me field is set" => true} = %{
             "me field is set" => not is_nil(me)
           }

           %{"me field matches verificationMethod" => true} = %{
             "me field matches verificationMethod" => me == vpk
           }

           %{"credential is valid" => %Result.Ok{}} = %{
             "credential is valid" => Crypto.verify_map(cred)
           }

           r_m(
             DoAuth.Invite.lookup(vpk |> B.mk_url!()),
             &(%{"PK is registered" => true} = %{"PK is registered" => not is_nil(&1)})
           )
         end) do
      %Result.Ok{ok: invite} ->
        send_resp(conn, 200, invite |> Jason.encode!())

      %Result.Err{err: err} ->
        send_resp(conn, 404, %{error: "Login failed", details: err} |> Jason.encode!())
        |> halt()
    end
  end
end
