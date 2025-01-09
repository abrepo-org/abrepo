# Authorization Basics / Notes via Pundit

Authorization is "contained" in `/app/policies` directory via gem
[Pundit](https://github.com/varvet/pundit)

Current "role" is a simple boolean for`user.moderator`.

### Policies Notes

Authorization policies are designed as extensions or "overlays" to resources;
currently:

* `policies/ProfilePolicy.rb`
* `policies/ExperimentPolicy.rb`
* `policies/VariationPolicy.rb`

Each policy has a number of boolean methods that correspond to a controller
action, e.g.:

```
def create?
  user.moderator?
end
```

This sets a policy to "gate" the 'create' action for that resource.

The actual call to check authorization is in the controller via the
`authorize` method, which is wrapped around the class or instance.

```
experiment = authorize Experiment.find(id: 123)
```

#### Scope

Authorization entails a restricted view of resources. The restrictions are
defined within the `Scope` class of each respective policy.

The definition can be applied throughout controllers or views via a decorator
`policy_scope` chainable method.

```
# app/views/variations/index.html.erb

filtered_variations = policy_scope(@experiment.variations).where(...)

```

### Notes

* `policy_scope`, `authorize` aren't available in models; these are
  controller/view helpers. But can dependency inject them in controller to
  helper models; e.g. see `search_controller#index`, and `models/search.rb`

* `user` in policy referenced as `current_user` (devise-friendly) automatically
  in pundit. However, this requires rescue when there is no logged in user (user
  is nil)

* unauthorized cases throw an error and require catching: `rescue_From
  Pundit::NotAuthorizedError, with: :user_helper_method` typically added to a
  controller.
