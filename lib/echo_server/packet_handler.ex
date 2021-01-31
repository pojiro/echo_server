defmodule EchoServer.PacketHandler do
  require Logger

  def handle(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, packet} ->
        # echo
        :gen_tcp.send(socket, packet)

      {:error, :enotconn} ->
        :ok = :gen_tcp.close(socket)
        exit(:normal)

      {:error, :closed} ->
        exit(:normal)

      {:error, reason} ->
        Logger.error(inspect(reason))
    end

    handle(socket)
  end
end
