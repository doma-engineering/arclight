defmodule Arclight.PlugReact do
  @moduledoc """
  A create-react-app compatible plug which routes /static/js and /static/css to APP/priv/static/build/{js,css}.
  Include it in your plug "pipeline", don't call it manually.

  This router expects only one option: :app, it will adapt it then to whichever options Plug.Static expects.
  """

  @behaviour Plug

  @impl true
  def init([app: app]) do
    [from: {app, "priv/ui/build/"}, at: "/"]
  end

  @impl true
  def call(conn, opts) do
    Plug.Static.call(conn, Plug.Static.init(opts))
  end
end
