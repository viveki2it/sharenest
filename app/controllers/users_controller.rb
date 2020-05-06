class UsersController < ApplicationController
  before_action :skip_first_page, only: :new
  before_action :handle_ip, only: :create
  before_action :fetch_user, only: :show

  def new
    @bodyId = 'home'
    @is_mobile = mobile_device?

    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    ref_code = cookies[:h_ref]
    email = params[:user][:email]
    first_name = params[:user][:first_name]
    @user = User.new(email: email, first_name: first_name)
    @user.referrer = User.find_by_referral_code(ref_code) if ref_code

    if @user.save
      @user.update_attributes(:referrer_id => @user.id) if ref_code.blank?
      cookies[:h_email] = { value: @user.email }
      redirect_to user_path(@user.referral_code), notice: "Please check your email for the referral unique link"
    else
      if email.blank?
        logger.info("Error saving user with email, email is empty")
        flash[:error] = "Please enter email"
      else
        errors = ""
        errors += flatten_errors(@user.errors) if !@user.errors.empty?
        flash[:error] = errors
        logger.info("Error saving user with email, #{email}")
      end
      redirect_to root_path
    end
  end

  def refer
    @bodyId = 'refer'
    @is_mobile = mobile_device?

    @user = User.find_by_email(cookies[:h_email])

    respond_to do |format|
      if @user.nil?
        format.html { redirect_to root_path, alert: 'Something went wrong!' }
      else
        format.html # refer.html.erb
      end
    end
  end

  def policy
  end

  def redirect
    redirect_to root_path, status: 404
  end
  
  def show
    if @user.blank?
      redirect_to root_path, alert: 'Your referral code is does not match!'
    else
      render "refer"
    end
  end

  private

  def skip_first_page
    return if Rails.application.config.ended

    email = cookies[:h_email]
    if email && User.find_by_email(email)
      redirect_to '/refer-a-friend'
    else
      cookies.delete :h_email
    end
  end
  
  def fetch_user
		@user = User.find_by(referral_code: params[:id])
	end


  def handle_ip
    # Prevent someone from gaming the site by referring themselves.
    # Presumably, users are doing this from the same device so block
    # their ip after their ip appears three times in the database.

    address = request.env['HTTP_X_FORWARDED_FOR']
    return if address.nil?

    current_ip = IpAddress.find_by_address(address)
    if current_ip.nil?
      current_ip = IpAddress.create(address: address, count: 1)
    elsif current_ip.count > 2
      logger.info('IP address has already appeared three times in our records.
                 Redirecting user back to landing page.')
      flash[:error] = "Your IP address has reached the max entries. Your IP address has been blocked by the system."
      return redirect_to root_path
    else
      current_ip.count += 1
      current_ip.save
    end
  end

end
