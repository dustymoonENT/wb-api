defmodule MotivusWbApiWeb.Ranking.CurrentSeasonRankingControllerTest do
  use MotivusWbApiWeb.ConnCase

  alias MotivusWbApi.Ranking
  alias MotivusWbApi.Ranking.CurrentSeasonRanking

  @create_attrs %{
    elapsed_time_ranking: 42,
    processing_ranking: 42
  }
  @update_attrs %{
    elapsed_time_ranking: 43,
    processing_ranking: 43
  }
  @invalid_attrs %{elapsed_time_ranking: nil, processing_ranking: nil}

  def fixture(:current_season_ranking) do
    {:ok, current_season_ranking} = Ranking.create_current_season_ranking(@create_attrs)
    current_season_ranking
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all current_season_ranking", %{conn: conn} do
      conn = get(conn, Routes.current_season_ranking_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create current_season_ranking" do
    test "renders current_season_ranking when data is valid", %{conn: conn} do
      conn = post(conn, Routes.current_season_ranking_path(conn, :create), current_season_ranking: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.current_season_ranking_path(conn, :show, id))

      assert %{
               "id" => id,
               "elapsed_time_ranking" => 42,
               "processing_ranking" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.current_season_ranking_path(conn, :create), current_season_ranking: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update current_season_ranking" do
    setup [:create_current_season_ranking]

    test "renders current_season_ranking when data is valid", %{conn: conn, current_season_ranking: %CurrentSeasonRanking{id: id} = current_season_ranking} do
      conn = put(conn, Routes.current_season_ranking_path(conn, :update, current_season_ranking), current_season_ranking: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.current_season_ranking_path(conn, :show, id))

      assert %{
               "id" => id,
               "elapsed_time_ranking" => 43,
               "processing_ranking" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, current_season_ranking: current_season_ranking} do
      conn = put(conn, Routes.current_season_ranking_path(conn, :update, current_season_ranking), current_season_ranking: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete current_season_ranking" do
    setup [:create_current_season_ranking]

    test "deletes chosen current_season_ranking", %{conn: conn, current_season_ranking: current_season_ranking} do
      conn = delete(conn, Routes.current_season_ranking_path(conn, :delete, current_season_ranking))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.current_season_ranking_path(conn, :show, current_season_ranking))
      end
    end
  end

  defp create_current_season_ranking(_) do
    current_season_ranking = fixture(:current_season_ranking)
    %{current_season_ranking: current_season_ranking}
  end
end
