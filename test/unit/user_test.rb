require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :user_groups, :roles, :permissions, :role_permissions, :roles_user_groups, :users, :user_groups_users, :user_roles, :access_control_lists
  #def test_should_have_association_between_user_and_roles
  #  assert_equal 2, users(:billy).roles.length
  #  assert_not_nil users(:billy).roles.detect { |role| role.name == roles(:poweruser).name }
  #  assert_equal 1, users(:sara).roles.length
  #  assert_nil users(:sara).roles.detect { |role| role.name == roles(:poweruser).name }
  #end
  
  #def test_should_be_able_to_check_permissions
  #  assert users(:billy).permission?(:golden_key)
  #  assert users(:billy).permission?(:read_power)
    
  #  assert users(:sara).permission?(:golden_key)
  #  assert_equal false, users(:sara).permission?(:write_power)
  #end
  
  def test_all_roles
     #assert(true)
     manager_person_one = users(:manager_person_one)
     assert_equal(5, manager_person_one.all_roles.size())
     sales_person_one = users(:sales_person_one)
     assert_equal(2, sales_person_one.all_roles.size())
  end
  
  def test_has_role
  	role = roles(:manager_role)
  	manager_person_one = users(:manager_person_one)
  	assert(manager_person_one.has_role?(role.access_name))
  	assert(manager_person_one.has_role?(role))

	assert( ! manager_person_one.has_role?('non_existant_role'))
  end
  
  def test_permission
     manager_person_one = users(:manager_person_one)
     assert(manager_person_one.permission?('manage_notes'))
     assert(manager_person_one.permission?('create_companies'))
     assert(! manager_person_one.permission?('sysadmin'))
  end
  
  def test_all_permissions
     manager_person_one = users(:manager_person_one)
     # should have manage_notes, create_companies, create_new_users, view_reports
     managers_perms = manager_person_one.all_permissions()
     assert_equal(5, managers_perms.size())
  end
  
  def test_member_of_groups
  	admin = users(:admin)
  	other_groups = Array.new()
  	other_groups << user_groups(:employees_group)
  	other_groups << user_groups(:operations_group)
  	
  	assert(! admin.member_of_groups?(other_groups))
  	
  	operations_person = users(:operations_person_one)
  	half_valid_groups = Array.new()
  	half_valid_groups << user_groups(:operations_group)
  	half_valid_groups << user_groups(:sysadmin_group)
  	
  	assert(operations_person.member_of_groups?(half_valid_groups))
  	
  end
  
  def test_member_of_group
    admin = users(:admin)
  	assert(! admin.member_of_group?(user_groups(:employees_group)))
  	assert(! admin.member_of_group?('Employees'))
  	operations_person = users(:operations_person_one)
  	assert(operations_person.member_of_group?(user_groups(:operations_group)))
  	assert(operations_person.member_of_group?('Operations'))
  end
  
  def test_member_of_groups_with_permission
  	operations_person = users(:operations_person_one)
  	half_valid_groups = Array.new()
  	half_valid_groups << user_groups(:operations_group)
  	half_valid_groups << user_groups(:sysadmin_group)
  	
  	assert(! operations_person.member_of_groups_with_permission?(half_valid_groups, 'sysadmin'))
  	#operations_person is a member_of_groups? here but not of the one 
  	#with sysadmin permission
    assert( operations_person.member_of_groups_with_permission?(half_valid_groups, 'operations_perm'))
    assert( operations_person.member_of_groups_with_permission?(half_valid_groups, ['operations_perm', 'bogus_perm']))
    
  end
  
  def test_has_permission_via_owner_or_groups
  	operations_person = users(:operations_person_one)
  	assert(operations_person.has_permission_via_groups_or_owner?("bogus_perm", operations_person))
  end
  
  def test_owner_of
  	admin = users(:admin)
  	sales_group = user_groups(:sales_group)
	assert(admin.owner_of?(sales_group))
  end
  
  # not testing member_of_groups_with_permission? because
  # member_of_groups? IS tested here and 
  # UserGroup.subset_with_permission is tested in UserGroupTest 
  # which leaves us with a couple simple true false logic tests 
  # in the main code
  
end
