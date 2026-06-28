defmodule Tandem.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Tandem.Repo

  alias Tandem.Accounts.UserAccounts

  @doc """
  Returns the list of tbl_users.

  ## Examples

      iex> list_tbl_users()
      [%UserAccounts{}, ...]

  """
  def list_tbl_users do
    Repo.all(UserAccounts)
  end

  @doc """
  Gets a single user_accounts.

  Raises `Ecto.NoResultsError` if the User accounts does not exist.

  ## Examples

      iex> get_user_accounts!(123)
      %UserAccounts{}

      iex> get_user_accounts!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_account!(id), do: Repo.get!(UserAccounts, id)

  @doc """
  Creates a user_accounts.

  ## Examples

      iex> create_user_accounts(%{field: value})
      {:ok, %UserAccounts{}}

      iex> create_user_accounts(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_accounts(attrs) do
    %UserAccounts{}
    |> UserAccounts.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_accounts.

  ## Examples

      iex> update_user_accounts(user_accounts, %{field: new_value})
      {:ok, %UserAccounts{}}

      iex> update_user_accounts(user_accounts, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_accounts(%UserAccounts{} = user_accounts, attrs) do
    user_accounts
    |> UserAccounts.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_accounts.

  ## Examples

      iex> delete_user_accounts(user_accounts)
      {:ok, %UserAccounts{}}

      iex> delete_user_accounts(user_accounts)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_accounts(%UserAccounts{} = user_accounts) do
    Repo.delete(user_accounts)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_accounts changes.

  ## Examples

      iex> change_user_accounts(user_accounts)
      %Ecto.Changeset{data: %UserAccounts{}}

  """
  def change_user_accounts(%UserAccounts{} = user_accounts, attrs \\ %{}) do
    UserAccounts.changeset(user_accounts, attrs)
  end

   # -------------------------------- custom queries
   def get_user_by_email(email) do
    Repo.one(
      from(
        u in UserAccounts,
        where: fragment("lower(?) = lower(?)", u.email, ^email),
        limit: 1,
        select: u
      )
    )
    |> case do
      [] ->
        nil

      user ->
        user
    end
  end
end
