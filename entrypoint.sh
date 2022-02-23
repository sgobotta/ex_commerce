#!/bin/bash

bin="/app/bin/ex_commerce"

# Create db if not exists
# echo "Attempting to create db..."
# eval "$bin eval \"ExCommerce.Release.create_db\""

# Migrate the database
echo "Starting Migrations..."
eval "$bin eval \"ExCommerce.Release.migrate\""

# Start the elixir application
echo "Starting Application..."
exec "$bin" "start"
