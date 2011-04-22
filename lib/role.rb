class Role < ActiveRecord::Base
	
	#has_and_belongs_to_many :coaches, :join_table=>“squads_coaches”, :class_name=>“Coach”, :table_name=>“coaches”
	has_and_belongs_to_many :permissions, 	:join_table=>'role_permissions'
	has_and_belongs_to_many :users, 		:join_table=>'user_roles'
	has_and_belongs_to_many :user_groups, 	:join_table=>'roles_user_groups', :foreign_key=>'role_id'

	def permission?(check_permission)
		check_permission = check_permission.instance_of?(Permission) ? check_permission.access_name : check_permission
		return !self.permissions.detect { |perm| perm.access_name == check_permission }.nil?
	end
	
	class <<self
		def add(role_name)
			return :duplicate unless Role.find_by_name(role_name).nil?
			
			newrole = Role.new do |r|
				r.name = role_name
			end
			
			newrole.save
			newrole
		end
		
		def remove(role_name)
			return :not_found if (oldrole = Role.find_by_name(role_name)).nil?
			
			oldrole.destroy
		end
	end
end
