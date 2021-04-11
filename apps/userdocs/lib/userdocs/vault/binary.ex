defmodule UserDocs.Encrypted.Binary do
  use Cloak.Ecto.Binary, vault: UserDocs.Vault
end
