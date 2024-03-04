#!/bin/sh

# File to check existence
db_version_old="${INVENTREE_HOME}/db_version.old"
# get current version
new_version=$(grep -oP 'INVENTREE_SW_VERSION\s*=\s*"\K[^"]+' InvenTree/InvenTree/version.py)
echo "To install DB version $new_version"

# Check if the file exists
if [ ! -e "$db_version_old" ]; then
    echo "No current version found -> New Installation of the DB is getting initialised"
    # Run setup command
    invoke update || exit 2

    echo "$new_version">>"$db_version_old"
    echo "Setup command completed."
fi

old_version=$(cat "$db_version_old")
echo "Current version $old_version"
# Number to compare (replace with your actual value)

# Check if the stored version is smaller than new one
if [ "$(awk -v num1="$new_version" -v num2="$old_version" 'BEGIN { print (num1 < num2) }')" -eq 1 ]; then
    echo "Error: Downgrade of version is not allowed."
    echo "Old DB version was $old_version, and the new version is $new_version"
    exit 1
fi

if [ "$(awk -v num1=$old_version -v num2=$new_version 'BEGIN { print (num1 < num2) }')" -eq 1 ]; then
    echo "DB upgrade available: Version was $old_version, new version is $new_version"

    # Run update command
    invoke update || exit 2

    echo "Update successful"

    # Copy the old version to the new version after update
    cp  "$db_version_new" "$db_version_old"
fi

echo "Database migration/update checks completed."
