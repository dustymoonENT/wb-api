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
    field :flop, :float
    field :result, :map
    field :is_valid, :boolean
    field :client_id, :string

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:type, :params, :date_in, :date_last_dispatch, :date_out, :attempts, :flops, :processing_base_time, :user_id, :flop, :result, :is_valid, :client_id ])
    |> validate_required([:type, :params, :date_in, :date_last_dispatch, :date_out, :attempts, :flops, :processing_base_time])
  end
end
