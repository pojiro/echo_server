defmodule EchoServer.Worker do
  use GenServer

  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    Logger.info("|=====> Starting #{__MODULE__} GenServer")

    port = Keyword.get(state, :port, _default_port = 10000)
    # TODO: オプションの意味を調べる
    {:ok, socket} = :gen_tcp.listen(port, active: false, reuseaddr: true)

    send(self(), :accept)

    {:ok, Keyword.put(state, :listening_socket, socket)}
  end

  @impl GenServer
  def terminate(reason, _state) do
    Logger.error("|=====> Stopping #{__MODULE__} GenServer, reason: #{inspect(reason)}")
  end

  @impl GenServer
  def handle_info(:accept, state) do
    {:ok, socket} = :gen_tcp.accept(state[:listening_socket])

    Task.start(EchoServer.PacketHandler, :handle, [socket])

    send(self(), :accept)
    {:noreply, state}
  end
end
