class Api::V1::UsersController < Api::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_user, only: [:update, :show, :destroy]
  load_and_authorize_resource params_method: :user_params

  def index
    @users = current_resource_owner.store.employees
    render json: @users.as_json(only: [:id, :email, :first_name, :last_name], methods: [:photo_medium]), status: 200
  end

  def create
    user = User.create(user_params)
    render json: user.as_json, status: 200
  end

  def update
    if params[:old_password] and params[:user][:password]
      # Check if user attempts to change password
      raise 'Incorrect Password' unless @user.valid_password?(params[:old_password])
    end
    @user.update!(user_params) if params[:user] and current_resource_owner == @user
    assign_roles if params[:role_ids] and (current_resource_owner.has_role?(:manager) or current_resource_owner.has_role?(:owner))
    render json: @user.as_json(include: :roles, methods: :photo_medium), status: 200
  end

  def show
    render json: @user.as_json(include: [:roles, :store], methods: [:photo_medium]), status: 200
  end

  def destroy
    @user.destroy!
    render json: {message: 'success'}.to_json, status: 200
  end

  private
  def set_user
    @user = params[:id].nil? || /me/.match(params[:id]) ? current_resource_owner : User.find(params[:id])
  end

  def assign_roles
    @user.roles.clear
    @user.roles << Role.where(id: params[:role_ids])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :email, :phone, :store_id, :manager_id,
                                 :authentication_token, :preferred_language)
  end

end
