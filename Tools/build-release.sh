#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
build_dir="$repo_dir/build"

xcodebuild -project "$repo_dir/Mouse Fix.xcodeproj" \
  -scheme "App - Release" -configuration Release \
  -derivedDataPath "$build_dir" \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= \
  PROVISIONING_PROFILE_SPECIFIER= ENABLE_HARDENED_RUNTIME=NO \
  OTHER_CODE_SIGN_FLAGS=--deep build

app="$build_dir/Build/Products/Release/Mac E-Mouse.app"
codesign --verify --deep --strict "$app"
printf '\nBuilt %s\n' "$app"
