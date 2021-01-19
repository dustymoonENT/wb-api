defmodule MotivusWbApi.Processing.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :attempts, :integer
    field :date_in, :utc_datetime
    field :date_last_dispatch, :utc_datetime
    field :date_out, :utc_datetime
    field :flops, :float
    field :params, :map
    field :processing_base_time, :integer
    field :type, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:type, :params, :date_in, :date_last_dispatch, :date_out, :attempts, :flops, :processing_base_time])
    |> validate_required([:type, :params, :date_in, :date_last_dispatch, :date_out, :attempts, :flops, :processing_base_time])
  end
end
