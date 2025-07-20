#!/bin/bash

# Poseidon2 Circuit Compilation Script
# This script compiles the Poseidon2 circuits using Circom

set -e

echo "Starting Poseidon2 circuit compilation..."

# Create build directory
CIRCUITS_DIR="circuits/poseidon2"
BUILD_DIR="build"
mkdir -p $BUILD_DIR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Compile main Poseidon2 circuit
echo_status "Compiling main Poseidon2 circuit..."
circom $CIRCUITS_DIR/poseidon2.circom --r1cs --wasm --sym --c -o $BUILD_DIR/

if [ $? -eq 0 ]; then
    echo_status "Main circuit compiled successfully!"
else
    echo_error "Failed to compile main circuit!"
    exit 1
fi

# Compile test circuit
echo_status "Compiling test circuit..."
circom $CIRCUITS_DIR/tests/poseidon2_test.circom --r1cs --wasm --sym --c -o $BUILD_DIR/

if [ $? -eq 0 ]; then
    echo_status "Test circuit compiled successfully!"
else
    echo_error "Failed to compile test circuit!"
    exit 1
fi

# Display circuit information
echo_status "Circuit compilation completed!"
echo ""
echo "Generated files:"
echo "  - $BUILD_DIR/poseidon2.r1cs"
echo "  - $BUILD_DIR/poseidon2_js/"
echo "  - $BUILD_DIR/poseidon2.sym"
echo "  - $BUILD_DIR/poseidon2_cpp/"
echo "  - $BUILD_DIR/poseidon2_test.r1cs"
echo "  - $BUILD_DIR/poseidon2_test_js/"
echo ""

# Show circuit statistics
if command -v snarkjs &> /dev/null; then
    echo_status "Circuit statistics:"
    echo "Main circuit:"
    snarkjs r1cs info $BUILD_DIR/poseidon2.r1cs
    echo ""
    echo "Test circuit:"
    snarkjs r1cs info $BUILD_DIR/poseidon2_test.r1cs
else
    echo_warning "snarkjs not found, skipping circuit statistics"
fi

echo_status "Compilation script completed successfully!"