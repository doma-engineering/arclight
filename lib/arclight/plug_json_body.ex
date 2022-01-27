defmodule Arclight.PlugJsonBody do
  @moduledoc """
  Plug to extract json in POST body into :json_body assign.
  """
  use Plug.Builder

  plug(:extract_json_body)

  @spec extract_json_body(Plug.Conn.t(), keyword) :: Plug.Conn.t()
  def extract_json_body(conn, opts) do
    case Plug.Conn.read_body(conn, opts) do
      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok, json} ->
            Plug.Conn.assign(conn, :json_body, json)

          _ ->
            fin(conn, "JSON required")
        end

      _ ->
        fin(conn, "POST with complete JSON expected")
    end
  end

  defp fin(c, msg) do
    c = send_resp(c, 403, msg)
    halt(c)
  end
end
