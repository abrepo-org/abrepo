# Devise Generated Views: Styling Updates

### Supporting Views:

* `devise/shared/error_messages`:
  * `<div id="error_expanation">`, `<h2>` error title, `<ul>` of `<li>` message
* `devise/shared/links`: underneath page forms - mostly `href` and `<br />`, no
  style
* `/devise/mailer/*.rb`: plain text - `<p>` tags, no style

### Main Style Changes with Devise

* `.field`: `<label>`, `<email_field`>

* `<label>` add class "label"
* `<label>` remove `<br/>`
* wrap input with `<div class="control">`
* `<label>` example with converted helper text:

```
<pre>
          <%= f.label :password, class: "label" do%>
          Password
          <span class="help has-text-weight-normal is-inline-block">
              (leave blank if you don't want to change it)
          </span>
          <% end  %>

</pre>
```

* `.actions`: `<submit>`
  * wrap with `<div class='control'>`, add `class: 'button is-fullwidth-desktop is-link'`
  * is-fullwidth-desktop custom class
* change min password length
* change links text
* error message list needs some styling e.g.: `http://localhost/users/unlock`:
  * "error confirmation": 1 error prohibited this user from being saved
  * Bulma styles for "Notification"
  * add "notification class" wrapper; add `<button> delete`
  * remove `<h2>`
  * adjust `<ul>` margin-top; mt-0

* use `content_for(:devise)` block to isolate devise views in its own separate
  layout
  * exceptions: user settings so not standalone `content_for`
    * `registrations/edit.html.erb`
    * `passwords/edit.html.erb`

* error message displayed:
    * `<%= resource.errors.inspect %>`
    * access each attribute error message: e.g. `<%=
      resource.errors[:email].join(',') if resource.errors[:email] %>`

#### Login page error messages use flash:

* There is a error_message devise_helper 'converter':
  https://stackoverflow.com/questions/4635986/rails-devise-error-messages-when-signing-in

* Flash approach:

``` erb
<% if flash[:error] || flash[:notice] || flash[:alert] %>
    <div class="notification is-danger is-light">
        <button class="delete"></button>
        <%= content_tag(:div, flash[:error], :id => "flash_error") if flash[:error] %>
        <%= content_tag(:div, flash[:notice], :id => "flash_notice") if flash[:notice] %>
        <%= content_tag(:div, flash[:alert], :id => "flash_alert") if flash[:alert] %>
    </div>
<% end %>

```


### Pages:

```

        new_user_session GET    /users/sign_in(.:format)          devise/sessions#new
       new_user_password GET    /users/password/new(.:format)     devise/passwords#new
      edit_user_password GET    /users/password/edit(.:format)    devise/passwords#edit
   new_user_registration GET    /users/sign_up(.:format)          devise/registrations#new
  edit_user_registration GET    /users/edit(.:format)             devise/registrations#edit
   new_user_confirmation GET    /users/confirmation/new(.:format) devise/confirmations#new
         new_user_unlock GET    /users/unlock/new(.:format)       devise/unlocks#new
             user_unlock GET    /users/unlock(.:format)           devise/unlocks#show


```
