#!/bin/bash

# Initialize an empty string to hold the env directives
env_directives=""

# Iterate through each environment variable, appending to the string
while IFS='=' read -r name value ; do
    # Skip LUA_PATH and LUA_CPATH and PATH
    if [[ $name == "LUA_PATH" || $name == "LUA_CPATH" || $name == "PATH" ]]; then
        continue
    fi
    env_directives="$env_directives env $name=$value;"
done < <(env)

# Now $env_directives contains a string of env directives with all the environment variables, except LUA_PATH and LUA_CPATH and PATH

# Use the env directives string in the openresty command
$OPENRESTY_BIN -g "$env_directives daemon off;"