# Getting started

## Usage

Removal strategy definition is called _Plan_. _Plan_ is created using DSL.
Plan can be validated and executed.

_Plan_ defines a list of attributes and relations to clear.
Relations work as nested _Plans_ and can be nested infinitely.

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

create_table "resource_files" do |t|
  t.integer "comment_id"
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
  has_many :resource_files
end

class ResourceFile < ActiveRecord::Base; end
class Dashboard < ActiveRecord::Base; end
```

Example Plan:

```ruby
UserWipeOutPlan = WipeOut.build_plan do
   # Set nil value by default
   wipe_out :first_name, :last_name
   # Custom strategy
   wipe_out :sign_in_count, strategy: WipeOut::AttributeStrategies::ConstValue.new(0)
   # Inline custom strategy
   wipe_out :reset_password_token do
     "random-value-#{SecureRandom.hex}"
   end

   # has_many relation
   relation :comments do
     # Behaves like nested Plan.
     wipe_out :value, strategy: WipeOut::AttributeStrategies::Randomize.new

     relation :resource_files do
      on_execute ->(execution) { execution.record.destroy! }
      ignore_all
     end
   end

   # has_one relation
   relation :dashboard do
     wipe_out :order
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
* Comment's resource_files are all destroyed

User's dashboard:

* `order` attribute is set to `nil`
* `name` attribute is ignored

## Validation

_Plans_ can be validated against DB schema:

```ruby
UserWipeOutPlan.validate(User)
UserWipeOutPlan.validate(User).errors
UserWipeOutPlan.validate(User).valid?
```

Method performs validation. It will contain errors if plan is invalid.

When new attribute is added to schema or a new relation is added to a model
that is used in _Plan_ then validation will fail.

### Ignoring

Every relation or attribute which is not part of removal plan
has to be marked as ignored with `ignore`.

`through` and `belongs_to` relations are ignored automatically and they don't have to be ignored manually.

By default these attributes are ignored:

* `id`
* `created_at`
* `updated_at`
* `archived_at`

Given schema:

```ruby
create_table "users" do |t|
  t.string "first_name"
  t.string "last_name"
  t.integer "company_id"
  t.datetime "created_at"
  t.datetime "updated_at"
end
```

and class:

```ruby
class User < ActiveRecord::Base
  belongs_to :company
  has_many :comments
  has_one :dashboard
  has_many :resource_files, through: :comments
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
* relation `resource_files` - through relation

### Reusing _Plans_

#### Extracting

Nested plans can be extracted as independent object. An exemplary plan can be rewritten to:

```ruby
CommentsWipeOutPlan = WipeOut.build_plan do
  wipe_out :value, strategy: WipeOut::AttributeStrategies::Randomize.new

  relation :resource_files do
    on_execute ->(execution) { execution.record.destroy! }
    ignore_all
  end
end

DashboardWipeOutPlan = WipeOut.build_plan do
  relation :dashboard do
    wipe_out :order
    ignore :name
  end
end

UserWipeOutPlan = WipeOut.build_plan do
  # …
  relation :comments, CommentsWipeOutPlan
  relation :dashboard, DashboardWipeOutPlan
  # …
end
```

#### Including

_Plan_ can be included to other existing _Plan_. When _Plan_ is included then
its strategy is copied and extends current definition.

E.g.

```ruby
HasAttachmentsPlan = WipeOut.build_plan do
  relation(:images) do
    on_execute ->(execution) { execution.record.destroy! }
    ignore_all
  end
  relation(:videos) do
    on_execute ->(execution) { execution.record.destroy! }
    ignore_all
  end
  wipe_out :attachments_count
end

WipeOut.build_plan do
  include_plan HasAttachmentsPlan
  relation(:comments) do
    wipe_out :content
    include_plan HasAttachmentsPlan
  end
end
```

is exactly the same as:

```ruby
WipeOut.build_plan do
  wipe_out :attachments_count

  relation(:images) do
    on_execute ->(execution) { execution.record.destroy! }
    ignore_all
  end
  relation(:videos) do
    on_execute ->(execution) { execution.record.destroy! }
    ignore_all
  end

  relation(:comments) do
    wipe_out :content, :attachments_count

    relation(:images) do
      on_execute ->(execution) { execution.record.destroy! }
      ignore_all
    end
    relation(:videos) do
      on_execute ->(execution) { execution.record.destroy! }
      ignore_all
    end
  end
end
```

### Dynamic plan selection

In some cases relation needs to have multiple _Plan_ depending on the record's state.
The list of _Plans_ have to be known upfront to provide static validation.
During _Plan_ execution callback is called determine which _Plan_ from the defined list
to use for a given record.

```ruby
UserPlan = WipeOut.build_plan do
  normal_plan = WipeOut.build_plan do
    on_execute ->(execution) { execution.record.destroy! }
  end
  vip_plan = WipeOut.build_plan do
    ignore … # do not remove all data yet
  end

  relation(:resource_files, plans: [vip_plan, normal_plan] do |resource_file|
    resource_file.user.vip? ? vip_plan : normal_plan
  end
end
```

### Plugins

Plugins are used to define behaviours which are not supported by the
core library.

Plugins usage can be defined by including them in a plan block.

Currently the only hooks available are:

* `before(:plan) { |execution| ... }` - called before plan execution, already in transaction
* `after(:plan) { |execution| ... }` - called after plan execution, still in transaction, last place to rollback
* `before(:execution) { |execution| ... }` - called before record is wiped out
* `after(:execution) { |execution| ... }` - called after record is wiped out

When _Plan_ with plugins is nested inside other _Plan_ (see "Reusing plans")
 then its plugins are ignored.

E.g. in scenario:

 ```ruby
XPlan = WipeOut.build_plan do
  plugin PluginX
  wipe_out …
end

YPlan = WipeOut.build_plan do
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

_Plans_ can override global config:

```ruby
WipeOut.build_plan do
  configure do |config|
    config.ignored_attributes += [:some, :attributes]
  end
end
```

Similarly to Plugins, when _Plan_ with config override is nested inside other _Plan_
(see "Reusing plans") then its custom configuration is ignored.
