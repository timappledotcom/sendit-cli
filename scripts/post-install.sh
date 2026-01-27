#!/bin/bash
# Post-install script for sendit-cli
# Installs Ruby gem dependencies that aren't available as system packages

gem install --no-document tty-prompt tty-spinner tty-box oauth typhoeus
