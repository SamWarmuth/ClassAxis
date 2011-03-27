ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ROOT_DIR

require "rubygems"

begin
  require "vendor/dependencies/lib/dependencies"
rescue LoadError
  require "dependencies"
end

CACHE_CSS = false
ARGV.each {|a| CACHE_CSS = true if a.downcase == "production"}

require "monk/glue"
require "couchrest"
require "haml"
require "sass"
require "json"
require "pusher"
require "active_support"
require "image_size"




class Main < Monk::Glue
  set :app_file, __FILE__
  use Rack::Session::Cookie
end

# Connect to couchdb.
couchdb_url = monk_settings(:couchdb)[:url]
COUCHDB_SERVER = CouchRest.database!(couchdb_url)

#Pusher Credentials
Pusher.app_id = '3031'
Pusher.key = '84d6245235e5b198d8aa'
Pusher.secret = 'a75d798c2cb2abd65dd1'

$current_users = {}
$users_names = {}
$rendered_messages = {}


# Load all application files.
Dir[root_path("app/**/*.rb")].each do |file|
  require file
end

Main.run! :port => 4571 if Main.run?
