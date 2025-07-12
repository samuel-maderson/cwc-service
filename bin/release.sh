#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get current version from git tags or default to 0.1.0
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null)
if [[ -z "$CURRENT_VERSION" ]]; then
    NEW_VERSION="0.1.0"
    echo -e "${GREEN}No existing tags found. Setting initial version to $NEW_VERSION${NC}"
else
    echo -e "${GREEN}Current version: $CURRENT_VERSION${NC}"
    # Parse version components
    IFS='.' read -r MAJOR MINOR PATCH <<< "${CURRENT_VERSION#v}"

    # Ask for version type
    read -p "Is this a major version? (y/n): " major_input
    if [[ $major_input == "y" ]]; then
        NEW_VERSION="$((MAJOR + 1)).0.0"
    else
        read -p "Is this a minor version? (y/n): " minor_input
        if [[ $minor_input == "y" ]]; then
            NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
        else
            read -p "Is this a patch version? (y/n): " patch_input
            if [[ $patch_input == "y" ]]; then
                NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
            else
                echo -e "${RED}No version type selected. Exiting.${NC}"
                exit 1
            fi
        fi
    fi
fi

# Update CHANGELOG.md
sed -i '' "s/## \[Unreleased\]/## [Unreleased]\n\n## [${NEW_VERSION}] - $(date +%Y-%m-%d)/" CHANGELOG.md

# Create git tag
git add CHANGELOG.md
git commit -m "Release v${NEW_VERSION}"
git tag "v${NEW_VERSION}"

echo -e "${GREEN}Created version v${NEW_VERSION}${NC}"