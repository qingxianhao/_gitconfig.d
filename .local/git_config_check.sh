#!/bin/bash

# Count .ini files in the current directory
ini_count=$(find . -maxdepth 1 -name "*.ini" | wc -l)
ignored_count=$(git ls-files --ignored --other --exclude-standard | wc -l)
ignored_files=$(git ls-files --ignored --other --exclude-standard)

ini_count=$((ini_count - ignored_count))

temp_incs=$(mktemp)
cp -v includes.gitconfig $temp_incs
while IFS= read -r ignored_file; do
    # Extract just the file name (in case it’s a
    file_name=$(basename "$ignored_file")
    sed -i '/^path[[:space:]]*=[[:space:]]*'"$file_name"'$/d' "$temp_incs"
done <<< "$ignored_files"

# Count 'path' lines in the config file
path_count=$(grep -c "^[[:space:]]*path[[:space:]]*=" $temp_incs)

# Check if counts match
if [ "$ini_count" -ne "$path_count" ]; then
  echo "Error: The number of .ini files does not match the number of 'path' entries in the config."
  exit 1
fi

# Validate each path line
valid=1
while IFS= read -r line; do
  if [[ $line =~ ^[[:space:]]*path[[:space:]]*=[[:space:]]*(.*)$ ]]; then
    path_value="${BASH_REMATCH[1]}"
    if [[ -z "$path_value" || ! -f "$path_value" ]]; then
      echo "Invalid path: $path_value"
      valid=0
      break
    fi
  fi
done < "$temp_incs"

if [ "$valid" -eq 1 ]; then
  echo "All paths are valid."
  exit 0
else
  echo "One or more paths are invalid."
  exit 1
fi
