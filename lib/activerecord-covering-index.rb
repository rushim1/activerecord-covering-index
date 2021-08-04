require 'active_record'
require "active_record/connection_adapters/postgresql_adapter"

require 'activerecord-covering-index/version'
require 'activerecord-covering-index/abstract_adapter'
require 'activerecord-covering-index/postgresql_adapter'
require 'activerecord-covering-index/schema_creation'
require 'activerecord-covering-index/index_definition'
require 'activerecord-covering-index/schema_dumper'

ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, ActiverecordCoveringIndex::AbstractAdapter)
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:prepend, ActiverecordCoveringIndex::PostgreSQLAdapter)
ActiveRecord::ConnectionAdapters::SchemaCreation.send(:prepend, ActiverecordCoveringIndex::SchemaCreation)
ActiveRecord::ConnectionAdapters::IndexDefinition.send(:prepend, ActiverecordCoveringIndex::IndexDefinition)
ActiveRecord::SchemaDumper.send(:prepend, ActiverecordCoveringIndex::SchemaDumper)
