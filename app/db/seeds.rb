# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#
# add initial "importer" user with moderator priviledges
#

user = User.where(email: "importer@abrepo.com")

if (user.empty?)
  user = User.where(email: "importer@abrepo.com",
                    password: ENV['USER_IMPORTER_PASSWORD'],
                    moderator: true).new
  user.save
else
  user.update(moderator:true)
end
