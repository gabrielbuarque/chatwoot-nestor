namespace :docker do
  desc "Precompile assets for Docker build with enhanced error handling"
  task :assets_precompile => :environment do
    puts "=== Docker Asset Compilation Started ==="
    
    # Set required environment variables
    ENV['RAILS_ENV'] ||= 'production'
    ENV['NODE_ENV'] = 'production'
    ENV['RAILS_SERVE_STATIC_FILES'] = 'true'
    ENV['RAILS_LOG_TO_STDOUT'] = 'enabled'
    ENV['DISABLE_SPRING'] = '1'
    ENV['SKIP_STORAGE_VALIDATION'] = 'true'
    ENV['SKIP_DATABASE_VALIDATIONS'] = 'true'
    
    puts "Environment: #{Rails.env}"
    puts "Node environment: #{ENV['NODE_ENV']}"
    puts "Node options: #{ENV['NODE_OPTIONS']}"
    
    begin
      # Ensure directories exist
      FileUtils.mkdir_p('tmp/cache/webpacker')
      FileUtils.mkdir_p('public/packs')
      FileUtils.mkdir_p('log')
      
      puts "=== Verifying Webpacker Installation ==="
      Rake::Task['webpacker:verify_install'].invoke rescue puts "Webpacker verification skipped"
      
      puts "=== Cleaning Previous Assets ==="
      Rake::Task['assets:clobber'].invoke rescue puts "Asset clobber skipped"
      
      puts "=== Starting Asset Precompilation ==="
      start_time = Time.current
      
      Rake::Task['assets:precompile'].invoke
      
      end_time = Time.current
      duration = (end_time - start_time).round(2)
      
      puts "=== Asset Compilation Completed Successfully ==="
      puts "Duration: #{duration} seconds"
      
      # Verify assets were created
      if Dir.glob('public/packs/**/*').any?
        puts "✓ Assets found in public/packs/"
        puts "Total assets: #{Dir.glob('public/packs/**/*').count}"
      else
        puts "⚠ Warning: No assets found in public/packs/"
      end
      
    rescue => e
      puts "=== Asset Compilation Failed ==="
      puts "Error: #{e.class}: #{e.message}"
      puts "Backtrace:"
      puts e.backtrace.join("\n")
      
      # Debug information
      puts "\n=== Debug Information ==="
      puts "Ruby version: #{RUBY_VERSION}"
      puts "Rails version: #{Rails.version}"
      puts "Webpacker version: #{Webpacker::VERSION}" rescue puts "Webpacker version: unknown"
      puts "Node version: #{`node --version`.strip}" rescue puts "Node version: unknown"
      puts "Yarn version: #{`yarn --version`.strip}" rescue puts "Yarn version: unknown"
      
      puts "\n=== Directory Status ==="
      puts "tmp/cache exists: #{Dir.exist?('tmp/cache')}"
      puts "tmp/cache/webpacker exists: #{Dir.exist?('tmp/cache/webpacker')}"
      puts "public/packs exists: #{Dir.exist?('public/packs')}"
      puts "node_modules exists: #{Dir.exist?('node_modules')}"
      
      puts "\n=== Environment Variables ==="
      env_vars = %w[RAILS_ENV NODE_ENV NODE_OPTIONS RAILS_SERVE_STATIC_FILES SECRET_KEY_BASE]
      env_vars.each do |var|
        value = ENV[var]
        if var == 'SECRET_KEY_BASE'
          puts "#{var}: #{value ? '[SET]' : '[NOT SET]'}"
        else
          puts "#{var}: #{value || '[NOT SET]'}"
        end
      end
      
      exit 1
    end
  end
end 