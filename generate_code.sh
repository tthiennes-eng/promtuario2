#!/bin/bash
# Script para gerar código do build_runner (freezed, json_serializable, drift, riverpod)

set -e

echo "Cleaning build and caches (corrige erros de FFI/InvalidType por cache corrompido)..."
flutter clean || true
rm -rf .dart_tool build

echo "Resolving dependencies..."
flutter pub get

echo "Running build_runner to generate code..."
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo "Code generation completed successfully!"
else
    echo "Code generation failed. Please check the errors above."
    exit 1
fi
