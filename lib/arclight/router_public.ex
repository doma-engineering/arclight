defmodule Arclight.RouterPublic do
  @moduledoc """
  Default public Arclight router. Ready to be the target of your forwards.
  """

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  # Trust on first use endpoint.
  # https://en.wikipedia.org/wiki/Trust_on_first_use
  # relevant:
  # https://drewdevault.com/2020/09/21/Gemini-TOFU.html
  get "/tofu" do
    Plug.run(conn, [&Arclight.Tofu.whoami/1])
  end

  post "/register" do
    Plug.run(conn, [{Arclight.PlugCaptcha, []}, {Arclight.Register, []}])
  end

  post "/login" do
    Plug.run(conn, [{Arclight.Login, []}])
  end
end
