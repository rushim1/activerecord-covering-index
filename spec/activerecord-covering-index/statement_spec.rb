require 'spec_helper'

RSpec.describe 'statements' do
  let(:connection) { ActiveRecord::Base.connection }

  before(:all) do
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
      def execute(sql, name = nil) sql.squeeze(' ') end
    end
  end

  after(:all) do
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
      remove_method :execute
    end
  end

  describe '#add_index' do
    context 'single non-key column' do
      let(:expected) { %(CREATE INDEX "index_users_on_name" ON "users" ("name") INCLUDE ("email")) }

      it { expect(connection.add_index(:users, :name, include: :email)).to eq(expected) }
      it { expect(connection.add_index(:users, :name, include: [:email])).to eq(expected) }
      it { expect(connection.add_index(:users, :name, include: ['email'])).to eq(expected) }
    end

    context 'multiple non-key columns' do
      let(:expected) { %(CREATE INDEX "index_users_on_name" ON "users" ("name") INCLUDE ("email", "id")) }

      it { expect(connection.add_index(:users, :name, include: [:email, :id])).to eq(expected) }
      it { expect(connection.add_index(:users, :name, include: ['email', :id])).to eq(expected) }
      it { expect(connection.add_index(:users, :name, include: %w(email id))).to eq(expected) }
    end

    context 'single string literal non-key column' do
      let(:expected) { %(CREATE INDEX "index_users_on_name" ON "users" ("name") INCLUDE (email)) }

      it { expect(connection.add_index(:users, :name, include: 'email')).to eq(expected) }
    end

    context 'multiple string literal non-key columns' do
      let(:expected) { %(CREATE INDEX "index_users_on_name" ON "users" ("name") INCLUDE (email, id)) }

      it { expect(connection.add_index(:users, :name, include: 'email, id')).to eq(expected) }
    end

    if ActiveRecord.version >= Gem::Version.new('6.1.0')
      context 'with additional index options' do
        let(:expected) { %(CREATE INDEX CONCURRENTLY IF NOT EXISTS "custom_index_name" ON "users" USING btree (lower(name)) INCLUDE ("email") WHERE email IS NOT NULL) }

        it { expect(connection.add_index(:users, 'lower(name)', where: 'email IS NOT NULL', algorithm: :concurrently, if_not_exists: true, include: :email, using: :btree, name: 'custom_index_name')).to eq(expected) }
      end
    else
      context 'with additional index options' do
        let(:expected) { %(CREATE INDEX "custom_index_name" ON "users" USING btree (lower(name)) INCLUDE ("email") WHERE email IS NOT NULL) }

        it { expect(connection.add_index(:users, 'lower(name)', where: 'email IS NOT NULL', include: :email, using: :btree, name: 'custom_index_name')).to eq(expected) }
      end
    end
  end
end
