# This file is used by Rack-based servers to start the application.

require "./setup"
require "./app"
run Sinatra::Application
