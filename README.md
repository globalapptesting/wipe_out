# WipeOut

Library for removing and clearing data using ActiveRecord.

Removal strategy definition is called _Plan_. _Plan_ is created using DSL.
Top level _Plan_ is called _Root Plan_ and can be validated against database schema
and executed on records.

_Plan_ defines a list of attributes and relations to clear.
Relations work as nested _Plans_ and can be nested infinitely.

_Root Plan_ is a plan that binds _Plan_, Active Record class and other settings.

Given schema:
```ruby
create_table "users" do |t|
  t.string "first_name"
  t.string "last_name"
  t.string "reset_password_token"
  t.string "access_tokens"
  t.datetime "confirmed_at"
  t.integer "sign_in_count"
end

create_table "comments" do |t|
  t.integer "user_id"
  t.string "value"
end

create_table "files" do |t|
  t.integer "comment_id"
  t.integer "file_id"
end

create_table "dashboards" do |t|
  t.integer "user_id"
  t.string "order"
end
```

and models
```ruby
class User < ActiveRecord::Base
 has_many :comments
 has_one :dashboard
end

class Comment < ActiveRecord::Base
  has_many :files
end

class File < ActiveRecord::Base; end
class Dashboard < ActiveRecord::Base; end
```

an example of _Root Plan_ and its _Plan_ is:

```ruby
UserWipeOutPlan = WipeOut.build_root_plan(User) do
   # Set nil value by default
   attributes :first_name, :last_name
   # Custom strategy
   attributes :sign_in_count, strategy: WipeOut::AttributeStrategies::ConstValue.new(0)
   # Inline custom strategy
   attributes :reset_password_token do
     "random-value-#{SecureRandom.hex}"
   end

   # has_many relation
   relation :comments do
     # Behaves like nested Plan.
     attribute :value, strategy: WipeOut::AttributeStrategies::Randomize.new

     relation :files do
       destroy! # Calls destroy on records
     end
   end

   # has_one relation
   relation :dashboard do
      attribute :order
      ignore :name
   end

   # Ignore is used to mark both ignored relations
   # and ignored attributes
   ignore :access_tokens, :confirmed_at
end
```

After executing on a record
```ruby
record = User.last
UserWipeOutPlan.execute(record)
```

User's:
* `first_name` and `last_name` attributes are set to `nil` value
* `sign_in_count` is set to `0`
* `reset_password_token` is randomized
* `access_tokens` and `confirmed_at` attributes are not changed

User's Comments:
* `value` is randomized
* Comment's files are all destroyed

User's dashboard:
* `order` attribute is set to `nil`
* `name` attribute is ignored

## Validation

_Root Plans_ can be validated against DB schema:
```ruby
UserWipeOutPlan.validation_errors
```

Method returns an array of error strings. When Root Plan is valid then the array is empty.

When new attribute is added to schema
or a new relation is added to model
that is used in _Root Plan_ then validation will fail.

### Ignoring

Every relation or attribute which is not part of removal plan
has to be marked as ignored with `ignore`.

`through` and `belongs_to` relations are ignored automatically and they don't have to be ignored manually.

By default these attributes are ignored:
* `id`
* `created_at`
* `updated_at`
* `archived_at`

Example:
Given schema
```ruby
create_table "users" do |t|
  t.string "first_name"
  t.string "last_name"
  t.integer "company_id"
  t.datetime "created_at"
  t.datetime "updated_at"
end
```
and class
```ruby
class User < ActiveRecord::Base
  belongs_to :company
  has_many :comments
  has_one :dashboard
  has_many :files, through: :comments
end
```

a _Plan_ to handle removing of this object has to provide strategy or ignore:
* attributes:
  * `first_name`
  * `last_name`
  * `company_id`
* relations:
  * `comments`
  * `dashboard`

_Plan_ can skip providing strategy for:
* attributes `id`, `created_at`, `updated_at` - ignored by default
* relation `company` - `belongs_to` relation
* relation `files` - through relation

## Reusing _Plans_

### Extracting

Nested plans can be extracted as independent object. An exemplary plan can be rewritten to:
```ruby
CommentsWipeOutPlan = WipeOut.build_root_plan(Comment) do
  attribute :value, strategy: WipeOut::AttributeStrategies::Randomize.new

  relation :files do
   destroy!
  end
end

DashboardWipeOutPlan = WipeOut.build_plan do
  relation :dashboard do
    attribute :order
    ignore :name
  end
end

UserWipeOutPlan = WipeOut.build_root_plan(User) do
  # …
  relation :comments, CommentsWipeOutPlan
  relation :dashboard, DashboardWipeOutPlan
  # …
end
```

### Including

_Plan_ can be included to other existing _Plan_. When _Plan_ is included then
its strategy is copied and extends current definition.

E.g.

```ruby
HasAttachmentsPlan = WipeOut.build_plan do
  relation(:images) { destroy! }
  relation(:videos) { destroy! }
  wipe_out :attachments_count
end

WipeOut.build_root_plan(User) do
  include_plan HasAttachmentsPlan
  relation(:comments) do
    wipe_out :content
    include_plan HasAttachmentsPlan
  end
end
```

is exactly the same as:
```ruby
WipeOut.build_root_plan(User) do
  relation(:images) { destroy! }
  relation(:videos) { destroy! }
  wipe_out :attachments_count
  relation(:comments) do
    wipe_out :content
    relation(:images) { destroy! }
    relation(:videos) { destroy! }
    wipe_out :attachments_count
  end
end
```

### Difference between _Root Plan_ and _Plan_

_Plans_ created using `WipeOut.build_plan` are not _Root Plans_. They can be nested
or used as a fragment for including in other _Plans_ or _Root Plans_, but
opposed to _Root Plans_ they can't be validated or executed alone, without a _Root Plan_.
They are meant to be used as non executable fragments used by _Root Plans_.

It is possible to nest _Root Plan_ inside _Root Plan_ using `relation`.
In such case some _Root Plan_ features like Plugins, custom Configuration definitions
are ignored.

## Dynamic plan selection

In some cases relation needs to have multiple _Plan_ depending on the record's state.
The list of _Plans_ have to be known upfront to provide static validation.
During _Root Plan_ execution callback is called determine which _Plan_ from the defined list
to use for a given record.

Example:
```ruby
UserPlan = WipeOut.build_root_plan(User) do
  normal_plan = WipeOut.build_plan { destroy! }
  vip_plan = WipeOut.build_plan do
    ignore … # do not remove all data yetg
  end

  relation(:files, plans: [vip_plan, normal_plan] do |file|
    file.user.vip? ? vip_plan : normal_plan
  end
end
```

## Plugins

Plugins are used to define behaviours which are not supported by the
core library.

Plugins usage can be defined using `plugin` call on the top level inside `WipeOut.build_root_plan` block.

Currently the only hooks available are:
* `around_each(plan, record)` - called around each entity removal.
* `around_all(plan)` - called once around root plan execution.

When _Root Plan_ with plugins is nested inside other _Root Plan_ (see "Reusing plans")
 then its plugins are ignored.

E.g. in scenario:

 ```ruby
XPlan = WipeOut.build_root_plan(X) do
  plugin PluginX
  wipe_out …
end

YPlan = WipeOut.build_root_plan(X) do
  relation :x, XPlan
end
```

plugin defined in `XPlan` is completely ignored and not used.

## Configuration

WipeOut global settings can can be configured:

```ruby
WipeOut.config do |config|
  config.ignored_attributes << :user_id # defaults: [:id, :updated_at, :created_at, :archived_at]
end
```

_Root Plans_ can override global config:
```ruby
WipeOut.build_root_plan(SomeClass) do
  config do |config|
    config.ignored_attributes += [:some, :attributes]
  end
end
```

Similarly to Plugins, when _Root Plan_ with config override is nested inside other _Root Plan_ (see "Reusing plans")
then its custom configuration is ignored.
