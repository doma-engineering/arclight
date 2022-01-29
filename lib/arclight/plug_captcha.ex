defmodule Arclight.PlugCaptcha do
  @moduledoc """
  Plug to validate captcha.
  """

  use Plug.Builder

  alias Uptight.Result
  alias Uptight.Result.{Ok, Err}

  use Witchcraft.Functor

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
        send_resp(conn, 403, recapthca_error_to_json(e) |> Jason.encode!()) |> halt()
    end
  end

  defp recapthca_error_to_json(e = %Err{err: %{exception: %{term: kvs}}}) do
    %{e | err: %{e.err | exception: %{e.err.exception | term: strip_errors(kvs)}}}
  end

  defp strip_errors(kvs) do
    kvs
    |> map(fn
      {:error, reason} -> reason
      x -> x
    end)
  end
end
