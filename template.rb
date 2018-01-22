def gen_controller(names)
  generate :controller, names, '--skip-assets --skip-helper --skip-view-specs --skip-controller-specs'
end

run '>Gemfile'
add_source 'https://rubygems.org'
gem 'rails', '~> 5.1.4'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jbuilder', '~> 2.5'

gem 'haml-rails', '~> 1.0'

gem 'jquery-rails', '~> 4.3'
gem 'sass-rails', '~> 5.0'
gem 'bootstrap', '~> 4.0'

gem_group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

gem_group :development, :test do
  gem 'pry', '~> 0.11'
  gem 'rspec-rails', '~> 3.7'
end

run %q{bash -c "sed -i -e '/ *#/d' -e '/^ *$/d' -e 's/_development$/_dev/g' -e 's/_production//g' config/database.yml"}

['app/models/concerns', 'app/controllers/concerns'].each { |path| FileUtils.rm_r path if File.exist? path }

'app/views/layouts/application.html.erb'.tap {|path| FileUtils.rm path if File.exist? path}
file 'app/views/layouts/application.html.haml', <<-EOL
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

'app/assets/stylesheets/application.css'.tap {|s| FileUtils.rm s if File.exist? s}
file 'app/assets/stylesheets/application.scss', <<-EOL
@import 'bootstrap';
EOL

'app/assets/javascripts/application.js'.tap do |s|
  FileUtils.rm s if File.exist? s
  file s, <<-EOL
//= require jquery3
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require_tree .
  EOL
end

run 'bundle install'
run 'rspec --init'

file 'db/migrate/00000000000001_add_hstore_and_uuid_extensions.rb', <<-EOL
class AddHstoreAndUuidExtensions < ActiveRecord::Migration[5.1]
  def up
    enable_extension 'hstore'
    enable_extension 'uuid-ossp'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
EOL

'config/routes.rb'.tap do |s|
  FileUtils.rm s if File.exist? s
  file s, <<-EOL
Rails.application.routes.draw do
end
  EOL
end

gen_controller 'homepage index'
route 'root to: "homepage#index"'
