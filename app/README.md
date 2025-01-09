# ABRepo Rails

Rails focused notes, concepts are found in parent `/docs`.

* [Authorization](../docs/rails_authorization.md)
* [Caching](../docs/rails_caching.md)
* [Search via `pg_search`](../docs/rails_pgsearch.md)
* [Tags and taggable](../docs/rails_taggable.md)
* [Rails Assets](../docs/rails_assets.md)
* [Transactional Email](../docs/transactional_email.md)
* [Importer User](../docs/rails_importer.md)

Devise:

* [Devise Pages custom styling](../docs/devise_style.md)
* [Devise Users - Stripe](../docs/devise_stripe.md)

Brainstorm:

* [Home Feed "Calcrank" brainstorm](../docs/rails_calcrank.md)

---

#### Misc

##### Migrations Examples Cheat sheet

* migration syntax: `$ rails g migration AddPartNumberToProducts part_number:string`
* Adding foreign key association (`experiment` / `experiment_id`) at migration:
  `$ rails g model Vendor name:string experiment:belongs_to`

Change a column:

```
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
  end
end

```
---


##### Favicon

https://redketchup.io/favicon-generator
