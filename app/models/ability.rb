class Ability
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  include CanCan::Ability

  ### Callbacks ####################################################################################


  ### Other ########################################################################################

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def initialize(user)
    # Define abilities for the passed in user
    @user = user || User.new      # guest user (not logged in)
    # Check them in order of least responsibility to more responsibilities
    employee if @user.roles.any? {|r| r.name == 'employee'}
    manager  if @user.roles.any? {|r| r.name == 'manager'}
    owner    if @user.roles.any? {|r| r.name == 'owner'}

    can :read, :all if @user.roles.count == 0   # Guest can only read
  end

  # Role that has least responsibilities should be on top in case it overwrites the higher roles logic (due to has many roles)
  def employee
    can :manage, User, id: @user.id
    cannot :create, User
    cannot :destroy, User
    can :read, :all
  end

  def manager
    can :manage, User, store_id: @user.store_id
    can :read, :all
  end

  def owner
    can :manage, User, store_id: @user.store_id
    can :manage, Role
    can :read, :all
  end

  private


end
