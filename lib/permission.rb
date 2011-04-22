class Permission < ActiveRecord::Base
	#has_many :role_permissions, :dependent => :destroy
	#has_many :roles, :through => :role_permissions


	has_and_belongs_to_many :roles, :join_table=>'role_permissions'


	class <<self
		def add(perm_name, new_access_name)
			return :duplicate unless Permission.find_by_name(perm_name).nil? or Permission.find_by_access_name(new_access_name).nil?
			
			newperm = Permission.new do |r|
				r.name = perm_name
				r.access_name = new_access_name
			end
			
			newperm.save
			newperm
		end
		
		def remove(perm_access_name)
			return :not_found if (oldperm = Permission.find_by_access_name(perm_access_name)).nil?
			
			oldperm.destroy
		end
	end
end
