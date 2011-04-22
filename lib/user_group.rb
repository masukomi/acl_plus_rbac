class UserGroup < ActiveRecord::Base
	has_and_belongs_to_many :roles, :join_table=>'roles_user_groups', :foreign_key=>'user_group_id'
	has_and_belongs_to_many :users, :join_table=>'user_groups_users'
	has_and_belongs_to_many :access_control_lists
	belongs_to :parent_group, :class_name=>'UserGroup', :foreign_key=>'parent_group_id'
	has_many :child_groups, :class_name=>'UserGroup', :foreign_key=>'parent_group_id'
	#belongs_to :owner, :class_name=>'User', :foreign_key=>'owner_id'
	
	# Brings together all of this groups roles plus all the roles of 
	# it's parent in no particular order and without duplicates.

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
       	
		return false
    end
	def all_roles
		all_my_roles = Array.new()
		roles.each do |role|
			all_my_roles << role
		end
		if (parent_group != nil)
			parent_group.all_roles.each do | role | 
				if (! all_my_roles.include?(role))
					all_my_roles << role
				end
			end
		end
		return all_my_roles
	end
	
	def permission?(check_permission)
		all_roles.each do |role|
			return true if role.permission?(check_permission)
		end
		return false
	end
	
	def all_users
		all_my_users = Array.new()
		users.each do |user|
			all_my_users << user
		end
		if (child_groups != nil)
			child_groups.each do | group | 
				group.all_users.each do | user | 
					if (! all_my_users.include?(user))
						all_my_users << user
					end
				end
			end
		end
		return all_my_users
	end
	
	# Warning. This may have unforseen consequences. The 
	# user may be removed from a subgroup that you really don't 
	# want them removed from. Of coulse that would indicate 
	# a poor group heirarchy.
	def remove_user_completely(user)
	   if (not users.nil? and users.include?(user))
		   users.delete(user)
	   end
	   if (not child_groups.nil?)
		   child_groups.each do | group | 
			   group.remove_user_completely(user)
		   end
	   end
	end
	
	def includes_user?(user)
	   return all_users.include?(user)
	end
	
	# returns true if this group is a child of the 
	# group passed in.
	# useful to prevent recursive groupings
	def is_child_of?(user_group)
		parent = parent_group
		while(parent != nil)
			if (parent.id == user_group.id)
				return true
			end
			parent = parent.parent_group
		end
	end
	
	def all_super_groups
		all_my_super_groups = Array.new()
		if (parent_group != nil)
			all_my_super_groups << parent_group
			parent_group.all_super_groups.each do | sg |
				if (! all_my_super_groups.include?(sg))
					#theoretically recursion can't happen
					#but just in case
					all_my_super_groups << sg
				end
			end
		end
		return all_my_super_groups
	end


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

	# Takes an array of UserGroups and returns the subset of 
	# that list that has the specified permission 
	def self.subset_with_permission(user_groups_array, permission)
		subset = Array.new()
		if (! user_groups_array.nil? and user_groups_array.size() > 0 and permission != nil)
			user_groups_array.each do | ug | 
				if (ug.permission?(permission))
					subset << ug
				end
			end
		end
		return subset
	end
	
end
