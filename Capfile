# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
# require 'capistrano/bundler'
# require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'
# require 'capistrano/passenger'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

#own deploy to 16.04
#require 'capistrano/rails'
#require 'capistrano/passenger'

# If you are using rbenv add these lines:
require 'capistrano/rbenv'
set :rbenv_type, :user
set :rbenv_ruby, '2.3.3'

# If you are using rvm add these lines:
# require 'capistrano/rvm'
# set :rvm_type, :user
# set :rvm_ruby_version, '2.7.0'

#require 'capistrano/rbenv'
require 'capistrano/rbenv_install'
require 'capistrano/bundler'
require 'capistrano/rails'
require 'capistrano/unicorn_nginx'
require 'capistrano/postgresql'
require 'capistrano/safe_deploy_to'
require 'capistrano/ssh_doctor'
