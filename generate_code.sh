#!/bin/bash
echo "Running build_runner to generate freezed and json_serializable files..."
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
echo "Code generation complete!"
