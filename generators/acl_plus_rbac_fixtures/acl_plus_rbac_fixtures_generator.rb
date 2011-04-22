class AclPlusRbacFixturesGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    #@user_table_name = (runtime_args.length < 2 ? 'users' : runtime_args[1]).tableize
    runtime_args << 'create_acl_plus_rbac_tables' if runtime_args.empty?
    super
  end

  def manifest
    record do |m|
            
      fixtures = ['access_control_lists_user_groups.yml',
                    'access_control_lists.yml',
                    'permissions.yml',
                    'role_permissions.yml',
                    'roles_user_groups.yml',
                    'roles.yml',
                    'user_groups_users.yml',
                    'user_groups.yml',
                    'user_roles.yml',
                    'users.yml'
                    ]
      fixtures.each do |fixture|
        m.template "test/fixtures/#{fixture}",
                  File.join('test/fixtures',
                            fixture)
      end
    end
  end
end