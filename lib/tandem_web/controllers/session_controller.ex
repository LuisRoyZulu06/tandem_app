defmodule TandemWeb.SessionController do
  use TandemWeb, :controller

  alias TandemWeb.PageController
  alias Tandem.Logs
  alias Tandem.Auth

  def login(conn, _params) do
    conn = put_layout(conn, false)
    render(conn, :login)
  end

  # def home(conn, _params) do
  #   render(conn, :login)
  # end

  def create(conn, params) do
    with {:error, _reason} <- PageController.get_user_by_email(String.trim(params["email"])) do
      conn
      |> put_flash(:error, "Invalid login credentials.")
      |> put_layout(false)
      |> render("applicant.html")
    else
      {:ok, user} ->
        with {:error, _reason} <- Auth.confirm_password(user, String.trim(params["password"])) do
          conn
          |> put_flash(:error, "Invalid login credentials.")
          |> put_layout(false)
          |> render("applicant.html")
        else
          {:ok, _} ->
            cond do
              user.user_status == "ACTIVE" ->
                {:ok, _} = Logs.create_user_logs(%{user_id: user.id, activity: "logged in"})

                cond do
                  # ------------------------------------------------ Applicant
                  user.user_type == 1 ->
                    conn
                    |> put_session(:current_user, user.id)
                    |> put_session(:session_timeout_at, session_timeout_at())
                    |> redirect(to: ~p"/applicant/dashboard")

                  # ------------------------------------------------ Approver
                  user.user_type == 2 ->
                    conn
                    |> put_session(:current_user, user.id)
                    |> put_session(:session_timeout_at, session_timeout_at())
                    |> redirect(to: ~p"/approver/dashboard")
                end

              true ->
                conn
                # |> put_status(405)
                # |> put_layout(false)
                |> redirect(to: Routes.session_path(conn, :error_405))
            end
        end
    end
  end

  defp session_timeout_at do
    DateTime.utc_now() |> DateTime.to_unix() |> (&(&1 + 3_600)).()
  end

  def signout(conn, _params) do
    {:ok, _} = Logs.create_user_logs(%{user_id: conn.assigns.user.id, activity: "logged out"})

    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
    # |> redirect(to: Routes.session_path(conn, :new))
  rescue
    _ ->
      conn
      |> configure_session(drop: true)
      |> redirect(to: ~p"/")
  end

end
