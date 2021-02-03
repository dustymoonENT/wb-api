defmodule MotivusWbApiWeb.Ranking.SeasonControllerTest do
  use MotivusWbApiWeb.ConnCase

  alias MotivusWbApi.Ranking
  alias MotivusWbApi.Ranking.Season

  @create_attrs %{
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

  def fixture(:season) do
    {:ok, season} = Ranking.create_season(@create_attrs)
    season
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all seasons", %{conn: conn} do
      conn = get(conn, Routes.ranking_season_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create season" do
    test "renders season when data is valid", %{conn: conn} do
      conn = post(conn, Routes.ranking_season_path(conn, :create), season: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.ranking_season_path(conn, :show, id))

      assert %{
               "id" => id,
               "end_date" => "2010-04-17T14:00:00Z",
               "name" => "some name",
               "start_date" => "2010-04-17T14:00:00Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.ranking_season_path(conn, :create), season: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update season" do
    setup [:create_season]

    test "renders season when data is valid", %{conn: conn, season: %Season{id: id} = season} do
      conn = put(conn, Routes.ranking_season_path(conn, :update, season), season: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.ranking_season_path(conn, :show, id))

      assert %{
               "id" => id,
               "end_date" => "2011-05-18T15:01:01Z",
               "name" => "some updated name",
               "start_date" => "2011-05-18T15:01:01Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, season: season} do
      conn = put(conn, Routes.ranking_season_path(conn, :update, season), season: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete season" do
    setup [:create_season]

    test "deletes chosen season", %{conn: conn, season: season} do
      conn = delete(conn, Routes.ranking_season_path(conn, :delete, season))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.ranking_season_path(conn, :show, season))
      end
    end
  end

  defp create_season(_) do
    season = fixture(:season)
    %{season: season}
  end
end
