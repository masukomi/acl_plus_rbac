module AclPlusRbacUser
    #class User < ActiveRecord::Base
        
        def has_permission?(check_permission)
			return permission?(check_permission)
		end
    	def permission?(check_permission)
			return false if check_permission.nil?
    		all_roles().each do |role| 
    			return true if role.permission?(check_permission)
    		end
    		return false
    	end
    	
    	# Returns a list of all the groups this user belongs to
    	# and all of their parent groups. May generate a large 
    	# number of database calls.
    	def all_groups
    		all_my_groups = Array.new()
    		user_groups.each do |ug|
    			all_my_groups << ug
    			if (! all_my_groups.include?(ug.parent_group))
    				ug.all_super_groups.each do |sg |
    					if (! all_my_groups.include?(sg))
    						all_my_groups << sg
    					end
    				end
    			end
    		end
    		return all_my_groups
    	end
    	
    	# Returns true if the user is a member of one or more 
    	# of the groups in the specified list
    	def member_of_groups?(group_list)
    		return false if (group_list.nil? or group_list.size()==0 or all_groups.nil? or all_groups.size() == 0)
    		if (group_list.size() < all_groups.size() )
    			group_list.each do | group |
    				return true if user_groups.include?(group)
    			end
    		else
    			all_groups.each do | group |
    				return true if group_list.include?(group)
    			end
    		end
    		return false
    	end
    	
    	# Returns true if the user is a member of the 
    	# specified group or one of its subgroups
    	def member_of_group?(group)
			return false if group.nil?
			if (group.instance_of?(String))
				group = UserGroup.find_by_name(group)
				return false if group.nil?
			end
			return group.includes_user?(self)
    	end
    	
    	# Returns true if any of the groups in the specified group_list
    	# has the specified permission and this user is a member of 
    	# one of those groups. Permission can optionally be an array of 
    	# permissions. Use this when having any ONE of the permissions 
    	# is acceptable. This will not test if the user has ALL of the
    	# permissions in the list.
    	def member_of_groups_with_permission?(groups_list, permission)
			return false if groups_list.nil? or permission.nil?
    		if ! permission.instance_of?(Array)
    			groups = UserGroup.subset_with_permission(groups_list, permission)
    		else
    			groups = Array.new
    			permission.each do |perm|
    				UserGroup.subset_with_permission(groups_list, perm).each do |group|
    					if (! groups.include?(group))
    						groups << group
    					end
    				end
    			end
    		end
    		
    		return member_of_groups?(groups)
    	end
    	
    	
    	# This verbosely named method returns true if this user has access to 
    	# the current object 
    	# and is a member of one of the groups in it's ACL (if any) that 
    	# has that permission or they are the user associated with the acl.
    	# 
    	# If the object has no associated groups this will return false
    	# even if one of the user's groups/roles has this permission. This 
    	# will also return false if the object is not access_restricted
    	# 
    	# This is useful when you have an object that should only be be 
    	# accessed by it's owner or someone in it's groups with that 
    	# permission
    	# 
    	# This can optionally take an array of permissions. See 
    	# member_of_groups_with_permission?(group_list, permission) for details.
    	def has_permission_via_groups?(permission, object)
			return false if permission.nil? or object.nil?
    		if (object.access_restricted? && object.has_access?(self))
    			return member_of_groups_with_permission?(object.acl.user_groups, permission)
    		end
    		return false
    	end
    	
    	#Just like has_permission_via_groups except it will 
    	#return true if the user is the owner of the object regardless
    	#of permissions
    	def has_permission_via_groups_or_owner?(permission, object)
			return false if permission.nil? or object.nil?
    		if (object.access_restricted? && object.has_access?(self))
    			if (object.acl.owner?(self))
    				return true
    			else
    				return member_of_groups_with_permission?(object.acl.user_groups, permission)
    			end
    		end
    		return false
    	end
    	
    	
    	# Brings together all of this groups roles plus all the roles of 
        # it's groups in no particular order and without duplicates.
        def all_roles
            all_my_roles = Array.new()
            roles.each do |role|
                all_my_roles << role
            end
            user_groups.each do |group|
                group.all_roles.each do |role|
                    if (! all_my_roles.include?(role))
                        all_my_roles << role
                    end
                end
            
            end
            return all_my_roles
        end
        
        # associates the specified role with this user
        # IF the user doesn't have it already.
        def assign_role(role)
        	return if role.nil?
			if (role.instance_of?(String))
                                db_role = Role.find_by_access_name(role)
                                raise "Unknown Role #{role}" if db_role.nil?
				role = db_role
                        end

			if (! has_role?(role.name))
        		self.roles << role
        	end
        end
        
        # Takes a Role or the access_name of a role.
        # It then tests if the incoming access_name
        # matches the name of any of the roles 
        # associated with this user either directly 
        # or via ANY of their groups. 
        def has_role?(role_access_name)
			return false if role_access_name.nil?
        	if role_access_name.instance_of?(Role)
        		role_access_name = role_access_name.access_name
        	end
        		
        	
        	# yes i *could* just loop through the results of all_roles
        	# but that would generally require many more lookups        	
        	roles.each do |role|
                return true if role.access_name == role_access_name
            end
            user_groups.each do |group|
                group.all_roles.each do |role|
                    return true if role.access_name == role_access_name
                end
            end
        	return false
        end
        
        def all_permissions
            all_my_permissions = Array.new()
            all_roles().each do | role | 
                role.permissions.each do | perm |
                    all_my_permissions << perm unless all_my_permissions.include?(perm)
                end
            end
            return all_my_permissions
        end
        
        # Takes an ActiveRecord::Base derived object and returns true
        # IF if it is access restricted and the user_id matches the id 
        # of this User object
        def owner_of?(model)
			return false if model.nil?
        	if (model.access_restricted?)
        		return model.acl.owner?(self)
        	end
        	return false
        end
    
    	
    #end
end
