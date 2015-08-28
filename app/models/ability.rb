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
    @user.roles.each { |role| send(role.name.downcase) }

    can :read, :all if @user.roles.count == 0   # Guest can only read
  end

  # Role that has least responsibilities should be on top in case it overwrites the higher roles logic (due to has many roles)
  def employee
    can :manage, User, id: @user.id
    cannot :destroy, User
    can :read, :all
  end

  def manager
    can :manage, User, id: @user.id
    can :assign_roles, User
    cannot :destroy, User
    can :read, :all
  end

  def owner
    can :manage, User
    can :assign_roles, User
    can :manage, Role
    can :read, :all
  end

  private


end
