defmodule MotivusWbApi.RankingTest do
  use MotivusWbApi.DataCase

  alias MotivusWbApi.Ranking
  alias MotivusWbApi.Users
  alias MotivusWbApi.Users.User
  alias MotivusWbApi.Processing
  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Ranking.CurrentSeasonRanking

  describe "seasons" do
    alias MotivusWbApi.Ranking.Season

    @valid_attrs %{
      end_date: "2010-04-17T14:00:00Z",
      name: "some name",
      start_date: "2010-04-17T14:00:00Z"
    }
    @update_attrs %{
      end_date: "2011-05-18T15:01:01Z",
      name: "some updated name",
      start_date: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{end_date: nil, name: nil, start_date: nil}

    def season_fixture(attrs \\ %{}) do
      {:ok, season} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ranking.create_season()

      season
    end

    test "list_seasons/0 returns all seasons" do
      season = season_fixture()
      assert Ranking.list_seasons() == [season]
    end

    test "get_season!/1 returns the season with given id" do
      season = season_fixture()
      assert Ranking.get_season!(season.id) == season
    end

    test "create_season/1 with valid data creates a season" do
      assert {:ok, %Season{} = season} = Ranking.create_season(@valid_attrs)
      assert season.end_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert season.name == "some name"
      assert season.start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_season/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ranking.create_season(@invalid_attrs)
    end

    test "update_season/2 with valid data updates the season" do
      season = season_fixture()
      assert {:ok, %Season{} = season} = Ranking.update_season(season, @update_attrs)
      assert season.end_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert season.name == "some updated name"
      assert season.start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_season/2 with invalid data returns error changeset" do
      season = season_fixture()
      assert {:error, %Ecto.Changeset{}} = Ranking.update_season(season, @invalid_attrs)
      assert season == Ranking.get_season!(season.id)
    end

    test "delete_season/1 deletes the season" do
      season = season_fixture()
      assert {:ok, %Season{}} = Ranking.delete_season(season)
      assert_raise Ecto.NoResultsError, fn -> Ranking.get_season!(season.id) end
    end

    test "change_season/1 returns a season changeset" do
      season = season_fixture()
      assert %Ecto.Changeset{} = Ranking.change_season(season)
    end

    test "get_current_season/1 " do
      assert {:ok, %Season{} = season} =
               Ranking.create_season(%{
                 end_date: "2010-04-24T14:00:00Z",
                 name: "SEASON_TEST",
                 start_date: "2010-04-17T14:00:00Z"
               })

      date = DateTime.from_naive!(~N[2010-04-20T14:00:00Z], "Etc/UTC")
      season = MotivusWbApi.Stats.get_current_season(date)
      assert season.name == "SEASON_TEST"
    end

    test "get_current_season/1 without season " do
      date = DateTime.from_naive!(~N[2010-04-20T14:00:00Z], "Etc/UTC")
      season = MotivusWbApi.Stats.get_current_season(date)
      assert season == nil
    end

    test "set_ranking/1" do
      assert {:ok, %Season{} = season} =
               Ranking.create_season(%{
                 start_date: "2021-01-28T14:00:00Z",
                 end_date: "2021-02-05T14:00:00Z",
                 name: "SEASON_TEST"
               })

      {:ok, %User{} = user1} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2010-04-17T14:00:00Z",
          mail: nil,
          name: "user1",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      {:ok, application_token} =
        Users.create_application_token(%{
          value: "value",
          description: "description",
          user_id: user1.id
        })

      {:ok, %User{} = user2} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2010-04-17T14:00:00Z",
          mail: nil,
          name: "user2",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      {:ok, %User{}} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2010-04-17T14:00:00Z",
          mail: nil,
          name: "user3",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user1.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user1.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user2.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user2.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user2.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      date = DateTime.from_naive!(~N[2021-02-04T14:00:00Z], "Etc/UTC")
      MotivusWbApi.Stats.set_ranking(date)
      [u1, u2] = Repo.all(from q in CurrentSeasonRanking, order_by: q.user_id)
      assert u1.processing_ranking == 2
      assert u1.elapsed_time_ranking == 2
      assert u2.processing_ranking == 1
      assert u2.elapsed_time_ranking == 1
    end

    test "set_ranking/1 with black_listed users" do
      assert {:ok, %Season{} = season} =
               Ranking.create_season(%{
                 start_date: "2021-01-28T14:00:00Z",
                 end_date: "2021-02-05T14:00:00Z",
                 name: "SEASON_TEST"
               })

      {:ok, %User{} = user1} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2010-04-17T14:00:00Z",
          mail: nil,
          name: "user1",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      {:ok, application_token} =
        Users.create_application_token(%{
          value: "value",
          description: "description",
          user_id: user1.id
        })

      {:ok, %User{} = user2} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2010-04-17T14:00:00Z",
          mail: nil,
          name: "user2",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      {:ok, %User{}} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2010-04-17T14:00:00Z",
          mail: nil,
          name: "user3",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      {:ok, %User{} = user4} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2010-04-17T14:00:00Z",
          mail: nil,
          name: "user4",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662",
          black_listed: true
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user1.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user1.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user2.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user2.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user2.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:00:00Z",
          date_last_dispatch: "2021-01-28T14:00:00Z",
          date_out: "2021-02-01T14:00:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user4.id,
          flop: 100.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      date = DateTime.from_naive!(~N[2021-02-04T14:00:00Z], "Etc/UTC")
      MotivusWbApi.Stats.set_ranking(date)
      [u1, u2] = Repo.all(from q in CurrentSeasonRanking, order_by: q.user_id)
      assert u1.processing_ranking == 2
      assert u1.elapsed_time_ranking == 2
      assert u2.processing_ranking == 1
      assert u2.elapsed_time_ranking == 1
    end

    test "get_user_stats/1 with current season" do
      {:ok, %Season{} = season} =
        Ranking.create_season(%{
          start_date: "2021-01-28T14:00:00Z",
          end_date: "2021-02-11T14:00:00Z",
          name: "SEASON_TEST"
        })

      {:ok, %User{} = user} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2021-01-28T14:30:00Z",
          mail: nil,
          name: "user",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      {:ok, application_token} =
        Users.create_application_token(%{
          value: "value",
          description: "description",
          user_id: user.id
        })

      {:ok, %Task{} = task1} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:30:00Z",
          date_last_dispatch: "2021-01-28T14:40:00Z",
          date_out: "2021-01-28T14:50:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{} = task2} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:30:00Z",
          date_last_dispatch: "2021-01-28T14:40:00Z",
          date_out: "2021-01-28T14:50:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{} = task3} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:30:00Z",
          date_last_dispatch: "2021-01-28T14:40:00Z",
          date_out: "2021-01-28T14:50:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      date = DateTime.from_naive!(~N[2021-02-09T14:00:00Z], "Etc/UTC")
      MotivusWbApi.Stats.set_ranking(date)

      stats = MotivusWbApi.Stats.get_user_stats(user.id, season)

      assert stats == %{
               base_time: 126,
               elapsed_time: 1800,
               elapsed_time_ranking: 1,
               processing_ranking: 1,
               season: %{
                 end_date: ~U[2021-02-11 14:00:00Z],
                 name: "SEASON_TEST",
                 start_date: ~U[2021-01-28 14:00:00Z]
               },
               task_quantity: 3,
               flop: task1.flop + task2.flop + task3.flop
             }
    end

    test "get_user_stats/1 without current season" do
      {:ok, %User{} = user} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2021-01-28T14:30:00Z",
          mail: nil,
          name: "user",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      {:ok, application_token} =
        Users.create_application_token(%{
          value: "value",
          description: "description",
          user_id: user.id
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:30:00Z",
          date_last_dispatch: "2021-01-28T14:40:00Z",
          date_out: "2021-01-28T14:50:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:30:00Z",
          date_last_dispatch: "2021-01-28T14:40:00Z",
          date_out: "2021-01-28T14:50:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      {:ok, %Task{}} =
        Processing.create_task(%{
          application_token_id: application_token.id,
          attempts: 42,
          date_in: "2021-01-28T14:30:00Z",
          date_last_dispatch: "2021-01-28T14:40:00Z",
          date_out: "2021-01-28T14:50:00Z",
          flops: 120.5,
          params: %{},
          processing_base_time: 42,
          type: "some type",
          user_id: user.id,
          flop: 10.0,
          result: %{},
          is_valid: true,
          client_id: "1"
        })

      date = DateTime.from_naive!(~N[2021-02-09T14:00:00Z], "Etc/UTC")
      MotivusWbApi.Stats.set_ranking(date)

      stats = MotivusWbApi.Stats.get_user_stats(user.id, nil)

      assert stats == %{
               base_time: nil,
               elapsed_time: nil,
               elapsed_time_ranking: nil,
               processing_ranking: nil,
               season: %{
                 end_date: nil,
                 name: nil,
                 start_date: nil
               },
               task_quantity: nil,
               flop: nil
             }
    end

    test "get_user_stats/1 with current season and no tasks" do
      {:ok, %Season{} = season} =
        Ranking.create_season(%{
          start_date: "2021-01-28T14:00:00Z",
          end_date: "2021-02-11T14:00:00Z",
          name: "SEASON_TEST"
        })

      {:ok, %User{} = user} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2021-01-28T14:30:00Z",
          mail: nil,
          name: "user",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      date = DateTime.from_naive!(~N[2021-02-09T14:00:00Z], "Etc/UTC")
      MotivusWbApi.Stats.set_ranking(date)

      stats = MotivusWbApi.Stats.get_user_stats(user.id, season)

      assert stats == %{
               base_time: 0,
               elapsed_time: 0,
               elapsed_time_ranking: nil,
               processing_ranking: nil,
               season: %{
                 end_date: season.end_date,
                 name: season.name,
                 start_date: season.start_date
               },
               task_quantity: 0,
               flop: 0
             }
    end

    test "get_user_stats/1 without season and no tasks" do
      {:ok, %User{} = user} =
        Users.create_user(%{
          avatar: "some avatar",
          is_guest: true,
          last_sign_in: "2021-01-28T14:30:00Z",
          mail: nil,
          name: "user",
          provider: "some provider",
          uuid: "7488a646-e31f-11e4-aace-600308960662"
        })

      date = DateTime.from_naive!(~N[2021-02-09T14:00:00Z], "Etc/UTC")
      MotivusWbApi.Stats.set_ranking(date)

      stats = MotivusWbApi.Stats.get_user_stats(user.id, nil)

      assert stats == %{
               base_time: nil,
               elapsed_time: nil,
               elapsed_time_ranking: nil,
               processing_ranking: nil,
               flop: nil,
               season: %{
                 end_date: nil,
                 name: nil,
                 start_date: nil
               },
               task_quantity: nil
             }
    end
  end

  describe "current_season_ranking" do
    alias MotivusWbApi.Ranking.CurrentSeasonRanking

    @valid_attrs %{elapsed_time_ranking: 42, processing_ranking: 42}
    @update_attrs %{elapsed_time_ranking: 43, processing_ranking: 43}
    @invalid_attrs %{elapsed_time_ranking: nil, processing_ranking: nil}

    def current_season_ranking_fixture(attrs \\ %{}) do
      {:ok, current_season_ranking} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ranking.create_current_season_ranking()

      current_season_ranking
    end

    test "list_current_season_ranking/0 returns all current_season_ranking" do
      current_season_ranking = current_season_ranking_fixture()
      assert Ranking.list_current_season_ranking() == [current_season_ranking]
    end

    test "get_current_season_ranking!/1 returns the current_season_ranking with given id" do
      current_season_ranking = current_season_ranking_fixture()

      assert Ranking.get_current_season_ranking!(current_season_ranking.id) ==
               current_season_ranking
    end

    test "create_current_season_ranking/1 with valid data creates a current_season_ranking" do
      assert {:ok, %CurrentSeasonRanking{} = current_season_ranking} =
               Ranking.create_current_season_ranking(@valid_attrs)

      assert current_season_ranking.elapsed_time_ranking == 42
      assert current_season_ranking.processing_ranking == 42
    end

    test "create_current_season_ranking/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ranking.create_current_season_ranking(@invalid_attrs)
    end

    test "update_current_season_ranking/2 with valid data updates the current_season_ranking" do
      current_season_ranking = current_season_ranking_fixture()

      assert {:ok, %CurrentSeasonRanking{} = current_season_ranking} =
               Ranking.update_current_season_ranking(
                 current_season_ranking,
                 @update_attrs
               )

      assert current_season_ranking.elapsed_time_ranking == 43
      assert current_season_ranking.processing_ranking == 43
    end

    test "update_current_season_ranking/2 with invalid data returns error changeset" do
      current_season_ranking = current_season_ranking_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Ranking.update_current_season_ranking(current_season_ranking, @invalid_attrs)

      assert current_season_ranking ==
               Ranking.get_current_season_ranking!(current_season_ranking.id)
    end

    test "delete_current_season_ranking/1 deletes the current_season_ranking" do
      current_season_ranking = current_season_ranking_fixture()

      assert {:ok, %CurrentSeasonRanking{}} =
               Ranking.delete_current_season_ranking(current_season_ranking)

      assert_raise Ecto.NoResultsError, fn ->
        Ranking.get_current_season_ranking!(current_season_ranking.id)
      end
    end

    test "change_current_season_ranking/1 returns a current_season_ranking changeset" do
      current_season_ranking = current_season_ranking_fixture()
      assert %Ecto.Changeset{} = Ranking.change_current_season_ranking(current_season_ranking)
    end
  end
end
