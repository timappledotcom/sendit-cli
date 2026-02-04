# SendIt CLI

A Ruby CLI tool for posting to Micro.blog, X (Twitter), and Nostr simultaneously.

## Installation

### Pre-built Packages

**Debian/Ubuntu (.deb)**
```bash
wget https://github.com/timappledotcom/sendit-cli/releases/download/v1.0.0/sendit-cli_1.0.0_amd64.deb
sudo dpkg -i sendit-cli_1.0.0_amd64.deb
sudo bundle install --system
```

**Arch Linux (.pkg.tar.zst)**
```bash
wget https://github.com/timappledotcom/sendit-cli/releases/download/v1.0.0/sendit-cli-1.0.0-1-x86_64.pkg.tar.zst
sudo pacman -U sendit-cli-1.0.0-1-x86_64.pkg.tar.zst
```

**Fedora/RHEL/Rocky Linux (.rpm)**
```bash
wget https://github.com/timappledotcom/sendit-cli/releases/download/v1.0.0/sendit-cli-1.0.0-1.el9.x86_64.rpm
sudo dnf install sendit-cli-1.0.0-1.el9.x86_64.rpm
sudo bundle install --system
```

**From Tarball (All Linux distros)**
```bash
wget https://github.com/timappledotcom/sendit-cli/releases/download/v1.0.0/sendit-cli-1.0.0-linux-x86_64.tar.gz
tar -xzf sendit-cli-1.0.0-linux-x86_64.tar.gz
cd sendit-cli-1.0.0-linux-x86_64
./install.sh
```

### From Source

1. Clone this repository
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Make the executable accessible:
   ```bash
   chmod +x bin/scli
   ```
4. Optionally, add to your PATH or create a symlink:
   ```bash
   ln -s /path/to/scli/bin/scli /usr/local/bin/scli
   ```

## Usage

### First Run Setup

On first run, SendIt will prompt you for credentials:

```bash
./bin/scli "Hello world!"
```

You'll be asked for:
- **Micro.blog**: Access token (generate at Settings > App tokens)
- **X (Twitter)**: API key, API secret, access token, access token secret
- **Nostr**: Authentication method (nsec key or Pleb Signer) and relay URLs

Credentials are stored securely in `~/.scli/config.yml` with 0600 permissions.

### Posting Messages

Simply run:

```bash
scli "Your message here"
```

The message will be posted to Micro.blog, X, and Nostr simultaneously.

### Features

- Interactive credential setup on first run
- Simultaneous posting to three services (Micro.blog, X, Nostr)
- Multiple Nostr authentication methods (nsec or Pleb Signer)
- Real-time progress spinners
- Beautiful success/error messages
- 280 character limit validation
- Secure credential storage
- Multi-relay Nostr support

## Configuration

Configuration is stored in `~/.scli/config.yml`:

```yaml
microblog:
  access_token: your_access_token
x:
  api_key: your_api_key
  api_secret: your_api_secret
  access_token: your_access_token
  access_secret: your_access_token_secret
nostr:
  # Option 1: Use nsec key
  nsec: nsec1...
  # Option 2: Use Pleb Signer
  use_pleb_signer: true
  # Relay configuration
  relays:
    - wss://relay.pleb.one
    - wss://relay.primal.net
    - wss://relay.damus.io
    - wss://relay.snort.social
```

To reconfigure, delete `~/.scli/config.yml` and run the command again.

## Getting API Credentials

### Micro.blog
1. Log in to your Micro.blog account
2. Go to Settings > App tokens
3. Create a new token with posting permissions

### X (Twitter)
1. Visit the [X Developer Portal](https://developer.x.com/en/portal/dashboard)
2. Create a new project and app
3. Set permissions to "Read and Write"
4. Generate API keys and access tokens

### Nostr

**Option 1: nsec Key**
1. If you already have a Nostr account, use your existing nsec key
2. Or generate a new keypair using any Nostr client (e.g., Damus, Amethyst, Snort)
3. Your nsec key starts with `nsec1` and should be kept secure

**Option 2: Pleb Signer (Recommended for security)**
1. Install Pleb Signer from [GitHub](https://github.com/PlebOne/Pleb_Signer)
2. Start Pleb Signer: `pleb-signer`
3. Create or import your Nostr key in Pleb Signer
4. Unlock the signer when prompted by SendIt
5. Your keys never leave the secure vault

**Default Relays:**
- wss://relay.pleb.one
- wss://relay.primal.net
- wss://relay.damus.io
- wss://relay.snort.social

## Examples

```bash
# Post a simple message
scli "Just shipped a new feature!"

# Post with quotes
scli "As Einstein said, 'Imagination is more important than knowledge.'"

# Multi-word messages
scli Check out my new blog post about Ruby!
```

## Requirements

- Ruby 2.7+
- Bundler

## Dependencies

- tty-prompt: Interactive CLI prompts
- tty-spinner: Progress spinners
- tty-box: Formatted output boxes
- oauth: OAuth authentication for X API
- typhoeus: HTTP client
- nostr: Nostr protocol implementation
- ruby-dbus: D-Bus communication (for Pleb Signer)

## API Documentation

- [Micro.blog Micropub API](https://help.micro.blog/t/micropub-api/95)
- [X API v2 Documentation](https://developer.x.com/en/docs/twitter-api)
- [Nostr Protocol](https://nostr.how/en/the-protocol)
- [NIP-19: bech32-encoded entities](https://github.com/nostr-protocol/nips/blob/master/19.md)
- [NIP-55: Android Signer Application](https://github.com/nostr-protocol/nips/blob/master/55.md)
- [Pleb Signer GitHub](https://github.com/PlebOne/Pleb_Signer)

## License

MIT

