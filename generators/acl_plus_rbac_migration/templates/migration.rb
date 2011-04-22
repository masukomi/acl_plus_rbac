class CreateAclPlusRbacTables < ActiveRecord::Migration
    def self.up

		
		create_table "roles", :force => true do |t|
			
			t.column :access_name,  :string, :limit => 40
			# an access_name is really only required for 
			# roles that are integral to the business logic 
			# of your app and will be hard-coded into it.
			# Otherwise roles tend to be dynamically 
			# loaded by id.
			t.column :name,			:string, :limit => 40
			t.column :description,  :text, :null=>false
		end
		
		create_table "permissions", :force => true do |t|
			t.column :name,						 	:string, :limit => 40
			t.column :access_name,					:string, :limit => 40
		end
		
		create_table "user_roles", :force => true,:id => false do |t|
			t.column :user_id,					:integer, :default => 0
			t.column :role_id,					:integer, :default => 0
		end
		
		create_table "role_permissions", :force => true, :id => false do |t|
			t.column :role_id,					:integer, :default => 0
			t.column :permission_id,		:integer, :default => 0
		end
		
		create_table "user_groups", :force => true do |t|
			t.column :name,				:string, :null=>true
			t.column :parent_group_id,   :integer, :null=>true
		end
		
		create_table "user_groups_users", :force => true, :id => false do |t|
			t.column :user_id,			:integer, :null=>false
			t.column :user_group_id,	:integer, :null=>false
		end

		create_table "roles_user_groups", :force=> true, :id => false do |t|
			t.column :role_id, 			:integer, :null=>false
			t.column :user_group_id, 	:integer, :null=>false
		end
		
		
		create_table :access_control_lists do |t|
          # t.column :name, :string
          t.column :user_id,        :integer,   :null=>true
          t.column :object_id,      :integer,   :null=>false
          t.column :object_class,   :string,    :null=>false
        end
        
        create_table :access_control_lists_user_groups, :id => false do |t|
            t.column :access_control_list_id, :integer, :null=>false
            t.column :user_group_id, :integer, :null=>false
        end

		%w{users roles user_roles permissions role_permissions user_groups user_groups_users }.each do | fixture | 
			begin 
				Fixtures.create_fixtures('db/initial_data', fixture)
			rescue

			end
		end
	end

  def self.down
    drop_table :roles
    drop_table :permissions
    drop_table :user_roles
    drop_table :role_permissions
    drop_table :user_groups
	drop_table :user_groups_users
	drop_table :roles_user_groups
    drop_table :access_control_lists
    drop_table :access_control_lists_user_groups
  end

end
