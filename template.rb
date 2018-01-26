# frozen_string_literal: true

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
  gem 'rubocop', '~> 0.52'
end

gem_group :development, :test do
  gem 'pry', '~> 0.11'
  gem 'rspec-rails', '~> 3.7'
end

FileUtils.mv 'config/database.yml', 'config/database.yml.example'
run %q(bash -c "sed -i -e '/ *#/d' -e '/^ *$/d' -e 's/_development$/_dev/g' -e 's/_production//g' \
       config/database.yml.example")

['app/models/concerns', 'app/controllers/concerns'].each { |path| FileUtils.rm_r path if File.exist? path }

'app/views/layouts/application.html.erb'.tap { |path| FileUtils.rm path if File.exist? path }
file 'app/views/layouts/application.html.haml', <<~EOL
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

'app/assets/stylesheets/application.css'.tap { |s| FileUtils.rm s if File.exist? s }
file 'app/assets/stylesheets/application.scss', <<~EOL
  @import 'bootstrap';
EOL

'app/assets/javascripts/application.js'.tap do |s|
  FileUtils.rm s if File.exist? s
  file s, <<~EOL
    //= require jquery3
    //= require jquery_ujs
    //= require popper
    //= require bootstrap
    //= require_tree .
  EOL
end

FileUtils.mkdir_p 'spec'

file 'spec/spec_helper.rb', <<~EOL
  RSpec.configure do |config|
    config.expect_with :rspec do |expectations|
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = true
    end

    config.shared_context_metadata_behavior = :apply_to_host_groups
    config.filter_run_when_matching :focus
    config.example_status_persistence_file_path = 'tmp/spec_examples.txt'
    config.disable_monkey_patching!
    config.default_formatter = 'doc' if config.files_to_run.one?
    config.order = :random
    Kernel.srand config.seed
  end
EOL

file 'spec/rails_helper.rb', <<~'EOL'
  require 'spec_helper'
  ENV['RAILS_ENV'] ||= 'test'
  require File.expand_path('../../config/environment', __FILE__)
  # Prevent database truncation if the environment is production
  abort("The Rails environment is running in production mode!") if Rails.env.production?
  require 'rspec/rails'
  # Add additional requires below this line. Rails is not loaded until this point!

  Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

  ActiveRecord::Migration.maintain_test_schema!

  RSpec.configure do |config|
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.infer_spec_type_from_file_location!
    config.filter_rails_from_backtrace!
  end
EOL

file '.rspec', <<~"EOL"
  --require spec_helper
EOL

file '.rubocop.yml', <<~"EOL"
  ---
  Style/Documentation:
    Enabled: false

  Metrics/LineLength:
    Max: 120
EOL

file 'db/migrate/00000000000001_add_hstore_and_uuid_extensions.rb', <<~EOL
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

'.gitignore'.tap do |f|
  FileUtils.rm f
  file f, <<~EOL
    /.bundle
    /log/*
    /tmp/*
    !/log/.keep
    !/tmp/.keep
    /node_modules
    /yarn-error.log
    .byebug_history
    vendor/bundle
    config/database.yml
  EOL
end

FileUtils.rm 'bin/update'
FileUtils.rm 'bin/setup'

file '.ruby-version', `/usr/bin/env ruby -rrbconfig -e "puts RbConfig::CONFIG['ruby_version']"`

after_bundle do
  gen_controller 'homepage index'
  route 'root to: "homepage#index"'
  run 'bundle exec rubocop -a'
end
