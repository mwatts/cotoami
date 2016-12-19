defmodule Cotoami.Auth do
  import Plug.Conn
  require Logger
  
  @cookie_for_anonymous_id "cotoami_anonymous_id"
  @anonymous_max_age 60 * 60 * 24 * 365 * 10
  @session_key_amishi_id :amishi_id
  
  def init(options) do
    options
  end
  
  def call(conn, _opts) do
    cond do
      amishi_id = get_session(conn, @session_key_amishi_id) ->
        conn
      anonymous_id = get_anonymous_id(conn)
        conn |> assign_anonymous_id(id) 
      true -> 
        new_id = generate_anonymous_id
        conn
        |> put_resp_cookie(@cookie_for_anonymous_id, new_id, max_age: @anonymous_max_age)
        |> assign_anonymous_id(new_id) 
    end
  end
  
  def get_anonymous_id(conn) do
    conn.cookies[@cookie_for_anonymous_id]
  end
  
  defp generate_anonymous_id do
    :crypto.strong_rand_bytes(30) |> Base.hex_encode32(case: :lower)
  end
  
  defp assign_anonymous_id(conn, anonymous_id) do
    Logger.info "anonymous_id: #{anonymous_id}"
    Logger.metadata(user_token: anonymous_id)
    assign(conn, :anonymous_id, anonymous_id)
  end
  
  def generate_signin_token do
    :crypto.strong_rand_bytes(30) |> Base.hex_encode32(case: :lower)
  end
  
  def start_session(conn, amishi) do
    conn |> put_session(@session_key_amishi_id, amishi.id)
  end
end
