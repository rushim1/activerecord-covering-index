require 'spec_helper'

RSpec.describe ActiverecordCoveringIndex do
  class AddCoveringIndex < ActiveRecord::Migration::Current
    def write(*); end

    def change
      add_index :users, [:name, :id], include: [:email, :created_at]
    end
  end

  let(:migration) { AddCoveringIndex.new }

  it 'is reversible' do
    migration.migrate :up
    index = migration.indexes(:users).first

    expect(index.name).to eq('index_users_on_name_and_id')
    expect(index.include).to eq(["email", "created_at"])

    migration.migrate :down
    expect(migration.indexes(:users)).to be_empty
  end
end
