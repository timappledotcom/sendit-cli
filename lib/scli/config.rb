require 'yaml'
require 'fileutils'

module SCLI
  class Config
    CONFIG_DIR = File.expand_path('~/.scli')
    CONFIG_FILE = File.join(CONFIG_DIR, 'config.yml')

    def self.exists?
      File.exist?(CONFIG_FILE)
    end

    def self.load
      return nil unless exists?
      YAML.load_file(CONFIG_FILE)
    end

    def self.save(config)
      FileUtils.mkdir_p(CONFIG_DIR)
      File.write(CONFIG_FILE, config.to_yaml)
      File.chmod(0600, CONFIG_FILE)
    end

    def self.setup
      require 'tty-prompt'
      prompt = TTY::Prompt.new

      puts "\n🚀 Welcome to SendIt! Let's set up your accounts.\n\n"

      config = {}
      
      # MicroBlog credentials
      puts "📝 Micro.blog Configuration"
      config['microblog'] = {
        'access_token' => prompt.ask('Micro.blog access token:', required: true)
      }

      puts "\n"

      # X credentials
      puts "🐦 X (Twitter) Configuration"
      config['x'] = {
        'api_key' => prompt.ask('X API key:', required: true),
        'api_secret' => prompt.mask('X API secret:', required: true),
        'access_token' => prompt.ask('X access token:', required: true),
        'access_secret' => prompt.mask('X access token secret:', required: true)
      }

      puts "\n"

      # Nostr credentials
      puts "⚡ Nostr Configuration"
      auth_method = prompt.select('Choose authentication method:', [
        { name: 'nsec key (bech32 format)', value: 'nsec' },
        { name: 'Pleb Signer (via D-Bus)', value: 'pleb_signer' }
      ])

      if auth_method == 'pleb_signer'
        # Check if Pleb Signer is available
        begin
          require 'dbus'
          dbus = DBus::SessionBus.instance
          service = dbus.service('com.plebsigner.Signer')
          signer = service.object('/com/plebsigner/Signer')
          signer.introspect
          signer_interface = signer['com.plebsigner.Signer1']
          
          is_ready = signer_interface.IsReady[0]
          if is_ready
            puts "✅ Pleb Signer connected successfully!"
            config['nostr'] = { 'use_pleb_signer' => true }
          else
            puts "⚠️  Pleb Signer is locked. Please unlock it and try again."
            exit 1
          end
        rescue => e
          puts "❌ Could not connect to Pleb Signer: #{e.message}"
          puts "   Make sure Pleb Signer is installed and running."
          exit 1
        end
      else
        # nsec key
        nsec = prompt.ask('Enter your nsec key:', required: true) do |q|
          q.validate /^nsec1[a-z0-9]+$/
          q.messages[:valid?] = 'Invalid nsec format. Should start with nsec1'
        end
        config['nostr'] = { 'nsec' => nsec }
      end

      # Relay configuration
      use_defaults = prompt.yes?('Use default Nostr relays? (wss://relay.pleb.one, wss://relay.primal.net, wss://relay.damus.io, wss://relay.snort.social)')
      
      if use_defaults
        config['nostr']['relays'] = [
          'wss://relay.pleb.one',
          'wss://relay.primal.net',
          'wss://relay.damus.io',
          'wss://relay.snort.social'
        ]
      else
        relays = []
        loop do
          relay = prompt.ask('Enter relay URL (or press Enter to finish):', default: '')
          break if relay.empty?
          relays << relay
        end
        config['nostr']['relays'] = relays if relays.any?
      end

      save(config)
      puts "\n✅ Configuration saved to #{CONFIG_FILE}"
      config
    end
  end
end
