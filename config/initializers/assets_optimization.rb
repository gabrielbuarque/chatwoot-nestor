# Optimize asset compilation for production builds
if Rails.env.production? && ENV['RAILS_SERVE_STATIC_FILES'] == 'true'
  # Configure asset settings for Docker builds
  Rails.application.config.public_file_server.enabled = true
  Rails.application.config.serve_static_files = true
  
  # Skip asset compilation checks that can cause issues in Docker
  Rails.application.config.assets.check_precompiled_asset = false
  
  # Set asset host for production
  Rails.application.config.action_controller.asset_host = nil
  
  # Disable asset debugging in production
  Rails.application.config.assets.debug = false
  
  # Configure asset compression
  Rails.application.config.assets.compress = true
  Rails.application.config.assets.js_compressor = :uglifier
  Rails.application.config.assets.css_compressor = :sass
  
  # Set asset digest for cache busting
  Rails.application.config.assets.digest = true
  
  # Configure asset pipeline for production
  Rails.application.config.assets.compile = false
  Rails.application.config.assets.precompile += %w( *.svg *.eot *.woff *.ttf *.woff2 )
end

# Skip certain validations during asset precompilation
if defined?(Rails::Server) || File.basename($0) == 'rake'
  if ARGV.any? { |arg| arg.include?('assets:precompile') }
    # Skip database checks during asset precompilation
    ENV['SKIP_DATABASE_VALIDATIONS'] = 'true'
    
    # Skip storage validations during asset precompilation  
    ENV['SKIP_STORAGE_VALIDATION'] = 'true'
    
    # Disable Spring during asset precompilation
    ENV['DISABLE_SPRING'] = '1'
  end
end 