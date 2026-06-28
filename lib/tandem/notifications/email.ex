defmodule Tandem.Notifications.Email do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_email" do
    field :subject, :string
    field :sender_email, :string
    field :sender_name, :string
    field :mail_body, :string
    field :recipient_email, :string
    field :status, :string
    field :attempts, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [
      :subject,
      :sender_email,
      :sender_name,
      :mail_body,
      :recipient_email,
      :status,
      :attempts
    ])
    |> validate_required([
      :subject,
      :sender_email,
      :sender_name,
      :mail_body,
      :recipient_email,
      :status,
      :attempts
    ])
  end
end
