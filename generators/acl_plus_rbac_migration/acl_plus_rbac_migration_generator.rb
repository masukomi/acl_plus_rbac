class AclPlusRbacMigrationGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    #@user_table_name = (runtime_args.length < 2 ? 'users' : runtime_args[1]).tableize
    runtime_args << 'create_acl_plus_rbac_tables' if runtime_args.empty?
    super
  end

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate'
      
    end
  end
end