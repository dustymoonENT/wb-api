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
alias MotivusWbApi.Processing
alias MotivusWbApi.Ranking
alias MotivusWbApi.Repo
require Ecto.Query

find_or_create_trusted_worker = fn email, name ->
  Users.User
  |> Ecto.Query.where(mail: ^email)
  |> Repo.one()
  |> case do
    nil ->
      {:ok, user} =
        Users.create_user(%{
          mail: email,
          is_trusted_worker: true,
          name: name,
          is_guest: false,
          uuid: UUID.uuid4()
        })

      user

    user ->
      user
  end
end

long_lived_token = fn user ->
  {:ok, token, _} = MotivusWbApi.Users.Guardian.encode_and_sign(user, %{}, ttl: {30 * 365, :day})
  %{user: user, token: token}
end

print_user_token = fn %{user: user, token: token} -> IO.inspect(token, label: user.name) end

if Mix.env() in [:prod] do
  trusted_workers = [
    {"gcp@motivus.cl", "Google Cloud Platform workers"},
    {"azure@motivus.cl", "Azure workers"},
    {"oci@motivus.cl", "Oracle Cloud Infrastructure workers"},
    {"aws@motivus.cl", "Amazon Web Services workers"}
  ]

  Enum.map(trusted_workers, fn {mail, name} ->
    find_or_create_trusted_worker.(mail, name)
    |> long_lived_token.()
    |> print_user_token.()
  end)
end

if Mix.env() in [:dev] do
  {:ok, user1} =
    Users.create_user(%{
      name: "guest",
      mail: nil,
      is_guest: true,
      uuid: "076c6703-0d9c-422e-971c-dfc482785229"
    })

  {:ok, user2} =
    Users.create_user(%{
      name: "guest",
      mail: nil,
      is_guest: true,
      uuid: "076c6703-0d9c-422e-971c-dfc482785230"
    })

  {:ok, user3} =
    Users.create_user(%{
      name: "guest",
      mail: nil,
      is_guest: true,
      uuid: "076c6703-0d9c-422e-971c-dfc482785231"
    })

  {:ok, user4} =
    Users.create_user(%{
      name: "guest",
      mail: nil,
      is_guest: true,
      uuid: "076c6703-0d9c-422e-971c-dfc482785232"
    })

  {:ok, task1} =
    Processing.create_task(%{
      attempts: 1,
      date_in: "2021-02-09T14:00:00Z",
      date_last_dispatch: "2021-02-09T14:20:00Z",
      date_out: "2021-02-09T14:30:00Z",
      flops: 120.5,
      params: %{},
      processing_base_time: 240,
      type: "some type",
      user_id: user1.id,
      flop: 10.0,
      result: %{},
      is_valid: true,
      application_token_id: nil
    })

  {:ok, task2} =
    Processing.create_task(%{
      attempts: 1,
      date_in: "2021-02-09T14:00:00Z",
      date_last_dispatch: "2021-02-09T14:20:00Z",
      date_out: "2021-02-09T14:30:00Z",
      flops: 120.5,
      params: %{},
      processing_base_time: 240,
      type: "some type",
      user_id: user1.id,
      flop: 10.0,
      result: %{},
      is_valid: true,
      application_token_id: nil
    })

  {:ok, task3} =
    Processing.create_task(%{
      attempts: 1,
      date_in: "2021-02-09T14:00:00Z",
      date_last_dispatch: "2021-02-09T14:20:00Z",
      date_out: "2021-02-09T14:30:00Z",
      flops: 120.5,
      params: %{},
      processing_base_time: 240,
      type: "some type",
      user_id: user1.id,
      flop: 10.0,
      result: %{},
      is_valid: true,
      application_token_id: nil
    })

  {:ok, task4} =
    Processing.create_task(%{
      attempts: 1,
      date_in: "2021-02-09T14:00:00Z",
      date_last_dispatch: "2021-02-09T14:20:00Z",
      date_out: "2021-02-09T14:30:00Z",
      flops: 120.5,
      params: %{},
      processing_base_time: 240,
      type: "some type",
      user_id: user2.id,
      flop: 10.0,
      result: %{},
      is_valid: true,
      application_token_id: nil
    })

  {:ok, task5} =
    Processing.create_task(%{
      attempts: 1,
      date_in: "2021-02-09T14:00:00Z",
      date_last_dispatch: "2021-02-09T14:20:00Z",
      date_out: "2021-02-09T14:30:00Z",
      flops: 120.5,
      params: %{},
      processing_base_time: 240,
      type: "some type",
      user_id: user2.id,
      flop: 10.0,
      result: %{},
      is_valid: true,
      application_token_id: nil
    })

  {:ok, season1} =
    Ranking.create_season(%{
      end_date: "2021-02-05T14:00:00Z",
      name: "Season 1",
      start_date: "2021-01-28T14:00:00Z"
    })

  {:ok, season2} =
    Ranking.create_season(%{
      end_date: "2021-02-15T14:00:00Z",
      name: "Season 2",
      start_date: "2021-02-06T14:00:00Z"
    })
end
