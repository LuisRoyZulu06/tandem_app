defmodule Tandem.Applications.Memberships do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_membership" do
    field :title, :string
    field :category, :string
    field :description, :string
    field :amount, :decimal
    field :status, :string, default: "UNDER_REVIEW"
    field :rejection_note, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(memberships, attrs) do
    memberships
    |> cast(attrs, [:title, :category, :description, :amount, :status, :rejection_note])
    |> validate_required([:title, :category, :description, :amount, :status])
  end
end
