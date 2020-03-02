source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.7'
# Use Puma as the app server
gem 'puma', '~> 4.3.2'
# Use SCSS for stylesheets
gem 'bootstrap-sass', '~> 3.4.1'
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'semantic-ui-sass'
gem 'jquery-rails'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
 gem 'bcrypt', '~> 3.1.7'
 gem 'hirb', '~> 0.7.3'

 #for mobile devices
gem 'mobile-fu', '~> 1.4'


gem 'tiny_tds', '~> 1.3.0'
gem 'activerecord-sqlserver-adapter'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '~> 1.3.13'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'

  #gem 'capistrano', '>= 3.2.1'
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rbenv', '~> 2.0'           # idiomatic rbenv support
  gem 'capistrano-rbenv-install'             # ensures the right ruby version is installed
  gem 'capistrano-bundler', '~> 1.1.2'       # support for bundler
  gem 'capistrano-rails', '~> 1.0'           # automatic migrations and asset compilation
  gem 'capistrano-unicorn-nginx', '~> 2.0'   # plug-n-play nginx and unicorn
  gem 'capistrano-postgresql', '~> 3.0'      # plug-n-play postgresql
  gem 'capistrano-safe-deploy-to', '~> 1.1'  # ensures deploy path for the app exists
  #gem 'capistrano-ssh-doctor'                # helps with debugging ssh-agent forwarding
  gem 'capistrano-ssh-doctor', '~> 1.0'
end

group :production do
  #gem 'pg'
  gem 'pg', '~> 1.1.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
