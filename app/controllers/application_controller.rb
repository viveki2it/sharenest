class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :ref_to_cookie
  before_action :set_locale

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == '1'
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end

  
  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed_locale = params[:locale] || request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/)[0]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  protected

  def ref_to_cookie
    campaign_ended = Rails.application.config.ended
    return if campaign_ended || !params[:ref]

    unless User.find_by(referral_code: params[:ref]).nil?
      h_ref = { value: params[:ref], expires: 1.week.from_now }
      cookies[:h_ref] = h_ref
    end

    user_agent = request.env['HTTP_USER_AGENT']
    return unless user_agent && !user_agent.include?('facebookexternalhit/1.1')
    redirect_to proc { url_for(params.permit(:ref, :locale).except(:ref)) }
  end
  
  def flatten_errors errors
    errors.values.flatten.join("; ")
  end  
end
