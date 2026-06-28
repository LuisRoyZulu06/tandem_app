defmodule Tandem.Repo.Migrations.CreateTblMembership do
  use Ecto.Migration

  def change do
    create table(:tbl_membership) do
      add :title, :string
      add :category, :string
      add :description, :string
      add :amount, :decimal
      add :status, :string
      add :rejection_note, :string

      timestamps(type: :utc_datetime)
    end
  end
end
