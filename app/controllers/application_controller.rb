class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :default_url_options
  before_action :set_locale
  before_filter :set_paper_trail_whodunnit

  include Devisable

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def user_for_paper_trail
    author = 'Public User'
    author = current_user.id if current_user
    author = current_admin_user.id if admin_user_signed_in?
    author
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :first_name, :last_name, :phone])
  end

end
