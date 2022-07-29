# defmodule MotivusWbApiWeb.ApplicationTokenController do
#   use MotivusWbApiWeb, :controller

#   alias MotivusWbApi.Users
#   alias MotivusWbApi.Users.ApplicationToken

#   action_fallback MotivusWbApiWeb.FallbackController

#   def index(conn, params) do
#     application_tokens = Users.list_application_tokens(params["user_id"])
#     render(conn, "index.json", application_tokens: application_tokens)
#   end

#   def create(conn, %{"application_token" => application_token_params, "user_id" => user_id}) do
#     with {:ok, %ApplicationToken{} = application_token} <-
#            Users.create_application_token(
#              application_token_params
#              |> Map.put_new("user_id", user_id)
#            ) do
#       conn
#       |> put_status(:created)
#       |> put_resp_header(
#         "location",
#         Routes.users_user_application_token_path(conn, :show, user_id, application_token)
#       )
#       |> render("show.json", application_token: application_token)
#     end
#   end

#   def show(conn, %{"id" => id, "user_id" => user_id}) do
#     application_token = Users.get_application_token!(user_id, id)
#     render(conn, "show.json", application_token: application_token)
#   end

#   def update(conn, %{
#         "id" => id,
#         "application_token" => application_token_params,
#         "user_id" => user_id
#       }) do
#     application_token = Users.get_application_token!(user_id, id)

#     with {:ok, %ApplicationToken{} = application_token} <-
#            Users.update_application_token(application_token, application_token_params) do
#       render(conn, "show.json", application_token: application_token)
#     end
#   end

#   def delete(conn, %{"id" => id, "user_id" => user_id}) do
#     application_token = Users.get_application_token!(user_id, id)

#     with {:ok, %ApplicationToken{}} <- Users.delete_application_token(application_token) do
#       send_resp(conn, :no_content, "")
#     end
#   end
# end
