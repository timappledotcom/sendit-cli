Name:           sendit-cli
Version:        1.0.0
Release:        1%{?dist}
Summary:        CLI tool for posting to Micro.blog and X simultaneously

License:        MIT
URL:            https://github.com/timappledotcom/sendit-cli
Source0:        sendit-cli-1.0.0-linux-x86_64.tar.gz

Requires:       ruby >= 2.7
Requires:       rubygem-bundler

%description
SendIt CLI is a Ruby command-line tool that allows you to post messages
simultaneously to Micro.blog and X (Twitter) from the terminal.

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
* Wed Jan 22 2026 SendIt CLI <noreply@example.com> - 1.0.0-1
- Initial release
