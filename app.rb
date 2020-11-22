require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra-snap'
require 'slim'
require 'yaml'

require_relative './helpers.rb'
Dir.glob('./models/*.rb').each {|model| require_relative model}
Dir.glob('./controllers/*.rb').each {|model| require_relative model}

also_reload './helpers.rb'
also_reload './models/*.rb'
also_reload './controllers/*.rb'

helpers AppHelpers

paths index: '/'

configure do
  $config = YAML.load(File.open('config/application.yml'))
  use Rack::Session::Cookie, secret: $config['secret']
end

get :index do
  slim :index
end
