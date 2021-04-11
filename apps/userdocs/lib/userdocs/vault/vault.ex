defmodule UserDocs.Vault do
  use Cloak.Vault, otp_app: :userdocs

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers, [
        default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: Base.decode64!("JdIqJR0pDeDCeP2aw1Zcob7zfBuWGdKWqinsDUKbfdw=")}
      ])

    {:ok, config}
  end

  defp decode_env!(var) do
    var
    |> System.get_env()
    |> Base.decode64!()
  end
end
