# Packaging Guide

This document describes how to build distribution packages for SendIt CLI.

## Prerequisites

- Ruby 2.7+
- fpm gem: `gem install fpm`
- Docker (for RPM builds)

## Important Notes

### Executable Path Configuration

**CRITICAL**: When building packages, the executable at `pkg/usr/local/bin/scli` MUST be updated to use absolute paths, not relative paths.

**Correct:**
```ruby
#!/usr/bin/env ruby

$LOAD_PATH.unshift('/usr/local/lib/scli')

require 'scli'

SCLI::CLI.run(ARGV)
```

**Incorrect:**
```ruby
#!/usr/bin/env ruby

require_relative '../lib/scli'  # This will fail when installed!

SCLI::CLI.run(ARGV)
```

The relative path works during development but breaks when the executable is installed to `/usr/local/bin/` because the relative path no longer points to the correct location.

## Build Process

### 1. Prepare Package Directory

```bash
# Clean and create directory structure
rm -rf pkg
mkdir -p pkg/usr/local/bin pkg/usr/local/lib/scli

# Copy library files
cp -r lib/* pkg/usr/local/lib/scli/

# Copy executable
cp bin/scli pkg/usr/local/bin/scli
chmod +x pkg/usr/local/bin/scli
```

### 2. Fix Executable Paths

**IMPORTANT**: Edit `pkg/usr/local/bin/scli` to use absolute paths as shown above.

### 3. Build Debian Package

```bash
fpm -s dir -t deb -n sendit-cli -v 1.0.2 \
  --description "CLI tool for posting to Micro.blog and X simultaneously" \
  --url "https://github.com/timappledotcom/sendit-cli" \
  --maintainer "SendIt CLI <noreply@example.com>" \
  --license MIT \
  --depends ruby \
  --after-install scripts/post-install.sh \
  --deb-no-default-config-files \
  -C pkg \
  usr/local/bin/scli usr/local/lib/scli
```

### 4. Create Post-Install Script (for Arch)

Arch doesn't have the TTY gems in official repos, so we use a post-install script:

```bash
mkdir -p scripts
cat > scripts/post-install.sh << 'EOF'
#!/bin/bash
gem install --no-document tty-prompt tty-spinner tty-box oauth typhoeus
EOF
chmod +x scripts/post-install.sh
```

### 5. Build Arch Package

```bash
fpm -s dir -t pacman -n sendit-cli -v 1.0.2 \
  --description "CLI tool for posting to Micro.blog and X simultaneously" \
  --url "https://github.com/timappledotcom/sendit-cli" \
  --maintainer "SendIt CLI <noreply@example.com>" \
  --license MIT \
  --depends ruby \
  --depends rubygems \
  --after-install scripts/post-install.sh \
  -C pkg \
  usr/local/bin/scli usr/local/lib/scli
```

### 5. Build RPM Package

First, create the tarball:

```bash
tar -czf sendit-cli-1.0.2-linux-x86_64.tar.gz bin lib Gemfile README.md LICENSE install.sh
```

Then build with Docker:

```bash
docker run --rm -v $(pwd):/workspace -w /workspace rockylinux:9 bash -c "
  dnf install -y rpm-build rpmdevtools &&
  mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS} &&
  cp sendit-cli-1.0.2-linux-x86_64.tar.gz ~/rpmbuild/SOURCES/ &&
  cp sendit-cli.spec ~/rpmbuild/SPECS/ &&
  rpmbuild -ba ~/rpmbuild/SPECS/sendit-cli.spec &&
  cp ~/rpmbuild/RPMS/x86_64/*.rpm /workspace/
"
```

### 6. Build Source Tarball

```bash
chmod +x install.sh
tar -czf sendit-cli-1.0.2-linux-x86_64.tar.gz bin lib Gemfile README.md LICENSE install.sh
```

## Verification

After building packages, verify they work:

### Test Debian Package
```bash
dpkg -c sendit-cli_1.0.2_amd64.deb
```

### Test Arch Package
```bash
tar -tzf sendit-cli-1.0.2-1-x86_64.pkg.tar.zst
# Check the executable:
tar -xOf sendit-cli-1.0.2-1-x86_64.pkg.tar.zst usr/local/bin/scli | head -10
```

### Test RPM Package
```bash
rpm -qlp sendit-cli-1.0.2-1.el9.x86_64.rpm
```

## Release Checklist

- [ ] Update version in `lib/scli.rb`
- [ ] Clean pkg directory: `rm -rf pkg`
- [ ] Rebuild all packages following steps above
- [ ] Verify executable paths in each package
- [ ] Test install on each platform if possible
- [ ] Create git tag: `git tag v1.0.2`
- [ ] Push tag: `git push origin v1.0.2`
- [ ] Create GitHub release
- [ ] Upload all packages to release
- [ ] Update README.md with new version numbers

## Common Issues

### Issue: "exit status 1" during Arch package install
**Cause**: Executable has `require_relative '../lib/scli'` instead of absolute path
**Fix**: Update `pkg/usr/local/bin/scli` with absolute paths before building

### Issue: RPM build fails with "cd: sendit-cli-1.0.2-linux-x86_64: No such file or directory"
**Cause**: Tarball doesn't extract to expected directory name
**Fix**: Use `%setup -q -c` in spec file instead of `%setup -q -n dirname`
