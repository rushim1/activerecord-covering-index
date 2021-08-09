require "bundler/setup"
require "activerecord-covering-index"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      host: ENV['POSTGRES_HOST'] || 'localhost',
      username: 'postgres',
      password: 'postgres',
      database: 'activerecord-covering-index_test'
    )

    ActiveRecord::Base.connection.create_table :users do |t|
      t.string :name
      t.string :email
      t.timestamps
    end
  end

  config.after(:suite) do
    ActiveRecord::Base.connection.drop_table :users
  end
end
