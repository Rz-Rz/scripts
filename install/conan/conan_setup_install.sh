#!/bin/bash
set -e

# -----------------------------------------------------------------------------
# This script sets up the build environment by:
# 1. Installing Conan (if not already installed) using sudo pip.
# 2. Configuring the Conan profile for the current architecture.
# 3. Creating and entering the 'build' directory.
# 4. Installing project dependencies using Conan.
# 5. Configuring the project with CMake.
# -----------------------------------------------------------------------------

# Check if pip is available
if ! command -v pip &>/dev/null; then
    echo "pip is required but not installed. Please install pip first."
    exit 1
fi

# Install Conan (run with sudo)
echo "Installing Conan..."
sudo pip install conan

# Detect and configure the Conan profile for the current architecture
echo "Detecting Conan profile..."
conan profile detect

# Create the build directory if it doesn't already exist and change to it
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Install project dependencies using Conan
echo "Installing dependencies with Conan..."
conan install .. -of=. --build=missing \
    -s:h compiler.cppstd=gnu17 \
    -s:b compiler.cppstd=gnu17 \
    -c tools.system.package_manager:mode=install \
    -c tools.system.package_manager:sudo=true

# Configure the project using CMake
echo "Configuring the project with CMake..."
cmake .. -G "Unix Makefiles" \
    -DCMAKE_TOOLCHAIN_FILE=build/Release/generators/conan_toolchain.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_SYSTEM_GSTREAMER=1

echo "Build configuration completed successfully."

