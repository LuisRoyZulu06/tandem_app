defmodule Tandem.Repo.Migrations.CreateTblUsers do
  use Ecto.Migration

  def change do
    create table(:tbl_users) do
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :password, :string
      add :user_type, :integer
      add :user_status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
