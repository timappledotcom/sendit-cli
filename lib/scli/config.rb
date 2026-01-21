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

      save(config)
      puts "\n✅ Configuration saved to #{CONFIG_FILE}"
      config
    end
  end
end
