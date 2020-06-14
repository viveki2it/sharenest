class UserMailer < ActionMailer::Base
  default from: "ShareNest <do-not-reply@sharenest.com>"

  def signup_email(user)
    @user = user
    @twitter_message = I18n.t("email.twitter_msg")

    mail(:to => user.email, :subject => I18n.t("email.subject"))
  end

  def thank_you_email(user)
    @user = user

    mail(:to => user.email, :subject => "Thank you for participating!")
  end
end
