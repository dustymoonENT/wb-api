#!/bin/sh
set -e

# Update mix client
mix local.hex --force

# Ensure the app's dependencies are installed
mix deps.get
# Potentially Set up the database
mix ecto.create
mix ecto.migrate
echo " Launching Phoenix web server..."
mix phx.server
