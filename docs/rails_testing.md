# Rails Testing

Using minitest and simplecov for testing.

### Assert Syntax

* `assert_response` : controller response
* `assert assigns(:variations).present?`: checks instance variable values in controller
* `assert_template /path`: asserts view template rendered
* `assert_match regex content`: regex match
* `assert_includes source, content`: source contains content

* `assert x`: truthy
* `assert_nil`: nil-y
* `assert_equal x,y`: equality
* `assert_not_equal x,y`: inequality

* `assert_difference`: before / after Model.count:

```
assert_difference 'Subscription.count', 1 do
  get checkout_success_path, params: { session_id: @session_id }
end
```

* `assert_raises`: captures and asserts on error within block:

```
assert_raises(ActionController::RoutingError) do
  get users_path(-1)
end
```

* `assert_redirected_to <path>`: result is 302


##### Random

* `response.body`: content
* `flash[:alert]`
* `response :success, :internal_server_error, :bad_request. :unauthorized`: response status


### Fixtures

Fixtures are loaded from `test/fixtures/`; populate with reasonable values.

* fixture's top level key is it's instance variable name (e.g. "profile_one")
* instance variables are accessible in a pluralized collection 'global' variable
* invalid fixtures will still be available - there's no warning: if tests aren't
  making sense, check fixture validity.

```
# `profiles` is shorthand for `Profile.all`, contains each instance of fixture file (profiles.yml)

@profile_one = profiles(:profile_one)
@profile_one.valid?  # checks fixture validity
```

#### Associations

* associations: don't blindly follow annotation comments; make sure the foreign
  key e.g. the `_id` field is replaced by the association model name.
  * e.g. `Profile` has_many `Experiments`, association fixture is
    `experiments.profile: profile_one`
* If associations are still not forming, ensure the instances are valid:
  `profiles(:profile_one).valid?`
* avoid fixtures with primary key `id` field; this will be auto generated, and
  needed to keep consistent associations.

#### ActsAsTaggable / Tag fixtures

For models with tags, the associated tag fixtures need to be created.

These need to be placed in a *subdirectory*, 'acts_as_taggable_on/tags.yml' to be
properly loaded by test suite.

For something like `Taggings` fixture - helps to look at attributes in console
as reference to populate. e.g. `Taggings.taggable_type` needs a fixture value
for associations to take.



### Stub and Mock: Minitest

Stub a method, need to setup input parameters and output - take care to ensure
they explicitly match expectations.

Example stub for `Stripe::Checkout::Session.create`:

```

# expected input parameters to method

@checkout_session_params = {
    customer: 123,
    customer_email: @user.email,
    ...
}

# expected return value
@checkout_session_return = Stripe::Util.convert_to_stripe_object(
    { id: 'session_123', url: 'http://example.com/checkout' }, "xyz"
)

checkout_session_mock = Minitest::Mock.new
checkout_session_mock.expect(:call, @checkout_session_return, **@checkout_session_params)

Stripe::Checkout::Session.stub(:create, checkout_session_mock) do
    post create_checkout_session_path, params: { data: {price_key: 'basic-monthly'} }
end
```

In this example user posts requests to `checkout_session` selecting the
'basic-monthly' setting.

There is a bunch of miscellaneous code, but eventually reaches
`Stripe::Checkout::Session.create` - which will be stubbed.

The stub is active within its defined block - in this case the start of the
request.

Again, make sure your mocks match the expected generated input and output, or
it'll throw an error. In this case there's a bunch of code in the controller to
shape input and outputs. This can get tricky when dynamically generating
instance (e.g. creating users, anticipating ids.)

Additionally showing example with `Stripe::Util.convert_to_stripe_object` to
highlight it is important to be rigorous when comes to symbol vs attribute vs
json, etc.


To handle exceptions, pass a lambda. Here stub
`Stripe::Checkout::Session.retrieve`, which takes a single `session_id`
parameter.

```
    raises_exception = -> (session_id) { raise Stripe::StripeError.new("Error") }
    Stripe::Checkout::Session.stub(:retrieve, raises_exception) do
      ...
    end

```

##### Gothcas:

* Be exact w/ expected input and return value.
* Dynamically generated ids? Can reset user id to 1 with
  `ActiveRecord::Base.connection.execute("TRUNCATE users RESTART IDENTITY
  CASCADE")`, but obviously not ideal.
* Nesting stubs works, but tracking multiple input/outputs gets unwieldy fast.
