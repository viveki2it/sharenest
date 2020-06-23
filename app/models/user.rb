class User < ApplicationRecord
  belongs_to :referrer, class_name: 'User', foreign_key: 'referrer_id', optional: true
  has_many :referrals, class_name: 'User', foreign_key: 'referrer_id'

  validates :email, presence: true, uniqueness: {case_sensitive: false, message: :unique_email }
  validates :email, 'valid_email_2/email': { mx: true, disposable: true, message: :valid_email }
  validates :referral_code, uniqueness: true

  before_create :create_referral_code
  after_create :send_welcome_email
  
  def user_url(root_url)
    root_url + "users/" + referral_code
  end  

  # def send_thankyou_email
  #   User.where("id > 27850").each_slice(1000) do |batch|
  #     batch.each do |user|
  #       address = ValidEmail2::Address.new(user.email)
  #       if address.valid? && address.valid_mx?
  #         mailgun_validate = get_validate(user.email)
  #         if mailgun_validate.dig('result').eql?('deliverable')
  #           UserMailer.thank_you_email(user).deliver_later
  #           puts "Thankyou eamil sent: #{user.email}"
  #         else
  #           puts "Failed mailgun eamil sent: #{user.email}"
  #         end
  #       else
  #         puts "Failed eamil sent: #{user.email}"
  #       end
  #     end
  #   end
  # end

  private

  def get_validate(email)
    url_params = { address: email }
    public_key = ENV['MAILGUN_API_KEY']
    validate_url = "https://api.mailgun.net/v4/address/validate"
    response = RestClient::Request.execute method: :get, url: validate_url, headers: { params: url_params }, user: 'api', password: public_key
    response_json = JSON.parse response
    response_json
  end

  def create_referral_code
    self.referral_code = UsersHelper.unused_referral_code
  end

  def send_welcome_email
    # klaviyo = Klaviyo::Client.new(ENV['KLAVIYO_API_KEY'])
    UserMailer.signup_email(self).deliver_later
    # klaviyo.track('Registered  new user',
    #   email: self.email
    # )
  end

end
