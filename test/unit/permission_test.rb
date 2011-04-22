require File.dirname(__FILE__) + '/../test_helper'

class PermissionTest < Test::Unit::TestCase
  fixtures :roles, :permissions, :role_permissions

  #def test_should_associate_to_roles
  #  assert_equal 1, permissions(:golden_key).roles.length
  #  assert_equal roles(:weakuser).name, permissions(:golden_key).roles[0].name
  #end
  
  #def test_should_add_and_remove_unique_role
  #  assert_equal 3, Permission.find(:all).length
  #  assert_kind_of Permission, Permission.add(:test, :moo)
  #  assert_equal 4, Permission.find(:all).length
  #  assert_equal :duplicate, Permission.add(:test, :moo)
  #  assert Permission.remove(:moo)
  #  assert_equal 3, Permission.find(:all).length
  #  assert_equal :not_found, Permission.remove(:moo)
  #end
end
