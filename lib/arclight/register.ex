defmodule Arclight.Register do
  @moduledoc """
  A simple way to register someone's public key with the
  Expects JSON body to be extracted and Captcha to have been passed.
  """

  use Plug.Builder

  alias Uptight.Result
  import Uptight.Result, only: [is_ok?: 1]

  plug(:register)

  @spec register(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def register(conn, _opts) do
    case Result.new(fn ->
           %{"Captcha is ok" => true} = %{"Captcha is ok" => conn.assigns[:captcha]} |> is_ok?()

           %{"`me` field is present in credentialSubject" => false} = %{
             "`me` field is present in credentialSubject" =>
               conn.assigns[:json_body]["credential"]["credentialSubject"]["me"] |> is_nil()
           }

           %{"`name` field is present in credentialSubject" => false} = %{
             "`name` field is present in credentialSubject" =>
               conn.assigns[:json_body]["credential"]["credentialSubject"]["name"] |> is_nil()
           }
         end)
         |> is_ok? do
      true ->
        register_do(conn, conn.assigns[:json_body]["credential"])

      false ->
        send_resp(
          conn,
          403,
          %{error: "Wrong captcha, missing `me` or `name` field."} |> Jason.encode!()
        )
        |> halt()
    end
  end

  defp register_do(conn, credential) do
    case DoAuth.Invite.fulfill_simple(credential) do
      %Result.Ok{ok: fulfillment} ->
        send_resp(
          conn,
          200,
          fulfillment |> Jason.encode!()
        )

      %Result.Err{err: err} ->
        send_resp(
          conn,
          403,
          %{error: "Invalid registration request", details: err} |> Jason.encode!()
        )
    end
  end
end
