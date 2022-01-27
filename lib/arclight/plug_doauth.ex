defmodule DoAuth.Plug do
  @moduledoc """
  Part of the pipeline that ensures that the client submits a presentation of a
  valid invite fulfillment along with a payload, encoded in credentialSubject.
  """
  use Plug.Builder

  # alias DoAuth.Credential
  alias Uptight.Result

  import DoAuth.Crypto, only: [verify_map: 1, urlsafe_server_pk: 0]
  import Result, only: [cont: 2, cont_end: 1]

  plug(Web.ExtractJsonBody)
  plug(:auth)

  @spec auth(Plug.Conn.t(), keyword) :: Plug.Conn.t()
  def auth(conn, _) do
    presentation = Map.get(conn.assigns, :json_body, %{})
    fulfillment = Map.get(presentation, "verifiableCredential", %{})
    payload = Map.get(presentation, "credentialSubject", %{})

    case verify_map(presentation)
         |> cont(fn _ -> verify_map(fulfillment) end)
         |> cont(fn _ -> is_presenter_the_holder(presentation, fulfillment) end)
         |> cont(fn _ -> is_fulfillment_legit(fulfillment) end)
         |> cont(fn _ -> is_payload_legit(payload) end)
         |> cont_end() do
      %Result.Ok{} = _x ->
        conn |> Plug.Conn.assign(:authenticated_payload, payload)

      %Result.Err{err: err} ->
        fin(conn, Jason.encode!(err))
    end
  end

  defp is_payload_legit(payload) when payload == %{} do
    Result.Ok.new()
  end

  defp is_payload_legit(payload) do
    verify_map(payload)
  end

  defp is_presenter_the_holder(presentation, fulfillment) do
    Result.new(fn ->
      true = presentation["issuer"] == fulfillment["credentialSubject"]["holder"]
    end)
  end

  defp is_fulfillment_legit(fulfillment) do
    Result.new(fn ->
      issuer = fulfillment["issuer"]
      server_pk = urlsafe_server_pk().encoded
      true = server_pk == issuer
      credential_kind = fulfillment["credentialSubject"]["kind"]
      true = "fulfill" == credential_kind
    end)
  end

  defp fin(c, msg) do
    c = send_resp(c, 403, msg)
    halt(c)
  end
end
