module Bretels
  class AppBuilder < Rails::AppBuilder
    include Bretels::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end

    def remove_public_index
      remove_file 'public/index.html'
    end

    def remove_rails_logo_image
      remove_file 'app/assets/images/rails.png'
    end

    def raise_delivery_errors
      replace_in_file 'config/environments/development.rb',
        'raise_delivery_errors = false', 'raise_delivery_errors = true'
    end

    def enable_factory_girl_syntax
      copy_file 'factory_girl_syntax_rspec.rb', 'spec/support/factory_girl.rb'
    end

    def test_factories_first
      copy_file 'factories_spec.rb', 'spec/models/factories_spec.rb'
    end

    def generate_factories_file
      template 'factories.rb', 'spec/factories.rb'
    end

    def add_cdn_settings
      config = <<-RUBY
\n\n  # Cloudfront settings
  # config.static_cache_control = "public, max-age=31536000"
  # config.action_controller.asset_host = ENV['ASSET_HOST']
      RUBY

      inject_into_file 'config.ru', "use Rack::Deflater\n",
        :before => "run #{app_const}"

      inject_into_file 'config/environments/production.rb', config.rstrip,
        :after => "config.assets.digest = true"
    end

    def configure_smtp
      config = <<-RUBY
\n\n  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'herokuapp.com',
    :enable_starttls_auto => true
  }
  config.action_mailer.delivery_method = :smtp
      RUBY

      inject_into_file 'config/environments/production.rb', config.rstrip,
        :after => 'config.action_mailer.raise_delivery_errors = false'

      inject_into_file(
        "config/environments/development.rb",
        "\n\n  config.action_mailer.delivery_method = :letter_opener",
        :before => "\nend"
      )
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
      replace_in_file 'config/application.rb',
        '# config.autoload_paths += %W(#{config.root}/extras)', 'config.autoload_paths += Dir["#{config.root}/lib/**/"]'
    end

    def create_partials_directory
      empty_directory 'app/views/application'
    end

    def create_shared_flashes
      copy_file '_flashes.html.erb', 'app/views/application/_flashes.html.erb'
    end

    def create_shared_javascripts
      copy_file '_javascript.html.erb', 'app/views/application/_javascript.html.erb'
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

    def enable_database_cleaner
      copy_file 'database_cleaner_rspec.rb', 'spec/support/database_cleaner.rb'
    end

    def configure_rspec
      remove_file '.rspec'
      copy_file 'rspec', '.rspec'

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

    def blacklist_active_record_attributes
      replace_in_file 'config/application.rb',
        'config.active_record.whitelist_attributes = true',
        'config.active_record.whitelist_attributes = false'
    end

    def configure_strong_parameters
      copy_file 'strong_parameters.rb', 'config/initializers/strong_parameters.rb'
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
      action_mailer_host 'production', "#{app_name}.nl"
    end

    def generate_rspec
      copy_file 'spec_helper.rb', 'spec/spec_helper.rb'
    end

    def setup_foreman
      copy_file 'sample.env', '.sample.env'
      copy_file 'unicorn.rb', 'config/unicorn.rb'
      copy_file 'Procfile', 'Procfile'
    end

    def setup_stylesheets
      copy_file 'app/assets/stylesheets/application.css',
        'app/assets/stylesheets/application.css.scss'
      remove_file 'app/assets/stylesheets/application.css'
      concat_file 'import_scss_styles', 'app/assets/stylesheets/application.css.scss'
      create_file 'app/assets/stylesheets/_screen.scss'
    end

    def gitignore_files
      concat_file 'suspenders_gitignore', '.gitignore'
      [
        'spec/support',
        'spec/lib',
        'spec/features',
        'spec/models',
      ].each do |dir|
        empty_directory_with_gitkeep dir
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

    def create_github_repo(repo_name)
      run "#{path_addition} hub create #{repo_name}"
    end

    def copy_miscellaneous_files
      copy_file 'errors.rb', 'config/initializers/errors.rb'
    end

    def customize_error_pages
      meta_tags =<<-EOS
  <meta charset='utf-8' />
  <meta name='robots' content='noodp' />
      EOS
      style_tags =<<-EOS
<link href='/assets/application.css' media='all' rel='stylesheet' type='text/css' />
      EOS

      %w(500 404 422).each do |page|
        inject_into_file "public/#{page}.html", meta_tags, :after => "<head>\n"
        replace_in_file "public/#{page}.html", /<style.+>.+<\/style>/mi, style_tags.strip
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb',
        /Application\.routes\.draw do.*end/m,
        "Application.routes.draw do\nend"
    end

    def add_email_validator
      copy_file 'email_validator.rb', 'app/validators/email_validator.rb'
    end

    def disable_xml_params
      copy_file 'disable_xml_params.rb', 'config/initializers/disable_xml_params.rb'
    end

    def setup_default_rake_task
      append_file 'Rakefile' do
        "task(:default).clear\ntask :default => [:spec]"
      end
    end

  end
end
