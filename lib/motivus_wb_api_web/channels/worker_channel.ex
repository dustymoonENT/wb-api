defmodule MotivusWbApiWeb.WorkerChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub

  def join("room:worker:" <> _ts, _message, socket) do
    PubSub.broadcast(MotivusWbApi.PubSub, "nodes", {"new_node", :hola, %{id: _ts}})
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in(
        "new_msg",
        %{
          "body" => body,
          "type" => type,
          "ref" => ref,
          "client_id" => client_id,
          "task_id" => task_id
        },
        socket
      ) do
    case type do
      "response" ->
        IO.inspect(task_id: task_id)
        [_, id] = socket.topic |> String.split("room:worker:")
        IO.inspect(respuesta: client_id)

        MotivusWbApiWeb.Endpoint.broadcast!(
          "room:client:" <> client_id,
          "new_msg",
          %{uid: 1, body: body, type: "response", ref: ref, client_id: client_id}
        )

        PubSub.broadcast(MotivusWbApi.PubSub, "nodes", {"new_node", :hola, %{id: id}})

      _ ->
        nil
    end

    {:noreply, socket}
  end

  def terminate(reason, socket) do
    IO.inspect(reason)
    IO.inspect(socket.topic)
    [_, id] = socket.topic |> String.split("room:worker:")
    MotivusWbApi.QueueNodes.drop(MotivusWbApi.QueueNodes, id)
  end
end
