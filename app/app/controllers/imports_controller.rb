class ImportsController < ApplicationController
  protect_from_forgery except: :create


  def test
    puts "TEST HI"
  end

  #
  #curl -i -H "Content-Type: application/json" -X POST localhost/imports/ -d '{"test":"123"}'
  #
  def create   

    puts "HI"
    puts params

  end
end
