# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do

  allow do
    #TODO: edit when figure out "submit" host
    origins (ENV['ABANNOTATE_HOSTS'] || "").split(",").map(&:strip)
    resource '/imports/*',
             headers: :any,
             methods: [:post, :options],
             credentials: true
  end
end
