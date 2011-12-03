require 'access_control_list'
require 'permission'
require 'user_group'
require 'acl_plus_rbac_user'
require 'acl_plus_rbac_base'


#class ActiveRecord::Base
#	
#	def acl
#		if (@acl_obj.nil?)
#			@acl_obj = AccessControlList.get_acl_for_object(self)
#		end
#		return @acl_obj
#	end
#	
#	#Returns true if this object is access restricted and 
#	#the AccessControlList's user_id is that of the user passed in.
#	def owned_by?(user)
#		if (access_restricted?)
#			return self.acl.owner?(user)
#		end
#		return false
#	end
#
#	def is_owned?
#		if self.access_restricted? and not self.acl.user_id.nil? and self.acl.user_id != 0
#			return true
#		end
#		return false
#	end
#
#	def access_restricted?
#		return self.acl != nil 
#	end
#	
#	def has_access?(user)
#		if (self.access_restricted?)
#			return self.acl.has_access?(user)
#		end
#		return true
#	end
#
#	def has_access_via_group?(group, user)
#		if (self.access_restricted?)
#			return self.acl.has_access_via_group?(group, user)
#		end
#		return true	
#	end
#end

#require 'user'
#class User # < ActiveRecord::Base
#    include AclPlusRbac::User
#    has_and_belongs_to_many :roles, :class_name=>"AclPlusRbac::Role", :join_table=>'acl_rbac_user_roles'
#    has_and_belongs_to_many :user_groups, :class_name=>"AclPlusRbac::UserGroup", :join_table=>'acl_rbac_user_groups_users'
#end 
