defmodule Tandem.Accounts.UserAccounts do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :user_type, :integer
    field :user_status, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_accounts, attrs) do
    user_accounts
    |> cast(attrs, [:first_name, :last_name, :email, :password, :user_type, :user_status])
    |> validate_required([:first_name, :last_name, :email, :password, :user_type, :user_status])
    |> validate_length(:password,
      min: 4,
      max: 12,
      message: " Password should be atleast 4 to 8 characters"
    )
    |> validate_length(:email,
      min: 10,
      max: 20,
      message: "Email address should be between 10 to 20 characters"
    )
    |> unique_constraint(:email, name: :unique_email, message: "Email address already in use.")
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    Ecto.Changeset.put_change(changeset, :password, encrypt_password(password))
  end

  defp put_pass_hash(changeset), do: changeset

  def encrypt_password(password), do: Base.encode16(:crypto.hash(:sha512, password))
end

# Tandem.Accounts.create_user_accounts(%{
#   first_name: "Luis Roy",
#   last_name: "Zulu",
#   email: "luis@mail.com",
#   password: "password06",
#   auto_pwd: "Y",
#   user_type: 1,
#   user_status: "ACTIVE",
#   inserted_at: NaiveDateTime.utc_now(),
#   updated_at: NaiveDateTime.utc_now()
# })
