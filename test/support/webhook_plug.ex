defmodule WebHookPlug do
  @moduledoc false
  import Plug.Conn
  alias Jellyfish.Notifier
  alias Phoenix.PubSub

  @pubsub Jellyfish.PubSub

  def init(opts) do
    # initialize options

    IO.inspect("START WebHookPlug")

    opts
  end

  def call(conn, _opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, [])
    notification = Jason.decode!(body)

    notification =
      if notification == %{} do
        notification
      else
        Notifier.handle_json(notification)
      end

    :ok = PubSub.broadcast(@pubsub, "webhook", notification)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "OK")
  end
end
