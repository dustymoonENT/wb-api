defmodule MotivusWbApiWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use MotivusWbApiWeb, :controller
  plug(Ueberauth)

  alias MotivusWbApi.Users.Guardian
  alias MotivusWbApi.Users

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

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(%{id: user.id}, %{})
        |> send_token(params)

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def send_token(conn, _params) do
    token = Guardian.Plug.current_token(conn)

    conn
    |> fetch_session()
    |> fetch_flash()
    |> Phoenix.Controller.render("success.html", %{
      token: token,
      origin: Application.get_env(:motivus_wb_api, :spa_origin),
      origin2: Application.get_env(:motivus_wb_api, :spa_alias_origin)
    })
  end

  def create_guest(conn, _params) do
    {:ok, user} =
      Users.create_user(%{
        uuid: Ecto.UUID.bingenerate(),
        is_guest: true,
        name: "guest",
        mail: nil,
        last_sign_in: DateTime.utc_now(),
        is_trusted_worker: false
      })

    token =
      conn
      |> Guardian.Plug.sign_in(%{id: user.id}, %{})
      |> Guardian.Plug.current_token()

    json(conn, %{"token" => token})
  end
end
