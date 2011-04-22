require File.dirname(__FILE__) + '/../test_helper'

class UserGroupTest < Test::Unit::TestCase
	fixtures :users, :user_groups, :user_groups_users, :roles, :roles_user_groups, :permissions, :role_permissions
	
	def test_parent_child_relationships
	    super_group = user_groups(:super_group)
		assert_equal(2, super_group.child_groups.size())
		sub_group_a = user_groups(:sub_group_a)
		assert(sub_group_a.parent_group != nil)
		assert(super_group.child_groups.include?(sub_group_a))
		sub_group_b = user_groups(:sub_group_b)
		assert(sub_group_b.parent_group != nil)
		assert(1, sub_group_b.child_groups.size())
		sub_group_b_sub_group=user_groups(:sub_group_b_sub_group)
		assert(sub_group_b_sub_group.parent_group != nil)
	end
	
	def test_all_roles
		super_group = user_groups(:super_group)
		# just the roles of super_group
		#assert_equal('Role', super_group.roles.class_name)
		#assert_equal('super_group_role', super_group.roles[0].name)
		assert_equal(1, super_group.roles.size())
		assert_equal('super_group_role', super_group.all_roles[0].name)
		sub_group_a = user_groups(:sub_group_a)
		sub_group_a_roles = %w{sub_group_a_role super_group_role}
		# roles of sub_group_a AND super_group
		assert_equal(2, sub_group_a.all_roles.size())
		sub_group_a_distinct_role_names = Array.new()
		sub_group_a.all_roles.each do |role|
		  assert(sub_group_a_roles.include?(role.name))
		  if (! sub_group_a_distinct_role_names.include?(role.name))
		      sub_group_a_distinct_role_names << role.name
		  end
		end
		assert_equal(2, sub_group_a_distinct_role_names.size())
		
		sub_group_b = user_groups(:sub_group_b)
		sub_group_b_roles = %w{sub_group_b_role super_group_role}
		# roles of sub_group_b AND super_group
		assert_equal(2, sub_group_b.all_roles.size())
		#assert_equal(1, sub_group_b.roles)
		sub_group_b.all_roles.each do |role|
		  assert(sub_group_b_roles.include?(role.name))
		end
		sub_group_b_sub_group=user_groups(:sub_group_b_sub_group)
		sub_group_b_sub_group_roles = %w{sub_group_b_sub_group_role sub_group_b_role super_group_role}
		# roles of sub_group_b_sub_group AND sub_group_b AND super_group
		assert_equal(3, sub_group_b_sub_group.all_roles.size())
		sub_group_b_sub_group.all_roles.each do |role|
		  assert(sub_group_b_sub_group_roles.include?(role.name))
		end
		
		
		assert(1, sub_group_b_sub_group.roles.size())
	end
	
	def test_permission
	   employees_group = user_groups(:employees_group)
	   assert(employees_group.permission?('manage_notes'))
	   assert(! employees_group.permission?('sysadmin'))
	end
	
	def test_all_users
	   employees_group = user_groups(:employees_group)
	   all_employees = employees_group.all_users
	   
	   operations_person_one = users(:operations_person_one) 
	       #employee via subgroup
	   assert(all_employees.include?(operations_person_one))
	   manager_person_one = users(:manager_person_one)
	       #directly associated to employees
	   assert(all_employees.include?(manager_person_one))
	end
	
	def test_is_child_of
	   sales_group = user_groups(:sales_group)
	   employees_group = user_groups(:employees_group)
	   assert(sales_group.is_child_of?(employees_group))
	   assert(! employees_group.is_child_of?(sales_group))
	end
	
	def test_subset_with_permission
		user_groups = UserGroup.find(:all)
		sysadmin_subset = UserGroup.subset_with_permission(user_groups, 'sysadmin')
		assert_equal(1, sysadmin_subset.size())
	end
end
