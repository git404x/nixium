#!/usr/bin/env bash
set -e

echo "Updating Nixium Modpack hashes..."

update_hash() {
  local target=$1
  echo "Hashing $target..."
  
  # Temporarily reset hash in versions.json
  jq ".[\"$target\"].hash = \"\"" versions.json > tmp.json && mv tmp.json versions.json
  
  # Nix will fail to build because of the empty packHash in default.nix. 
  # We elegantly extract the correct one from the error message.
  local output
  set +e
  output=$(nix-build -A "$target" 2>&1)
  set -e
  
  local hash
  hash=$(echo "$output" | grep -oP 'got:\s+\Ksha256-[a-zA-Z0-9+/=]+' || true)
  
  if [[ -n "$hash" ]]; then
    echo "✔ Found hash for $target: $hash"
    jq ".[\"$target\"].hash = \"$hash\"" versions.json > tmp.json && mv tmp.json versions.json
  else
    echo "❌ Failed to evaluate hash for $target"
    echo "$output"
    exit 1
  fi
}

update_hash "server"
update_hash "client"

echo "Update complete!"
