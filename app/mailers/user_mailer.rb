class UserMailer < ActionMailer::Base
  default from: "OA <welcome@oa.com>"

  def signup_email(user)
    @user = user
    @twitter_message = "Invite your friends to ShareNest - For each friend you get exclusive experiences with unique people."

    mail(:to => user.email, :subject => "Thank you for Raising your Hand!")
  end

  def thank_you_email(user)
    @user = user

    mail(:to => user.email, :subject => "Thank you for participating!")
  end
end
