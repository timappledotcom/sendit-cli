# SendIt CLI v1.0.1

## What's New

- Fix: Ruby gem dependencies now installed automatically during package installation
- No longer requires manual `gem install` or `bundle install` after installing

## Installation

### Debian/Ubuntu (.deb)
```bash
wget https://github.com/timappledotcom/sendit-cli/releases/download/v1.0.1/sendit-cli_1.0.1_amd64.deb
sudo dpkg -i sendit-cli_1.0.1_amd64.deb
```

### Arch Linux (.pkg.tar.zst)
```bash
wget https://github.com/timappledotcom/sendit-cli/releases/download/v1.0.1/sendit-cli-1.0.1-1-x86_64.pkg.tar.zst
sudo pacman -U sendit-cli-1.0.1-1-x86_64.pkg.tar.zst
```

### Fedora/RHEL/Rocky Linux (.rpm)
```bash
wget https://github.com/timappledotcom/sendit-cli/releases/download/v1.0.1/sendit-cli-1.0.1-1.el9.x86_64.rpm
sudo dnf install sendit-cli-1.0.1-1.el9.x86_64.rpm
```

### From Source (.tar.gz)
```bash
wget https://github.com/timappledotcom/sendit-cli/releases/download/v1.0.1/sendit-cli-1.0.1-linux-x86_64.tar.gz
tar -xzf sendit-cli-1.0.1-linux-x86_64.tar.gz
cd sendit-cli-1.0.1-linux-x86_64
./install.sh
```

## Usage

```bash
scli "Your message here"
```

On first run, you'll be prompted to enter your Micro.blog and X API credentials.

## Full Changelog

https://github.com/timappledotcom/sendit-cli/compare/v1.0.0...v1.0.1

---

# SendIt CLI v1.0.0

## What's New

- Initial release of SendIt CLI
- Post to Micro.blog and X (Twitter) simultaneously from the command line
- Interactive credential setup on first run
- Secure credential storage in ~/.scli/config.yml
- Real-time posting with progress spinners
- 280 character limit validation

## Full Changelog

https://github.com/timappledotcom/sendit-cli/commits/v1.0.0
