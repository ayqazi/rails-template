def gen_controller(names)
  generate :controller, names, "--skip-assets --skip-helper --skip-view-specs"
end

run "echo \"source 'https://rubygems.org'\" > Gemfile"
gem "rails", "~> 4.2.1"
gem "pg"
gem "haml-rails"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"

gem "jquery-rails"

gem_group :development, :test do
  gem "byebug"
  gem "rspec-rails"
end

run "bundle install"

after_bundle do
  generate "rspec:install"
  gen_controller "homepage index"
  route 'root to: "homepage#index"'
end
