#!/usr/bin/env bash
set -e

echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential libpq-dev

echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "Installing root dependencies..."
bundle install

echo "Installing web app dependencies..."
cd web
bundle install

echo "Installing npm dependencies..."
npm install

echo "Installing Playwright browsers and dependencies..."
npx playwright install chromium --with-deps

echo "Preparing database..."
bin/rails db:prepare

echo "Loading cable schema..."
bin/rails db:schema:load:cable || true

echo "Setup complete!"
echo ""
echo "To run e2e tests: cd web && npm test"
echo "To run e2e tests with UI: cd web && npm run test:ui"
