require File.dirname(__FILE__) + '/../test_helper'

class ActiveRecordBaseTest < Test::Unit::TestCase

	fixtures :user_groups, :roles, :permissions, :role_permissions, :roles_user_groups, :users, :user_groups_users, :user_roles, :access_control_lists, :access_control_lists_user_groups
	
	def test_owner
		admin = users(:admin)
		
		sales_group = user_groups(:sales_group)
		assert(sales_group.owned_by?(admin))
		assert(admin.owner_of?(sales_group))
		
	  	operations_person = users(:operations_person_one)
	  	
	  	assert(! sales_group.owned_by?(operations_person))
	  	
	  	assert(operations_person.owner_of?(operations_person))
	  	#ops person owns themself via an acl
	  	
	  	#TODO also test ActiveRecord::Base for owner?(user)
	end

	def test_has_access_via_group
		#sales_person_one is a member of the sales_group
		sales_person_one = users(:sales_person_one)
		sales_person_two = users(:sales_person_two)
	    #sales_person_two is a member of the sales_group
		sales_group = user_groups(:sales_group)
		#thus some_active_record_object.has_access_via_group?(group, some_user)
		assert sales_person_one.has_access_via_group?(sales_group, sales_person_two)	
		assert(! sales_person_one.has_access_via_group?('operations_group', sales_person_two))	
		operations_person = users(:operations_person_one)
		assert(! operations_person.has_access_via_group?(sales_group, sales_person_two))
	end
  
end
