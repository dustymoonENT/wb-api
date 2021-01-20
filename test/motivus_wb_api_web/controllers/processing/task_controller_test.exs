#defmodule MotivusWbApiWeb.Processing.TaskControllerTest do
#  use MotivusWbApiWeb.ConnCase
#
#  alias MotivusWbApi.Processing
#  alias MotivusWbApi.Processing.Task
#
#  @create_attrs %{
#    attempts: 42,
#    date_in: "2010-04-17T14:00:00Z",
#    date_last_dispatch: "2010-04-17T14:00:00Z",
#    date_out: "2010-04-17T14:00:00Z",
#    flops: 120.5,
#    params: %{},
#    processing_base_time: 42,
#    type: "some type"
#  }
#  @update_attrs %{
#    attempts: 43,
#    date_in: "2011-05-18T15:01:01Z",
#    date_last_dispatch: "2011-05-18T15:01:01Z",
#    date_out: "2011-05-18T15:01:01Z",
#    flops: 456.7,
#    params: %{},
#    processing_base_time: 43,
#    type: "some updated type"
#  }
#  @invalid_attrs %{attempts: nil, date_in: nil, date_last_dispatch: nil, date_out: nil, flops: nil, params: nil, processing_base_time: nil, type: nil}
#
#  def fixture(:task) do
#    {:ok, task} = Processing.create_task(@create_attrs)
#    task
#  end
#
#  setup %{conn: conn} do
#    {:ok, conn: put_req_header(conn, "accept", "application/json")}
#  end
#
#  describe "index" do
#    test "lists all tasks", %{conn: conn} do
#      conn = get(conn, Routes.processing_task_path(conn, :index))
#      assert json_response(conn, 200)["data"] == []
#    end
#  end
#
#  describe "create task" do
#    test "renders task when data is valid", %{conn: conn} do
#      conn = post(conn, Routes.processing_task_path(conn, :create), task: @create_attrs)
#      assert %{"id" => id} = json_response(conn, 201)["data"]
#
#      conn = get(conn, Routes.processing_task_path(conn, :show, id))
#
#      assert %{
#               "id" => id,
#               "attempts" => 42,
#               "date_in" => "2010-04-17T14:00:00Z",
#               "date_last_dispatch" => "2010-04-17T14:00:00Z",
#               "date_out" => "2010-04-17T14:00:00Z",
#               "flops" => 120.5,
#               "params" => %{},
#               "processing_base_time" => 42,
#               "type" => "some type"
#             } = json_response(conn, 200)["data"]
#    end
#
#    test "renders errors when data is invalid", %{conn: conn} do
#      conn = post(conn, Routes.processing_task_path(conn, :create), task: @invalid_attrs)
#      assert json_response(conn, 422)["errors"] != %{}
#    end
#  end
#
#  describe "update task" do
#    setup [:create_task]
#
#    test "renders task when data is valid", %{conn: conn, task: %Task{id: id} = task} do
#      conn = put(conn, Routes.processing_task_path(conn, :update, task), task: @update_attrs)
#      assert %{"id" => ^id} = json_response(conn, 200)["data"]
#
#      conn = get(conn, Routes.processing_task_path(conn, :show, id))
#
#      assert %{
#               "id" => id,
#               "attempts" => 43,
#               "date_in" => "2011-05-18T15:01:01Z",
#               "date_last_dispatch" => "2011-05-18T15:01:01Z",
#               "date_out" => "2011-05-18T15:01:01Z",
#               "flops" => 456.7,
#               "params" => %{},
#               "processing_base_time" => 43,
#               "type" => "some updated type"
#             } = json_response(conn, 200)["data"]
#    end
#
#    test "renders errors when data is invalid", %{conn: conn, task: task} do
#      conn = put(conn, Routes.processing_task_path(conn, :update, task), task: @invalid_attrs)
#      assert json_response(conn, 422)["errors"] != %{}
#    end
#  end
#
#  describe "delete task" do
#    setup [:create_task]
#
#    test "deletes chosen task", %{conn: conn, task: task} do
#      conn = delete(conn, Routes.processing_task_path(conn, :delete, task))
#      assert response(conn, 204)
#
#      assert_error_sent 404, fn ->
#        get(conn, Routes.processing_task_path(conn, :show, task))
#      end
#    end
#  end
#
#  defp create_task(_) do
#    task = fixture(:task)
#    %{task: task}
#  end
#end
