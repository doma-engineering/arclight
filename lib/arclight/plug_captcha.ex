defmodule Arclight.PlugCaptcha do
  @moduledoc """
  Plug to validate captcha.
  """

  use Plug.Builder

  alias Uptight.Result
  alias Uptight.Result.{Ok, Err}

  plug(:captcha)

  @spec captcha(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def captcha(conn, _opts) do
    case Result.new(fn ->
           %{"Recaptcha is NOT configured" => false} = %{
             "Recaptcha is NOT configured" =>
               Application.get_env(:doma_recaptcha, :secret) |> is_nil
           }

           %{
             "User submitted valid recaptcha" =>
               {:ok, res = %{challenge_ts: _ts, hostname: _host}}
           } = %{
             "User submitted valid recaptcha" =>
               Recaptcha.verify(conn.body_params["captchaToken"])
           }

           res
         end) do
      x = %Ok{} ->
        Plug.Conn.assign(conn, :captcha, x)

      e = %Err{} ->
        send_resp(conn, 403, e |> Jason.encode!()) |> halt()
    end
  end
end
