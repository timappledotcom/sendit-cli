require 'nostr'

module SCLI
  class Nostr
    DEFAULT_RELAYS = [
      'wss://relay.pleb.one',
      'wss://relay.primal.net',
      'wss://relay.damus.io',
      'wss://relay.snort.social'
    ]

    def initialize(config)
      @use_pleb_signer = config['use_pleb_signer']
      @nsec = config['nsec']
      @relays = config['relays'] || DEFAULT_RELAYS
      
      if @use_pleb_signer
        setup_pleb_signer
      elsif @nsec
        setup_nsec_key
      else
        raise "No Nostr authentication method configured"
      end
    end

    def post(message)
      if @use_pleb_signer
        post_with_pleb_signer(message)
      else
        post_with_nsec(message)
      end
    rescue => e
      { success: false, service: 'Nostr', error: e.message }
    end

    private

    def setup_nsec_key
      # Decode nsec to get the private key
      type, private_key_hex = ::Nostr::Bech32.decode(@nsec)
      
      if type != 'nsec'
        raise "Invalid nsec format. Expected nsec, got #{type}"
      end
      
      @keypair = ::Nostr::KeyPair.new(private_key: private_key_hex)
    end

    def setup_pleb_signer
      require 'dbus'
      
      begin
        @dbus = DBus::SessionBus.instance
        service = @dbus.service('com.plebsigner.Signer')
        @pleb_signer = service.object('/com/plebsigner/Signer')
        @pleb_signer.introspect
        @pleb_signer_interface = @pleb_signer['com.plebsigner.Signer1']
        
        # Check if signer is ready
        is_ready = @pleb_signer_interface.IsReady[0]
        unless is_ready
          raise "Pleb Signer is not unlocked. Please unlock it first."
        end
        
        # Get public key to verify connection
        pubkey_result = @pleb_signer_interface.GetPublicKey[0]
        pubkey_data = JSON.parse(pubkey_result)
        @pubkey = pubkey_data['npub']
      rescue DBus::Error => e
        raise "Failed to connect to Pleb Signer: #{e.message}. Is it running?"
      end
    end

    def post_with_nsec(message)
      # Create a text note event (kind 1)
      event = ::Nostr::Event.new(
        pubkey: @keypair.public_key,
        created_at: Time.now.to_i,
        kind: 1,
        tags: [],
        content: message
      )
      
      # Sign the event
      event.sign(@keypair.private_key)
      
      # Post to relays
      publish_to_relays(event)
    end

    def post_with_pleb_signer(message)
      # Create unsigned event
      event_json = {
        kind: 1,
        content: message,
        tags: [],
        created_at: Time.now.to_i
      }.to_json
      
      # Sign via D-Bus
      signed_result = @pleb_signer_interface.SignEvent(event_json, 'sendit-cli')[0]
      signed_data = JSON.parse(signed_result)
      
      unless signed_data['success']
        error = signed_data['error'] || 'Unknown error'
        raise "Pleb Signer error: #{error}"
      end
      
      # Parse the double-encoded result
      result_data = JSON.parse(signed_data['result'])
      event_data = JSON.parse(result_data['event_json'])
      event = ::Nostr::Event.new(
        id: event_data['id'],
        pubkey: event_data['pubkey'],
        created_at: event_data['created_at'],
        kind: event_data['kind'],
        tags: event_data['tags'],
        content: event_data['content'],
        sig: event_data['sig']
      )
      
      # Post to relays
      publish_to_relays(event)
    end

    def publish_to_relays(event)
      client = ::Nostr::Client.new(logger: nil)
      
      # Connect to all relays first
      @relays.each do |relay_url|
        relay = ::Nostr::Relay.new(url: relay_url, name: relay_url)
        client.connect(relay)
      end
      
      # Wait for connections to establish
      sleep 2
      
      # Publish the event (goes to all connected relays)
      client.publish(event)
      
      # Wait for publish to complete
      sleep 2
      
      # Assume success if we got here
      { 
        success: true, 
        service: 'Nostr', 
        details: "Posted to #{@relays.length} relays"
      }
    rescue => e
      { 
        success: false, 
        service: 'Nostr', 
        error: e.message
      }
    end
  end
end
