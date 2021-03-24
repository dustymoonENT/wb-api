defmodule MotivusWbApiWeb.WorkerChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub

  def join("room:worker:" <> uuid, _message, socket) do
    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes",
      {"new_channel", :hola, %{uuid: uuid}}
    )

    {:ok, socket}
  end


  def join("room:private", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in(
        "result",
        %{
          "body" => body,
          "type" => type,
          "ref" => ref,
          "client_id" => client_id,
          "task_id" => task_id,
          "tid" => tid
        },
        socket
      ) do
    case type do
      "response" ->
        [_, id] = socket.topic |> String.split("room:worker:")

        PubSub.broadcast(
          MotivusWbApi.PubSub,
          "completed",
          {"task_completed", :hola,
           %{
             body: body,
             type: type,
             ref: ref,
             client_id: client_id,
             id: id,
             task_id: task_id,
             tid: tid
           }}
        )

      _ ->
        nil
    end

    {:noreply, socket}
  end

  def handle_in("input_request", %{"tid" => tid}, socket) do
    [_, uuid] = socket.topic |> String.split("room:worker:")
    PubSub.broadcast(MotivusWbApi.PubSub, "nodes", {"new_node", :hola, %{id: uuid, tid: tid}})
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    [_, id] = socket.topic |> String.split("room:worker:")
    PubSub.broadcast(MotivusWbApi.PubSub, "nodes", {"dead_node", :hola, %{id: id}})
    # MotivusWbApi.QueueNodes.drop(MotivusWbApi.QueueNodes, id)
    # {:ok,task} = MotivusWbApi.QueueProcessing.drop(MotivusWbApi.QueueProcessing, id)
    # IO.inspect(MotivusWbApi.QueueProcessing.list(MotivusWbApi.QueueProcessing)) 
    # PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"new_task", :hola, task})
  end
end
