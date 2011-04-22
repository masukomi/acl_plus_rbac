# Similar to the Unix ACL concept except 
# that it isn't limited to one group and 
# it assumes that you will be using RBAC 
# to control WHAT a user can do to the 
# related object instead of specifying 
# read/write/execute bits itself. 
# Please note that the following should be added to environment.rb 
# class ActiveRecord::Base
#
#	def acl
#		return AccessControlList.get_acl(self)
#	end
# end
class AccessControlList < ActiveRecord::Base
    has_and_belongs_to_many :user_groups
    belongs_to :user
	set_table_name 'access_control_lists'
    
    #The object_class column tells us the name of the class 
    #of the object this ACL prevents access to.
    #The object_id column is it's id. By using these 
    #two pieces of information and standard Rails conventions
    #we can retreive the item in question.
	# The assumption, of course, is that the object in question 
	# extends ActiveRecord::Base.
    def get_controlled_object
    	return Object.const_get(object_class).find(object_id)
    end
    
    
    
    def has_access?(test_user)
		return true if user_id == test_user.id
        test_user.all_groups().each do |ug|
			return true if user_groups.include?(ug) 
		end
		return false
    end

	def has_access_via_group?(group, test_user)
		if (group.instance_of?(String))
			group = UserGroup.find_by_name(group)
			return false if (group.nil?)
		end
		#puts("test_user.all_groups().include?(group)==#{test_user.all_groups().include?(group)} AND user_groups.include?(group) == #{user_groups.include?(group)}")
		#user_groups.each do |ug|
		#	puts "ug.name= #{ug.name}"
		#end
		return (test_user.all_groups().include?(group) and user_groups.include?(group))
	end
    
    def owner?(test_user)
    	return test_user.id == self.user_id
    end
    
    
	def self.get_acl_for_object(active_record_object)
		return self.find_acl(active_record_object.class.to_s, active_record_object.id)
	end

	#Returns the ACL object that controls the object indicated by 
    #the object_class and object_id passed in or nil if no matching ACL 
    #is found.
    def self.find_acl(object_class_name, object_id)
        current_acl =  AccessControlList.find(:first, :conditions=>['object_class=? AND object_id=?', object_class_name, object_id])
		if (current_acl.nil?)
			current_acl = AccessControlList.new()
			current_acl.object_class = object_class_name
			current_acl.attributes['object_id'] = object_id
			current_acl.save()
		end
		return current_acl
    end
    
    # Returns an array of objects of the type specified by object_class_name who have 
    # an associated ACL with a user_id matching the one passed in
    def self.get_users_objects(object_class_name, user_id)
        acls = AccessControlList.find(:all, :conditions=>['user_id=? AND object_class=?', user_id, object_class_name])
        if (acls != nil && acls.size() > 0)
	        object_ids = acls.collect{|acl| acl.object_id}
	        if (object_ids != nil && object_ids.size() > 0)
	        	return Object.const_get(object_class_name).find(:all, :conditions=>['id IN (?)', object_ids] )
	        end
        end
        return nil
    end

	# Updates the user_id on all ACL records associated with a given user. This is optionally 
    # limited to records for a specific class.	
	def self.chown(original_user_id, new_user_id, object_class_name = nil)
		#the slow way
#		if (class_name.nil?)
#			acls = AccessControlList.find(:all, :conditions=>['user_id=?', original_user_id])
#		else
#			acls = AccessControlList.find(:all, :conditions=>['user_id=? AND object_class=?', original_user_id, class_name])
#		end
#		num_updated = 0
#		if (! acls.nil?)
#			acls.each do |acl|
#				acl.user_id = new_user_id
#				acl.save()
#				num_updated+=1
#			end
#		end

		#the fast way
		AccessControlList.connection.begin_db_transaction()
		base_update_string = "UPDATE #{self.table_name} SET user_id= #{new_user_id} WHERE user_id = #{original_user_id}"
		if(object_class_name.nil?)
			num_updated = AccessControlList.connection.update(base_update_string, "AccessControlList chown") || 0
		else
			num_updated = AccessControlList.connection.update(base_update_string + " AND object_class='#{object_class_name}'", "#{self.class.name} chown ") || 0
		end
		AccessControlList.connection.commit_db_transaction()
		logger.debug("num records chowned #{num_updated}")
		return num_updated
	end

	def logger
		RAILS_DEFAULT_LOGGER
	end


end


