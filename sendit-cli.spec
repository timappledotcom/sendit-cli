Name:           sendit-cli
Version:        1.1.0
Release:        1%{?dist}
Summary:        CLI tool for posting to Micro.blog, X, and Nostr simultaneously

License:        MIT
URL:            https://github.com/timappledotcom/sendit-cli
Source0:        sendit-cli-1.1.0-linux-x86_64.tar.gz

Requires:       ruby >= 2.7

%post
gem install --no-document tty-prompt tty-spinner tty-box oauth typhoeus nostr ruby-dbus

%description
SendIt CLI is a Ruby command-line tool that allows you to post messages
simultaneously to Micro.blog, X (Twitter), and Nostr from the terminal.

%prep
%setup -q -c

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/usr/local/lib/scli
cp -r lib/* %{buildroot}/usr/local/lib/scli/
cp bin/scli %{buildroot}/usr/local/bin/scli
chmod +x %{buildroot}/usr/local/bin/scli

# Update the executable to use installed library path
sed -i "s|require_relative '../lib/scli'|require '/usr/local/lib/scli/scli'|" %{buildroot}/usr/local/bin/scli

%files
/usr/local/bin/scli
/usr/local/lib/scli/*

%changelog
* Wed Feb 04 2026 SendIt CLI <noreply@example.com> - 1.1.0-1
- Feature: Add Nostr protocol support with nsec and Pleb Signer authentication
- Feature: Multi-relay Nostr posting support
- Updated: Dependencies include nostr and ruby-dbus gems

* Tue Jan 27 2026 SendIt CLI <noreply@example.com> - 1.0.2-1
- Fix: Use post-install script for all packages to install gems

* Mon Jan 27 2026 SendIt CLI <noreply@example.com> - 1.0.1-1
- Fix: Add Ruby gem dependencies to package requirements

* Wed Jan 22 2026 SendIt CLI <noreply@example.com> - 1.0.0-1
- Initial release
