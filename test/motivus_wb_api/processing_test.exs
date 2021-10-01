defmodule MotivusWbApi.ProcessingTest do
  use MotivusWbApi.DataCase

  alias MotivusWbApi.Processing
  alias MotivusWbApi.Fixtures

  describe "tasks" do
    alias MotivusWbApi.Processing.Task

    @valid_attrs %{
      attempts: 42,
      date_in: "2010-04-17T14:00:00Z",
      date_last_dispatch: "2010-04-17T14:00:00Z",
      date_out: "2010-04-17T14:00:00Z",
      flops: 120.5,
      params: %{},
      processing_base_time: 42,
      type: "some type",
      flop: 10.0,
      result: %{},
      is_valid: true,
      client_id: "1"
    }
    @update_attrs %{
      attempts: 43,
      date_in: "2011-05-18T15:01:01Z",
      date_last_dispatch: "2011-05-18T15:01:01Z",
      date_out: "2011-05-18T15:01:01Z",
      flops: 456.7,
      params: %{},
      processing_base_time: 43,
      type: "some updated type",
      flop: 10.0,
      result: %{},
      is_valid: false,
      client_id: "2"
    }
    @invalid_attrs %{
      attempts: nil,
      date_in: nil,
      date_last_dispatch: nil,
      date_out: nil,
      flops: nil,
      params: nil,
      processing_base_time: nil,
      type: nil,
      flop: nil,
      result: nil,
      is_valid: nil,
      client_id: nil
    }

    def task_fixture(attrs \\ %{}) do
      user = Fixtures.fixture(:user)
      application_token = Fixtures.fixture(:application_token, user.id)

      {:ok, task} =
        attrs
        |> Map.put_new(:application_token_id, application_token.id)
        |> Enum.into(@valid_attrs)
        |> Processing.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Processing.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Processing.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      user = Fixtures.fixture(:user)
      application_token = Fixtures.fixture(:application_token, user.id)

      assert {:ok, %Task{} = task} =
               Processing.create_task(
                 @valid_attrs
                 |> Map.put_new(:application_token_id, application_token.id)
               )

      assert task.attempts == 42
      assert task.date_in == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert task.date_last_dispatch == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert task.date_out == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert task.flops == 120.5
      assert task.params == %{}
      assert task.processing_base_time == 42
      assert task.type == "some type"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Processing.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Processing.update_task(task, @update_attrs)
      assert task.attempts == 43
      assert task.date_in == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert task.date_last_dispatch == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert task.date_out == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert task.flops == 456.7
      assert task.params == %{}
      assert task.processing_base_time == 43
      assert task.type == "some updated type"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Processing.update_task(task, @invalid_attrs)
      assert task == Processing.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Processing.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Processing.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Processing.change_task(task)
    end
  end
end
