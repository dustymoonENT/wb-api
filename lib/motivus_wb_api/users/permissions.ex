defmodule MotivusWbApi.Users.Permissions do
  import Plug.Conn

  defp check_permissions(conn) do
    user = Guardian.Plug.current_resource(conn)

    if(conn.params["user_id"]) do
      if conn.params["user_id"] != nil and user.id == String.to_integer(conn.params["user_id"]) do
        conn
      else
        conn
        |> resp(401, "Unauthorized")
        |> halt()
      end
    else
      conn
    end
  end

  def init(_params), do: {}

  def call(conn, _params) do
    check_permissions(conn)
  end
end
