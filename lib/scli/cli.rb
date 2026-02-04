require 'tty-spinner'
require 'tty-box'

module SCLI
  class CLI
    def self.run(args)
      # Check if configuration exists
      unless Config.exists?
        Config.setup
        puts ""
      end

      # Validate arguments
      if args.empty?
        puts "❌ Error: Please provide a message to post."
        puts "Usage: scli \"Your message here\""
        exit 1
      end

      message = args.join(' ')

      # Validate message length (typical social media limit)
      if message.length > 280
        puts "❌ Error: Message is too long (#{message.length} characters). Maximum is 280."
        exit 1
      end

      post(message)
    end

    def self.post(message)
      config = Config.load

      # Initialize service clients
      microblog = MicroBlog.new(config['microblog'])
      x_client = X.new(config['x'])
      nostr_client = Nostr.new(config['nostr'])

      puts "\n📤 Posting to Micro.blog, X, and Nostr...\n"

      results = []
      
      # Post to Micro.blog
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

      # Post to X
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

      # Post to Nostr
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
