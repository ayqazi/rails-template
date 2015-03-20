def gen_controller(names)
  generate :controller, names, "--skip-assets --skip-helper --skip-view-specs"
end

run "echo \"source 'https://rubygems.org'\" > Gemfile"
gem "rails", "~> 4.2.1"
gem "pg"

gem "haml-rails"

gem "uglifier", ">= 1.3.0"
gem "jquery-rails"
gem "sass-rails", "~> 5.0"
gem "bootstrap-sass", "~> 3.3.4"


gem_group :development, :test do
  gem "byebug"
  gem "rspec-rails"
end

run %q{bash -c "sed -i -e '/ *#/d' -e '/^ *$/d' -e 's/_development$/_dev/g' config/database.yml"}
run %q{bash -c "sed -r -i -e \"s/key: '_([a-z_]+)_session'/key: %Q[_\1_#{Rails.env}_session]/\" config/initializers/session_store.rb"}

FileUtils.rm "app/assets/stylesheets/application.css"
File.open("app/assets/stylesheets/application.scss", "ab") do |f|
  f.write <<-EOL
@import "bootstrap-sprockets";
@import "bootstrap";
  EOL
end

File.open("app/assets/javascripts/application.js", "ab") do |f|
  f.write <<-EOL
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
  EOL
end

run "bundle install"

after_bundle do
  generate "rspec:install"
  gen_controller "homepage index"
  route 'root to: "homepage#index"'
end
