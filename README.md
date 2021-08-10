# WipeOut

Library for removing and clearing data in Rails ActiveRecord models.

## Installation

1. Add WipeOut to your application's Gemfile:

```ruby
gem "wipe_out", "~> 1.0"
```

Check newest release at [here](https://rubygems.org/gems/wipe_out).

## Usage

Quick example:

Given the following model:

```ruby
# == Schema Info
#
# Table name: users
#
#  id                  :integer(11)    not null, primary key
#  name                :varchar(11)    not null
#  orders_count        :integer(11)    not null
class User < ActiveRecord::Base
end

```

We can define custom wipe out plan:

```ruby
UserWipeOutPlan = WipeOut.build_plan do
  wipe_out :name
  ignore :orders_count
end
```

and execute it:

```ruby
User.last.then { |user| UserWipeOutPlan.execute(user) }
```

It will overwrite data inside `name` but leave, `orders_count` untouched.

There is also support for relations and making sure that policies are defined
for any added columns.

Read more in [getting started](./docs/getting_started.md) doc.

## Contributing && Development

See [development.md](./docs/development.md)
