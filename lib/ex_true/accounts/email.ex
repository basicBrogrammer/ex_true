defmodule ExTrue.Accounts.Email do
  import Bamboo.Email
  alias ExTrue.Accounts.User

  def confirmation_email(%User{email: email, confirmation_token: token}) do
    new_email(
      to: email,
      from: "support@myapp.com",
      subject: "Confirm Your Signup.",
      html_body: "
      <h2>Confirm your signup</h2>

      <p>Your confirmation code is #{token}</p>
      ",
      text_body: "
      Confirm your signup

      Your confirmation code is #{token}
      "
    )
  end
end
