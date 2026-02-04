require 'tty-spinner'
require 'tty-box'

module SCLI
  class CLI
    def self.run(args)
      # Check for help flag
      if args.include?('-h') || args.include?('--help')
        show_help
        exit 0
      end
      
      # Check if configuration exists
      unless Config.exists?
        Config.setup
        puts ""
      end

      # Parse flags and message
      services = []
      message_parts = []
      
      args.each do |arg|
        if arg.start_with?('-') && arg.length > 1 && arg !~ /^-\d/
          # Parse service flags (e.g., -n, -m, -x, -nx, -mnx)
          arg[1..-1].each_char do |char|
            case char
            when 'n'
              services << :nostr
            when 'm'
              services << :microblog
            when 'x'
              services << :x
            else
              puts "❌ Error: Unknown flag '-#{char}'"
              puts "Valid flags: -n (Nostr), -m (Micro.blog), -x (X)"
              puts "Run 'scli --help' for more information."
              exit 1
            end
          end
        else
          message_parts << arg
        end
      end
      
      # Default to all services if no flags specified
      services = [:microblog, :x, :nostr] if services.empty?
      services.uniq!

      # Validate message
      if message_parts.empty?
        puts "❌ Error: Please provide a message to post."
        puts "Usage: scli [-n] [-m] [-x] \"Your message here\""
        puts "Run 'scli --help' for more information."
        exit 1
      end

      message = message_parts.join(' ')

      # Validate message length (typical social media limit)
      if message.length > 280
        puts "❌ Error: Message is too long (#{message.length} characters). Maximum is 280."
        exit 1
      end

      post(message, services)
    end

    def self.show_help
      puts <<~HELP
        SendIt CLI - Post to Micro.blog, X, and Nostr simultaneously
        
        USAGE:
            scli [OPTIONS] "Your message here"
        
        OPTIONS:
            -n              Post to Nostr only
            -m              Post to Micro.blog only
            -x              Post to X (Twitter) only
            -h, --help      Show this help message
        
        COMBINING OPTIONS:
            You can combine flags to post to multiple services:
            
            -nm             Post to Nostr and Micro.blog
            -nx             Post to Nostr and X
            -mx             Post to Micro.blog and X
            -nmx            Post to all three services (same as default)
        
        EXAMPLES:
            # Post to all services (default behavior)
            scli "Hello, world!"
            
            # Post to Nostr only
            scli -n "This goes to Nostr only"
            
            # Post to X and Micro.blog
            scli -mx "Posting to X and Micro.blog"
            
            # Post to all three explicitly
            scli -nmx "Everywhere at once!"
        
        CONFIGURATION:
            On first run, you'll be prompted to configure your accounts.
            Configuration is stored in: ~/.config/scli/config.yml
        
        AUTHENTICATION:
            - Micro.blog: Uses app token authentication
            - X: Uses OAuth 1.0a with API keys
            - Nostr: Supports nsec key or Pleb Signer
        
        NOTES:
            - Maximum message length: 280 characters
            - If no service flags are specified, posts to all services
            - Failed posts to one service won't affect others
        
        VERSION:
            #{SCLI::VERSION}
        
        MORE INFO:
            https://github.com/timappledotcom/sendit-cli
      HELP
    end

    def self.post(message, services = [:microblog, :x, :nostr])
      config = Config.load

      # Build service names for display
      service_names = []
      service_names << "Micro.blog" if services.include?(:microblog)
      service_names << "X" if services.include?(:x)
      service_names << "Nostr" if services.include?(:nostr)
      
      puts "\n📤 Posting to #{service_names.join(', ')}...\n"

      results = []
      
      # Post to Micro.blog
      if services.include?(:microblog)
        microblog = MicroBlog.new(config['microblog'])
        spinner1 = TTY::Spinner.new("[:spinner] Posting to Micro.blog...", format: :dots)
        spinner1.auto_spin
        result1 = microblog.post(message)
        results << result1
        if result1[:success]
          spinner1.success("✅")
        else
          spinner1.error("❌")
          puts "   Error: #{result1[:error]}"
        end
      end

      # Post to X
      if services.include?(:x)
        x_client = X.new(config['x'])
        spinner2 = TTY::Spinner.new("[:spinner] Posting to X...", format: :dots)
        spinner2.auto_spin
        result2 = x_client.post(message)
        results << result2
        if result2[:success]
          spinner2.success("✅")
        else
          spinner2.error("❌")
          puts "   Error: #{result2[:error]}"
        end
      end

      # Post to Nostr
      if services.include?(:nostr)
        nostr_client = Nostr.new(config['nostr'])
        spinner3 = TTY::Spinner.new("[:spinner] Posting to Nostr...", format: :dots)
        spinner3.auto_spin
        result3 = nostr_client.post(message)
        results << result3
        if result3[:success]
          spinner3.success("✅")
          puts "   #{result3[:details]}" if result3[:details]
        else
          spinner3.error("❌")
          puts "   Error: #{result3[:error]}"
        end
      end

      # Summary
      puts ""
      successes = results.count { |r| r[:success] }
      
      if successes == results.length
        box = TTY::Box.frame(
          "🎉 Successfully posted to all services!",
          padding: 1,
          border: :thick,
          style: {
            fg: :green,
            border: {
              fg: :green
            }
          }
        )
        puts box
      elsif successes > 0
        puts "⚠️  Posted to #{successes} out of #{results.length} services."
      else
        puts "❌ Failed to post to any service."
        exit 1
      end
    end
  end
end
