ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Load .env before Rails initializes so ENV vars are available everywhere,
# including database.yml. Only active in development and test environments.
require "dotenv" rescue LoadError
Dotenv.load if defined?(Dotenv)
