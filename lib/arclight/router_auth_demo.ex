defmodule Arclight.RouterAuthDemo do
  @moduledoc """
  An example router, demonstrating the power of DoAuth subsystem.
  """
  use Plug.Router

  plug(:match)
  plug(DoAuth.Plug)
  # ^ Yields :authenticated_payload assign
  plug(:dispatch)

  # v This stuff will only work if the user making a request has passed authentication. (See invite_test for a reference).
  post "/" do
    send_resp(conn, 200, "Welcome to DoAuth")
  end

  post "/echo" do
    Plug.run(conn, [{Arclight.Echo, []}])
  end
end
