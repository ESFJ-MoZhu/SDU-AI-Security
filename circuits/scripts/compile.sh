#!/bin/bash

# Poseidon2 Circuit Compilation Script
# This script compiles the Poseidon2 circuits using Circom 2.x

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

# Check for circom
if ! command -v circom &> /dev/null; then
    echo_error "circom not found! Please install Circom 2.x"
    exit 1
fi

CIRCOM_VERSION=$(circom --version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
echo_status "Using Circom version: $CIRCOM_VERSION"

# Compile main Poseidon2 circuit
echo_status "Compiling main Poseidon2 circuit..."
circom $CIRCUITS_DIR/poseidon2_minimal.circom --r1cs --wasm --sym -o $BUILD_DIR/

if [ $? -eq 0 ]; then
    echo_status "Main circuit compiled successfully!"
else
    echo_error "Failed to compile main circuit!"
    exit 1
fi

# Compile calculator circuit (for testing)
echo_status "Compiling calculator circuit..."
circom $CIRCUITS_DIR/poseidon2_calculator.circom --r1cs --wasm --sym -o $BUILD_DIR/

if [ $? -eq 0 ]; then
    echo_status "Calculator circuit compiled successfully!"
else
    echo_error "Failed to compile calculator circuit!"
    exit 1
fi

# Display circuit information
echo_status "Circuit compilation completed!"
echo ""
echo "Generated files:"
echo "  - $BUILD_DIR/poseidon2_minimal.r1cs"
echo "  - $BUILD_DIR/poseidon2_minimal_js/"
echo "  - $BUILD_DIR/poseidon2_minimal.sym"
echo ""

# Show circuit statistics
if command -v snarkjs &> /dev/null; then
    echo_status "Circuit statistics:"
    echo "Main circuit:"
    snarkjs r1cs info $BUILD_DIR/poseidon2_minimal.r1cs
    echo ""
else
    echo_warning "snarkjs not found, skipping circuit statistics"
fi

echo_status "Compilation script completed successfully!"
echo ""
echo "Next steps:"
echo "  1. Run setup.sh to perform trusted setup"
echo "  2. Run prove.sh to generate and verify proofs"