def gen_controller(names)
  generate :controller, names, "--skip-assets --skip-helper --skip-view-specs --skip-controller-specs"
end

run ">Gemfile"
add_source "https://rubygems.org"
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

"app/models/concerns".tap {|s| FileUtils.rm_r s if File.exist? s}

"app/views/layouts/application.html.erb".tap {|s| FileUtils.rm s if File.exist? s}
file "app/views/layouts/application.html.haml", <<-EOL
!!!
%html{:lang => "en"}
  %head
    %meta{:charset => "utf-8"}
    %meta{:content => "IE=edge", "http-equiv" => "X-UA-Compatible"}
    %meta{:content => "width=device-width, initial-scale=1", :name => "viewport"}

    %title Application

    = stylesheet_link_tag    'application', media: 'all'
    = csrf_meta_tags
  %body
    = yield
    = javascript_include_tag 'application'
EOL

"app/assets/stylesheets/application.css".tap {|s| FileUtils.rm s if File.exist? s}
file "app/assets/stylesheets/application.scss", <<-EOL
@import "bootstrap-sprockets";
@import "bootstrap";
EOL

file "app/assets/javascripts/application.js", <<-EOL
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
EOL

run "bundle install"

generate "rspec:install"
run %q{sed -i -e '/Rails\.root\.join.*spec\/support.*require f/c \Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }' spec/rails_helper.rb}

file "db/migrate/00000000000001_add_hstore_uuid_extensions.rb", <<-EOL
class AddHstoreUuidExtensions < ActiveRecord::Migration
  def up
    enable_extension "hstore"
    enable_extension "uuid-ossp"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
EOL

file "config/routes.rb", <<-EOL
Rails.application.routes.draw do
end
EOL

gen_controller "homepage index"
route 'root to: "homepage#index"'
