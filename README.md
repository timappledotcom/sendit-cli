# SendIt CLI

A Ruby CLI tool for posting to Micro.blog and X (Twitter) simultaneously.

## Installation

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

Credentials are stored securely in `~/.scli/config.yml` with 0600 permissions.

### Posting Messages

Simply run:

```bash
scli "Your message here"
```

The message will be posted to both Micro.blog and X simultaneously.

### Features

- Interactive credential setup on first run
- Simultaneous posting to both services
- Real-time progress spinners
- Beautiful success/error messages
- 280 character limit validation
- Secure credential storage

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

## API Documentation

- [Micro.blog Micropub API](https://help.micro.blog/t/micropub-api/95)
- [X API v2 Documentation](https://developer.x.com/en/docs/twitter-api)

## License

MIT

