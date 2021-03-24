defmodule MotivusWbApiWeb.PrivateChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub

  def join("room:private:api", _message, socket) do
    {:ok, socket}
  end

  def join("room:private:" <> uuid, _message, socket) do
    {:ok, socket}
  end

  ##handle in for incomming task from driver
  def handle_in("task",%{"body" => body, "type" => type, "ref" => ref, "client_id" => client_id},socket)
  do
    ###code for send to private API
    [_, id] = socket.topic |> String.split("room:private:")
    MotivusWbApiWeb.Endpoint.broadcast!("room:private:api","task",%{"body": body, "type": type, "ref": ref, "client_id": id})
		{:noreply, socket}
  end


  ##handle in for incomming response from private api
  def handle_in("response",%{"body"=> body,"client_id"=> client_id},socket)
  do
   ##code
   MotivusWbApiWeb.Endpoint.broadcast!("room:private:"<>client_id,"response",%{"body": body})
	 {:noreply, socket}
  end
 

  def terminate(reason, socket) do
    #[_, id] = socket.topic |> String.split("room:worker:")
    #PubSub.broadcast(MotivusWbApi.PubSub, "nodes", {"dead_node", :hola, %{id: id}})
    # MotivusWbApi.QueueNodes.drop(MotivusWbApi.QueueNodes, id)
    # {:ok,task} = MotivusWbApi.QueueProcessing.drop(MotivusWbApi.QueueProcessing, id)
    # IO.inspect(MotivusWbApi.QueueProcessing.list(MotivusWbApi.QueueProcessing)) 
    # PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"new_task", :hola, task})
  end
end
