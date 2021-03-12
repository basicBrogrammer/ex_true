defmodule ExTrue.Repo.Migrations.AddConfirmationTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :confirmation_token, :integer
      add :confirmation_sent_at, :naive_datetime, default: fragment("now()")
      add :confirmed_at, :naive_datetime
    end
  end
end
