defmodule TandemWeb.PageController do
  use TandemWeb, :controller
  import Ecto.Query, warn: false
  alias Tandem.Auth
  alias Tandem.Repo
  alias Tandem.Logs
  alias Tandem.Emails
  alias Tandem.Accounts
  alias Tandem.Applications
  alias Tandem.Emails.Email
  alias Tandem.Logs.UserLogs
  alias Tandem.Accounts.UserAccounts
  alias Tandem.Applications.Memberships

   plug(
    TandemWeb.Plugs.RequireAuth
    when action in [
      :dasboard,
      :membership_application
    ]
  )

  plug(
    TandemWeb.Plugs.EnforcePasswordPolicy
    when action in [:new_password, :change_password]
  )

  def applicant(conn, _params) do
    membership_applications = Applications.list_memberships()
    render(conn, :applicant, membership_applications: membership_applications)
  end

  def approver(conn, _params) do
    total_applications = Applications.total_applications()
    apps_in_review = Applications.apps_in_review()
    apps_approved = Applications.apps_approved()
    apps_rejected = Applications.apps_rejected()
    membership_applications = Applications.list_memberships()
    render(conn, :approver, membership_applications: membership_applications, total_applications: total_applications, apps_in_review: apps_in_review, apps_approved: apps_approved, apps_rejected: apps_rejected)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  def create_user(conn, params) do
    IO.inspect(~c"================HT=============")
    IO.inspect(conn)

    case Accounts.get_user_by_email(params["email"]) do
      nil ->
        pwd = random_string(8)
        params = Map.put(params, "password", pwd)

        Ecto.Multi.new()
        |> Ecto.Multi.insert(:useraccount, UserAccounts.changeset(%UserAccounts{}, params))
        |> Ecto.Multi.run(:user_log, fn _repo, %{useraccount: useraccount} ->
          activity = "Created new user on the system. of ID #{useraccount.id}"
          user_log = %{user_id: conn.assigns.user.id, activity: activity}

          UserLogs.changeset(%UserLogs{}, user_log)
          |> Repo.insert()
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{useraccount: _useraccount, user_log: _user_log}} ->
            Email.send_alert(pwd, params["email"], params["email"])

            conn
            |> put_flash(:info, "User created Successfully")
            |> redirect(to: Routes.user_path(conn, :user_mgt, id: params["company_id"]))

          {:error, _} ->
            conn
            |> put_flash(:error, "Failed to create user.")
            |> redirect(to: Routes.user_path(conn, :user_mgt, id: params["company_id"]))
        end

      _user ->
        conn
        |> put_flash(:error, "User with #{params["email"]} already exists.")
        |> redirect(to: Routes.user_path(conn, :user_mgt))
    end
  end

  def save_draft(conn, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:memberships, Memberships.changeset(%Memberships{}, params))
    |> Ecto.Multi.run(:user_log, fn _repo, %{memberships: memberships} ->
      activity = "Saved Draft for membership application. Application has ID #{memberships.id}"
      user_log = %{user_id: conn.assigns.user.id, activity: activity}

      UserLogs.changeset(%UserLogs{}, user_log)
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{memberships: memberships, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Draft Membership Application Saved. You can come back anytime to edit.")
        |> redirect(to: ~p"/applicant/dashboard")

      {:error, _} ->
        conn
        |> put_flash(:error, "Application failed. Please try again later.")
        |> redirect(to: ~p"/applicant/dashboard")
    end
  end

  def membership_application(conn, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:memberships, Memberships.changeset(%Memberships{}, params))
    |> Ecto.Multi.run(:user_log, fn _repo, %{memberships: memberships} ->
      activity = "Applied for membership. Application has ID #{memberships.id}"
      user_log = %{user_id: conn.assigns.user.id, activity: activity}

      UserLogs.changeset(%UserLogs{}, user_log)
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{memberships: memberships, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "You have successfully applied for new Membership. Please wait for review of the application.")
        |> redirect(to: ~p"/applicant/dashboard")

      {:error, _} ->
        conn
        |> put_flash(:error, "Application failed. Please try again later.")
        |> redirect(to: ~p"/applicant/dashboard")
    end
  end

#   def application_details(conn, %{"id" => id}) do
#   application = Applications.get_application_details!(id)

#   render(conn, :application_details,
#     get_application_details: application,
#     get_user: application.user
#   )
# end

  # def application_details(conn, %{"id" => id} = params) do
  #   get_user = Accounts.get_user_account!(id)
  #   get_application_details = Applications.get_application_details!(id)
  #   render(conn, :application_details, id: id, get_application_details: get_application_details, get_user: get_user)
  # end

  def application_details(conn, %{"id" => id} = params) do
    get_application_details = Applications.get_application_details!(id)
    render(conn, :application_details, id: id, get_application_details: get_application_details)
  end

  def approve_application(conn, %{"id" => id} = params) do
    edit_application_status = Applications.get_application_details!(id)

    redirect_path =
      case conn.assigns.user.user_type do
        1 -> ~p"/applicant/dashboard"
        2 -> ~p"/approver/dashboard"
        _ -> ~p"/dashboard"
      end

    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :update_category,
      Memberships.changeset(edit_application_status, params)
    )
    |> Ecto.Multi.run(:user_log, fn _repo, %{update_category: application} ->
      activity = "Approved application of ID #{application.id}"

      user_log = %{
        user_id: conn.assigns.user.id,
        activity: activity
      }

      UserLogs.changeset(%UserLogs{}, user_log)
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{update_category: _application, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Application approved successfully")
        |> redirect(to: redirect_path)

      {:error, _step, _reason, _changes} ->
        conn
        |> put_flash(:error, "Failed to approve application. Please try again later.")
        |> redirect(to: redirect_path)
    end
  end

  # def approve_application(conn, %{"id" => id} = params) do
  #   edit_application_status = Applications.get_application_details!(id)

  #   Ecto.Multi.new()
  #   |> Ecto.Multi.update(:update_category, Memberships.changeset(edit_application_status, params))
  #   |> Ecto.Multi.run(:user_log, fn _repo, %{update_category: edit_application_status} ->
  #     activity = "Approved application of  ID #{edit_application_status.id}"

  #     user_log = %{
  #       user_id: conn.assigns.user.id,
  #       activity: activity
  #     }

  #     UserLogs.changeset(%UserLogs{}, user_log)
  #     |> Repo.insert()
  #   end)
  #   |> Repo.transaction()
  #   |> case do
  #     {:ok, %{update_category: edit_application_status, user_log: _user_log}} ->
  #       conn
  #       |> put_flash(:info, "Application approved successfully")
  #       |> redirect(to: ~p"/approver/dashboard", id: edit_application_status.id)

  #     {:error, _} ->
  #       conn
  #       |> put_flash(:error, "Failed to approve application. Please try again later.")
  #       |> redirect(to: ~p"/approver/dashboard", id: edit_application_status.id)
  #   end
  # end

  # -----------helper functions---------
  def get_user_by_email(email) do
    case Repo.get_by(UserAccounts, email: email) do
      nil -> {:error, "invalid email address"}
      user -> {:ok, user}
    end
  end
end
