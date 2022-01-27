defmodule Arclight.PlugCaptcha do
  @moduledoc """
  Plug to validate captcha.
  """

  use Plug.Builder

  alias Uptight.Result

  plug(Arclight.PlugJsonBody)
  plug(:captcha)

  @spec captcha(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def captcha(conn, _opts) do
    case Recaptcha.verify(conn.assigns[:json_body]["captchaToken"]) do
      {:ok, %{challenge_ts: ts, hostname: host}} ->
        # TODO: check for hostname green-list, per configuration
        Plug.Conn.assign(
          conn,
          :captcha,
          Result.new(fn -> %{challenge_ts: ts, hostname: host} end)
        )

      {:error, error} ->
        send_resp(conn, 403, error |> Jason.encode!())
        |> halt()
    end
  end
end
