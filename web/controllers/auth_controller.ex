defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth
  alias Discuss.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn , params) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: Atom.to_string(auth.provider)}
    sign_in(conn, User.changeset(%User{}, user_params))
  end

  defp sign_in(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} -> conn
      |> put_flash(:info, "Welcome Back")
      |> put_session(:user_id, user.id)
      |> redirect to: topic_path(conn, :index)
      {:error, error} -> conn
      |> put_flash(:error, "Error signing in")
      |> redirect to: topic_path(conn, :index)
    end
  end

  def sign_out(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: topic_path(conn, :index))
  end

  defp insert_or_update_user(changeset) do
    IO.inspect changeset
    case Repo.get_by(User, email: changeset.changes.email) do
      nil -> Repo.insert(changeset)
      user -> {:ok, user}
    end
  end

  def request(conn, params) do

  end

end
