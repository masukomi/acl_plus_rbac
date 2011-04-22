module AutoAclCreation

	def after_create
		my_acl = AccessControlList.new()
		#my_acl.user_id = self.id
		my_acl.object_id= self.id
		my_acl.object_class = self.class.to_s
		my_acl.save!
	end
end
