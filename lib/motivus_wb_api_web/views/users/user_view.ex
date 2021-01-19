defmodule MotivusWbApiWeb.Users.UserView do
  use MotivusWbApiWeb, :view
  alias MotivusWbApiWeb.Users.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      mail: user.mail,
      avatar: user.avatar,
      provider: user.provider,
      uuid: user.uuid,
      is_guest: user.is_guest,
      last_sign_in: user.last_sign_in}
  end
end
