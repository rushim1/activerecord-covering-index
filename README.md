# activerecord-covering-index

Extends ActiveRecord/Rails to support [covering indexes](https://www.postgresql.org/docs/11/indexes-index-only-scans.html) in PostgreSQL using the `INCLUDE` clause.

From the [PostgreSQL documentation](https://www.postgresql.org/docs/11/sql-createindex.html):

> The optional INCLUDE clause specifies a list of columns which will be included in the index as non-key columns. A non-key column cannot be used in an index scan search qualification, and it is disregarded for purposes of any uniqueness or exclusion constraint enforced by the index. However, an index-only scan can return the contents of non-key columns without having to visit the index's table, since they are available directly from the index entry. Thus, addition of non-key columns allows index-only scans to be used for queries that otherwise could not use them.

## Compatibility

- ActiveRecord 5.2, 6.0 and 6.1
- PostgreSQL 11 and later

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-covering-index'
```

And then execute:

    $ bundle install

## Usage

In a migration, use the `include` option with `add_index`:

```ruby
class IndexUsersOnName < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :name, include: :email
  end
end
```

Or within a `create_table` block:

```ruby
class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.timestamps

      t.index :name, include: :email
    end
  end
end
```

You can also `include` multiple columns:

```ruby
add_index :users, :name, include: [:email, :updated_at]
```

Or combine `include` with other index options:

```ruby
add_index :users, :name, include: :email, where: 'email IS NOT NULL', unique: true
```

## Caveats

Non-key columns are not included in the name Rails generates for an index. For example, the following two indexes will receive the same name, which causes the second to raise a `PG::DuplicateTable` error:

```ruby
add_index :users, :name
add_index :users, :name, include: :email
```

To avoid collisions, you can specify a different name:

```ruby
add_index :users, :name, include: :email, name: 'index_users_on_name_include_email'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and merge requests are welcome on GitLab at https://gitlab.com/schlock/activerecord-covering-index.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

The gem was adapted from https://github.com/rails/rails/pull/37515, created by [@sebastian-palma](https://github.com/sebastian-palma).
