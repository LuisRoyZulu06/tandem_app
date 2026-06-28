defmodule Tandem.Applications do
  @moduledoc """
  The Applications context.
  """

  import Ecto.Query, warn: false
  alias Tandem.Repo

  alias Tandem.Applications.Memberships

  @doc """
  Returns the list of tbl_membership.

  ## Examples

      iex> list_tbl_membership()
      [%Memberships{}, ...]

  """
  def list_memberships do
    Repo.all(Memberships)
  end

  @doc """
  Gets a single memberships.

  Raises `Ecto.NoResultsError` if the Memberships does not exist.

  ## Examples

      iex> get_memberships!(123)
      %Memberships{}

      iex> get_memberships!(456)
      ** (Ecto.NoResultsError)

  """
  def get_application_details!(id), do: Repo.get!(Memberships, id)

  @doc """
  Creates a memberships.

  ## Examples

      iex> create_memberships(%{field: value})
      {:ok, %Memberships{}}

      iex> create_memberships(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_memberships(attrs) do
    %Memberships{}
    |> Memberships.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a memberships.

  ## Examples

      iex> update_memberships(memberships, %{field: new_value})
      {:ok, %Memberships{}}

      iex> update_memberships(memberships, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_memberships(%Memberships{} = memberships, attrs) do
    memberships
    |> Memberships.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a memberships.

  ## Examples

      iex> delete_memberships(memberships)
      {:ok, %Memberships{}}

      iex> delete_memberships(memberships)
      {:error, %Ecto.Changeset{}}

  """
  def delete_memberships(%Memberships{} = memberships) do
    Repo.delete(memberships)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking memberships changes.

  ## Examples

      iex> change_memberships(memberships)
      %Ecto.Changeset{data: %Memberships{}}

  """
  def change_memberships(%Memberships{} = memberships, attrs \\ %{}) do
    Memberships.changeset(memberships, attrs)
  end

  # ----------------- Custom Queries
  def total_applications do
    Repo.aggregate(from(v in "tbl_membership", where: v.status != "DRAFT"), :count, :id)
    # Repo.aggregate(from(v in "tbl_membership"), :count, :id)
  end

  def apps_in_review do
    Repo.aggregate(from(v in "tbl_membership", where: v.status == "UNDER_REVIEW"), :count, :id)
  end

  def apps_approved do
    Repo.aggregate(from(v in "tbl_membership", where: v.status == "APPROVED"), :count, :id)
  end

  def apps_rejected do
    Repo.aggregate(from(v in "tbl_membership", where: v.status == "REJECTED"), :count, :id)
  end
end
