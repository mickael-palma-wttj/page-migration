#!/usr/bin/env bash
set -e

echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential libpq-dev

echo "Installing root dependencies..."
bundle install

echo "Installing web app dependencies..."
cd web
bundle install

echo "Preparing database..."
bin/rails db:prepare

echo "Loading cable schema..."
bin/rails db:schema:load:cable || true

echo "Setup complete!"
