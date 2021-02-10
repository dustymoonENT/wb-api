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

if Mix.env() in [:dev] do
  {:ok, user1} =
    Users.create_user(
      %{
        name: "guest",
        mail: "guest@motivus.cl",
        is_guest: true,
        uuid: "076c6703-0d9c-422e-971c-dfc482785229"
      }
    )

  {:ok, user2} =
    Users.create_user(
      %{
        name: "guest",
        mail: "guest@motivus.cl",
        is_guest: true,
        uuid: "076c6703-0d9c-422e-971c-dfc482785230"
      }
    )

  {:ok, user3} =
    Users.create_user(
      %{
        name: "guest",
        mail: "guest@motivus.cl",
        is_guest: true,
        uuid: "076c6703-0d9c-422e-971c-dfc482785231"
      }
    )

  {:ok, user4} =
    Users.create_user(
      %{
        name: "guest",
        mail: "guest@motivus.cl",
        is_guest: true,
        uuid: "076c6703-0d9c-422e-971c-dfc482785232"
      }
    )

  {:ok, task1} =
    Processing.create_task(
      %{
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
        is_valid: true
      }
    )

  {:ok, task2} =
    Processing.create_task(
      %{
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
        is_valid: true
      }
    )

  {:ok, task3} =
    Processing.create_task(
      %{
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
        is_valid: true
      }
    )

  {:ok, task4} =
    Processing.create_task(
      %{
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
        is_valid: true
      }
    )

  {:ok, task5} =
    Processing.create_task(
      %{
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
        is_valid: true
      }
    )

  {:ok, season1} =
    Ranking.create_season(
      %{
        end_date: "2021-02-05T14:00:00Z",
        name: "Season 1",
        start_date: "2021-01-28T14:00:00Z"
      }
    )

  {:ok, season2} =
    Ranking.create_season(
      %{
        end_date: "2021-02-15T14:00:00Z",
        name: "Season 2",
        start_date: "2021-02-06T14:00:00Z"
      }
    )
end

# if Mix.env() in [:prod] do
  #{:ok, season_one} =
  #  Ranking.create_season(
  #    %{
#      start_date: "2021-01-28T23:00:00Z"
#      end_date: "2021-02-05T23:00:00Z",
#      name: "Season 1",
  #    }
  #  )
# end
