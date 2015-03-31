module Bretels
  class AppBuilder < Rails::AppBuilder
    include Bretels::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end

    def remove_rails_logo_image
      remove_file 'app/assets/images/rails.png'
    end

    def raise_delivery_errors
      replace_in_file 'config/environments/development.rb',
        'raise_delivery_errors = false', 'raise_delivery_errors = true'
    end

    def add_support_files
      copy_file 'factory_girl_syntax_rspec.rb', 'spec/support/factory_girl.rb'
      copy_file 'database_cleaner.rb', 'spec/support/database_cleaner.rb'
      copy_file 'poltergeist.rb', 'spec/support/poltergeist.rb'
    end

    def test_factories_first
      copy_file 'factories_spec.rb', 'spec/models/factories_spec.rb'
    end

    def generate_factories_file
      empty_directory 'spec/factories'
    end

    def install_spring_gem
      `gem install spring spring-commands-rspec`
    end

    def add_cdn_settings
      config = <<-RUBY
\n\n  # Cloudfront settings
  config.static_cache_control = "public, max-age=31536000"
  config.action_controller.asset_host = ENV['ASSET_HOST']

  # Enable Rack Zippy for GZIP responses
  config.middleware.swap(ActionDispatch::Static, Rack::Zippy::AssetServer)
      RUBY

      inject_into_file 'config/environments/production.rb', config.rstrip,
        :after => "config.assets.digest = true"
    end

    def enable_rack_deflater
      config = <<-RUBY

  # Enable deflate / gzip compression of controller-generated responses
  config.middleware.use Rack::Deflater
      RUBY

      inject_into_file 'config/environments/production.rb', config,
        :after => "config.serve_static_assets = false\n"
    end

    def remove_turbolinks
      replace_in_file 'app/assets/javascripts/application.js',
        /\/\/= require turbolinks\n/,
        ''
    end

    def enable_force_ssl
      replace_in_file 'config/environments/production.rb',
        '# config.force_ssl = true', 'config.force_ssl = true'
    end

    def setup_staging_environment
      template 'staging.rb.erb', 'config/environments/staging.rb'
    end

    def initialize_on_precompile
      inject_into_file 'config/application.rb',
        "\n    config.assets.initialize_on_precompile = false",
        :after => 'config.assets.enabled = true'
    end

    def lib_in_load_path
      inject_into_file 'config/application.rb', "\n\n" + '    config.autoload_paths += Dir["#{config.root}/lib/**/"]',
        after: /class Application < Rails::Application/
    end

    def create_partials_directory
      empty_directory 'app/views/application'
    end

    def create_shared_flashes
      copy_file '_flashes.html.erb', 'app/views/application/_flashes.html.erb'
    end

    def create_application_layout
      template 'suspenders_layout.html.erb.erb',
        'app/views/layouts/application.html.erb',
        :force => true
    end

    def use_postgres_config_template
      template 'postgresql_database.yml.erb', 'config/database.yml',
        :force => true
    end

    def replace_gemfile
      remove_file 'Gemfile'
      copy_file 'Gemfile_clean', 'Gemfile'
    end

    def set_ruby_to_version_being_used
      inject_into_file 'Gemfile', "\n\nruby '#{RUBY_VERSION}'",
        after: /source 'https:\/\/rubygems.org'/
    end

    def configure_rspec
      config = <<-RUBY

    # Hand-pick the generators we use
    config.generators do |generate|
      generate.test_framework :rspec
      generate.helper false
      generate.stylesheets false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.view_specs false
    end
      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def configure_time_zone
      replace_in_file 'config/application.rb',
        "# config.time_zone = 'Central Time (US & Canada)'",
        "config.time_zone = 'Amsterdam'"
    end

    def configure_dutch_language
      replace_in_file 'config/application.rb',
        '# config.i18n.default_locale = :de',
        "config.i18n.default_locale = :nl\n    config.i18n.available_locales = :nl"
    end

    def configure_time_formats
      copy_file 'config_locales_nl.yml', 'config/locales/nl.yml'
    end

    def configure_rack_timeout
      copy_file 'rack_timeout.rb', 'config/initializers/rack_timeout.rb'
    end

    def configure_action_mailer
      action_mailer_host 'development', "#{app_name}.dev"
      action_mailer_host 'test', 'www.example.com'
      action_mailer_host 'staging', "#{app_name}-staging.herokuapp.com"
      action_mailer_host 'production', "#{app_name}.nl"
    end

    def generate_rspec
      copy_file 'spec_helper.rb', 'spec/spec_helper.rb'
      copy_file 'rails_helper.rb', 'spec/rails_helper.rb'
    end

    def setup_foreman
      copy_file 'puma.rb', 'config/puma.rb'
      copy_file 'Procfile', 'Procfile'
    end

    def setup_stylesheets
      copy_file 'app/assets/stylesheets/application.css',
        'app/assets/stylesheets/application.css.scss'
      remove_file 'app/assets/stylesheets/application.css'
    end

    def gitignore_files
      concat_file 'suspenders_gitignore', '.gitignore'
      [
        'spec/features',
        'spec/models',
        'spec/support'
      ].each do |dir|
        empty_directory(dir)
        create_file("#{dir}/.gitkeep")
      end
    end

    def init_git
      run 'git init'
      run 'git add .'
      run 'git commit -m "Initial commit" > /dev/null'
    end

    def create_heroku_apps
      run "#{path_addition} heroku create #{app_name}-production --remote=production"
      run "#{path_addition} heroku create #{app_name}-staging --remote=staging"
      run "#{path_addition} heroku config:add RACK_ENV=staging RAILS_ENV=staging --remote=staging"
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb',
        /Rails\.application\.routes\.draw do.*end/m,
        "Rails.application.routes.draw do\nend"
    end

    def add_airbrake_configuration
      copy_file 'airbrake.rb', 'config/initializers/airbrake.rb'
    end

    def raise_unpermitted_params
      config = <<-RUBY
\n\n  config.action_controller.action_on_unpermitted_parameters = :raise
      RUBY

      inject_into_file 'config/environments/development.rb', config.rstrip,
        :after => "config.assets.debug = true"
    end

  end
end
