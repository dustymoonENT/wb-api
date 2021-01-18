# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MotivusWbApi.Repo.insert!(%MotivusWbApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
#
alias MotivusWbApi.Users
{:ok, user} = Users.create_user(%{name: "guest", mail: "guest@motivus.cl", is_guest: true, uuid: "076c6703-0d9c-422e-971c-dfc482785229"})
