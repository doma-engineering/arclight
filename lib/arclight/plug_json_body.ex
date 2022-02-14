defmodule Arclight.PlugJsonBody do
  @moduledoc """
  Plug to extract json in POST body into :json_body assign.
  """
  use Plug.Builder

  plug(:extract_json_body)

  @spec extract_json_body(Plug.Conn.t(), keyword) :: Plug.Conn.t()
  def extract_json_body(conn, opts) do
    case get_body(conn, opts) do
      {:body_params, ex_map} ->
          Plug.Conn.assign(conn, :json_body, ex_map)
      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok, ex_map} ->
            Plug.Conn.assign(conn, :json_body, ex_map)

          _ ->
            fin(conn, "JSON required")
        end

      _ ->
        fin(conn, "POST with complete JSON expected")
    end
  end

  defp get_body(conn, _opts) do
    # Sorry for shitty defensive code, but this bit of Plugs is a bit ad hoc,
    # so I just write the same thing several times to make sure I won't crash
    # out like  I did a couple of times.
    if Map.get(conn, :body_params) do
      fetch_if_unfetched_and_return_body_params(conn.body_params, conn)
    else
      Plug.Conn.read_body(conn)
    end
  end

  defp fetch_if_unfetched_and_return_body_params(%Plug.Conn.Unfetched{} = _, conn) do
    Plug.Conn.read_body(conn)
  end
  defp fetch_if_unfetched_and_return_body_params(body_params, _conn) do
    {:body_params, body_params}
  end

  defp fin(c, msg) do
    c = send_resp(c, 403, msg)
    halt(c)
  end
end
