require 'spec_helper'

RSpec.describe 'schema' do
  before(:all) do
    ActiveRecord::Base.connection.change_table :users do |t|
      t.index :name, include: :email, where: 'email is not null'
      t.index :name, include: ['id'], name: 'custom_index_name', comment: 'comment_on_index'
      t.index [:name, :created_at], include: [:email, :id]
      t.index 'id, lower(name)', unique: true, include: [:created_at]
      t.index 'lower(name), created_at', include: 'id, updated_at'
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.change_table :users do |t|
      t.remove_index name: 'index_users_on_name'
      t.remove_index name: 'index_users_on_name_and_created_at'
      t.remove_index name: 'index_users_on_id_lower_name'
      t.remove_index name: 'index_users_on_lower_name_created_at'
      t.remove_index name: 'custom_index_name'
    end
  end

  subject do
    stream = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    stream.string
  end

  it { is_expected.to include(%(t.index ["name"], name: "index_users_on_name", where: "(email IS NOT NULL)", include: ["email"])) }
  it { is_expected.to include(%(t.index ["name"], name: "custom_index_name", comment: "comment_on_index", include: ["id"])) }
  it { is_expected.to include(%(t.index ["name", "created_at"], name: "index_users_on_name_and_created_at", include: ["email", "id"])) }
  it { is_expected.to include(%(t.index "id, lower((name)::text)", name: "index_users_on_id_lower_name", unique: true, include: ["created_at"])) }
  it { is_expected.to include(%(t.index "lower((name)::text), created_at", name: "index_users_on_lower_name_created_at", include: ["id", "updated_at"])) }
end
