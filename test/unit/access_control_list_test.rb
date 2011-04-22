require File.dirname(__FILE__) + '/../test_helper'

class AccessControlListTest < Test::Unit::TestCase
	
	fixtures :access_control_lists, :user_groups, :users, :user_groups_users, :access_control_lists_user_groups
#    table_names = [ 'acl_rbac_access_control_lists',
#                    'acl_rbac_user_groups',
#                    'users',
#                    'acl_rbac_user_groups_users',
#                    'acl_rbac_access_control_lists_user_groups'
#                    ]
#    class_names = {'acl_rbac_access_control_lists' => 'AclPlusRbac::AccessControlList',
#                    'acl_rbac_user_groups'=>'AclPlusRbac::UserGroup'
#                    #'users'=>'User',
#                    #'acl_rbac_user_groups_users',
#                    #'acl_rbac_access_control_lists_user_groups'
#                    
#                    }
#    create_fixtures( 'acl_plus_rbac', table_names, class_names)
    #fixtures_map[table_name] = Fixtures.new(connection, File.split(table_name.to_s).last, class_names[table_name.to_sym], File.join(fixtures_directory, table_name.to_s))
    
	# Replace this with your real tests.
	def test_truth
		assert true
	end

	def test_active_record_acl
		#operations_person_one = users(:operations_person_one)
		sales_group = user_groups(:sales_group)
		assert sales_group.acl != nil
	end

	def test_access_restricted
		sales_group = user_groups(:sales_group)
		assert sales_group.access_restricted?
	end

	def test_has_access
		operations_person_one = users(:operations_person_one)
		# should have no access to the sales user group
		sales_group = user_groups(:sales_group)
		assert_equal(false, sales_group.acl.has_access?(operations_person_one))
		# they should be able to access the operations group
		operations_group = user_groups(:operations_group)
		assert(operations_group.acl.has_access?(operations_person_one))
		# they should be able to access the agents group
		# because members of operations_group are indirectly 
		# members of employees and employees should be able to access 
		# the agents group
		agents_group = user_groups(:agents_group)
		assert(agents_group.acl.has_access?(operations_person_one))
	end

	def test_chown
		operations_person_one = users(:operations_person_one)
		# should have no access to the sales user group
		sales_group = user_groups(:sales_group)
		assert_equal(false, sales_group.acl.has_access?(operations_person_one))
		AccessControlList.chown(1,operations_person_one.id) #1 is admin 
		sales_group = user_groups(:sales_group) #need to reload it 
		#TODO add an .reload_acl method
		sales_acl = AccessControlList.find(sales_group.acl.id)
		assert_equal(true, sales_acl.has_access?(operations_person_one))
		AccessControlList.chown(operations_person_one.id, 1) #reset it to starting point 
		sales_acl = AccessControlList.find(sales_group.acl.id)
		
		assert_equal(false, sales_acl.has_access?(operations_person_one))
		AccessControlList.chown(1,operations_person_one.id, 'UserGroup') #see if it works when specifying a group too 
		sales_acl = AccessControlList.find(sales_group.acl.id)
		
		assert_equal(true, sales_acl.has_access?(operations_person_one))
		AccessControlList.chown(operations_person_one.id, 1) #reset it to starting point 
	end
end
