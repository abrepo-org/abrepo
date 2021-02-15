class AddVerifiedToVariation < ActiveRecord::Migration[6.1]
  def change
    add_column :variations, :verified, :boolean, null: false, default: false
    Variation.find_each do |variation|
      variation.verified = false
      variation.save!
    end
  end
end
