# README


## Notes

Migrations and Models

```
#can add foreign key (experiment_id) at migratin
$ rails g model Vendor name:string experiment:belongs_to

$ rails g migration AddPartNumberToProducts part_number:string

class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
  end
end

```

---

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
