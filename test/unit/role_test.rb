require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  fixtures :users, :roles, :user_roles, :permissions, :role_permissions

  #def test_should_associate_to_users
  #  assert_equal 1, roles(:poweruser).users.length
  #  assert_equal users(:billy).login, roles(:poweruser).users[0].login
  #  assert_equal 2, roles(:weakuser).users.length
  #  assert_not_nil roles(:weakuser).users.detect { |user| user.login == users(:sara).login }
  #end
  
  #def test_should_associate_to_permissions
  #  assert_equal 2, roles(:poweruser).permissions.length
  #  assert_not_nil roles(:poweruser).permissions.detect { |perm| perm.name == permissions(:read_power).name }
  #  assert_nil roles(:poweruser).permissions.detect { |perm| perm.name == permissions(:golden_key).name }
  #  assert_equal 1, roles(:weakuser).permissions.length
  #  assert_not_nil roles(:weakuser).permissions.detect { |perm| perm.name == permissions(:golden_key).name }
  #end
  
  #def test_should_check_permissions_of_role
  #  assert roles(:poweruser).permission?(:read_power)
  #  assert_equal false, roles(:weakuser).permission?(:read_power)
  #  assert roles(:weakuser).permission?(:golden_key)
  #end
  
  #def test_should_add_and_remove_unique_role
  #  assert_equal 2, Role.find(:all).length
  #  assert_kind_of Role, Role.add(:test)
  #  assert_equal 3, Role.find(:all).length
  #  assert_equal :duplicate, Role.add(:test)
  #  assert Role.remove(:test)
  #  assert_equal 2, Role.find(:all).length
  #  assert_equal :not_found, Role.remove(:test)
  #end
  
  def test_permission
    secretarial_role = roles(:secretarial_role)
    assert(secretarial_role.permission?('manage_notes'))
  end
end
