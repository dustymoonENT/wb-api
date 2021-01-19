defmodule MotivusWbApiWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use MotivusWbApiWeb, :controller
  plug(Ueberauth)

  alias Ueberauth.Strategy.Helpers
  alias MotivusWbApi.Users.Guardian

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    conn
    |> json(%{"error" => fails})
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(%{id: user.id}, %{})
        |> redirect_to_spa()

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  defp redirect_to_spa(conn) do
    token = Guardian.Plug.current_token(conn)

    redirect(conn,
      external: System.get_env("SPA_REDIRECT_URI", "http://motivus.cl/auth") <> "?token=" <> token
    )
  end
end
