class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:email, :password, :first_name, :last_name, :phone )}
  end

  def authenticate_user_from_token!
    if params[:email] and params[:token]
      user = User.find_by(email: params[:email])
      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      if user && Devise.secure_compare(user.authentication_token, params[:token])
        sign_in user, store: false
      else
        render json: {errors: 'Invalid Identity'}.to_json, status: 401
      end
    end
  end


end
