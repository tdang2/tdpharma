class Api::V1::UsersController < ApplicationController
  before_filter :authenticate_user_from_token!  # This is for mobile app api
  before_filter :authenticate_user!             # standard devise web app
  before_action :set_user, only: [:update, :show, :destroy]
  load_and_authorize_resource

  def index
    begin
      @users = @current_user.store.employees
      render json: @users.as_json(only: [:email, :first_name, :last_name]), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def update
    begin
      @user.update!(user_params) if params[:user] and @current_user == @user
      assign_roles if params[:role_ids] and (@current_user.has_role?(:manager) or @current_user.has_role?(:owner))
      render json: @user.as_json(include: :roles), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}),  status: 400
    end
  end

  def show
    begin
      render json: @user.as_json(include: :roles), status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  def destroy
    begin
      sign_out @current_user if @user == @current_user
      @user.destroy!
      render json: {message: 'success'}.to_json, status: 200
    rescue StandardError => e
      render json: prepare_json({errors: e.message}), status: 400
    end
  end

  private
  def set_user
    @user = params[:id].nil? ? @current_user : User.find(params[:id])
  end

  def assign_roles
    @user.roles.clear
    @user.roles << Role.where(id: params[:role_ids])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :email, :phone)
  end

end
