module Devisable
  extend ActiveSupport::Concern

  included do
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :first_name, :last_name, :phone])
    end
  end

end