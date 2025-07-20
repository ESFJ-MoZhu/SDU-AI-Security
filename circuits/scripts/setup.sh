#!/bin/bash

# Poseidon2 Trusted Setup Script
# This script performs the trusted setup for Groth16 proofs

set -e

BUILD_DIR="build"
SETUP_DIR="setup"
CIRCUIT_NAME="poseidon2"

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

# Check if circuit is compiled
if [ ! -f "$BUILD_DIR/${CIRCUIT_NAME}.r1cs" ]; then
    echo_error "Circuit not found! Please run compile.sh first."
    exit 1
fi

# Create setup directory
mkdir -p $SETUP_DIR

echo_status "Starting trusted setup for Poseidon2 circuit..."

# Step 1: Start a new "powers of tau" ceremony
echo_status "Step 1: Generating initial powers of tau..."
POWER=14  # 2^14 = 16384 constraints (should be enough for our circuit)
snarkjs powersoftau new bn128 $POWER $SETUP_DIR/pot12_0000.ptau -v

# Step 2: Contribute to the ceremony
echo_status "Step 2: Contributing to powers of tau ceremony..."
snarkjs powersoftau contribute $SETUP_DIR/pot12_0000.ptau $SETUP_DIR/pot12_0001.ptau --name="First contribution" -v -e="$(date)"

# Step 3: Provide a second contribution
echo_status "Step 3: Adding second contribution..."
snarkjs powersoftau contribute $SETUP_DIR/pot12_0001.ptau $SETUP_DIR/pot12_0002.ptau --name="Second contribution" -v -e="$(date)+1"

# Step 4: Provide a third contribution using third party software
echo_status "Step 4: Adding third contribution..."
snarkjs powersoftau contribute $SETUP_DIR/pot12_0002.ptau $SETUP_DIR/pot12_0003.ptau --name="Third contribution" -v -e="$(date)+2"

# Step 5: Apply a random beacon
echo_status "Step 5: Applying random beacon..."
snarkjs powersoftau beacon $SETUP_DIR/pot12_0003.ptau $SETUP_DIR/pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

# Step 6: Prepare phase 2
echo_status "Step 6: Preparing phase 2..."
snarkjs powersoftau prepare phase2 $SETUP_DIR/pot12_beacon.ptau $SETUP_DIR/pot12_final.ptau -v

# Step 7: Verify the final ptau
echo_status "Step 7: Verifying final ptau..."
snarkjs powersoftau verify $SETUP_DIR/pot12_final.ptau

# Step 8: Generate the reference zkey
echo_status "Step 8: Generating reference zkey..."
snarkjs groth16 setup $BUILD_DIR/${CIRCUIT_NAME}.r1cs $SETUP_DIR/pot12_final.ptau $SETUP_DIR/${CIRCUIT_NAME}_0000.zkey

# Step 9: Contribute to the phase 2 ceremony
echo_status "Step 9: Contributing to phase 2 ceremony..."
snarkjs zkey contribute $SETUP_DIR/${CIRCUIT_NAME}_0000.zkey $SETUP_DIR/${CIRCUIT_NAME}_0001.zkey --name="1st Contributor Name" -v -e="$(date)"

# Step 10: Provide a second contribution
echo_status "Step 10: Adding second phase 2 contribution..."
snarkjs zkey contribute $SETUP_DIR/${CIRCUIT_NAME}_0001.zkey $SETUP_DIR/${CIRCUIT_NAME}_0002.zkey --name="Second contribution Name" -v -e="$(date)+1"

# Step 11: Provide a third contribution using third party software
echo_status "Step 11: Adding third phase 2 contribution..."
snarkjs zkey contribute $SETUP_DIR/${CIRCUIT_NAME}_0002.zkey $SETUP_DIR/${CIRCUIT_NAME}_0003.zkey --name="Third contribution Name" -v -e="$(date)+2"

# Step 12: Apply a random beacon
echo_status "Step 12: Applying random beacon to phase 2..."
snarkjs zkey beacon $SETUP_DIR/${CIRCUIT_NAME}_0003.zkey $SETUP_DIR/${CIRCUIT_NAME}_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"

# Step 13: Verify the final zkey
echo_status "Step 13: Verifying final zkey..."
snarkjs zkey verify $BUILD_DIR/${CIRCUIT_NAME}.r1cs $SETUP_DIR/pot12_final.ptau $SETUP_DIR/${CIRCUIT_NAME}_final.zkey

# Step 14: Export the verification key
echo_status "Step 14: Exporting verification key..."
snarkjs zkey export verificationkey $SETUP_DIR/${CIRCUIT_NAME}_final.zkey $SETUP_DIR/verification_key.json

# Step 15: Export Solidity verifier
echo_status "Step 15: Generating Solidity verifier..."
snarkjs zkey export solidityverifier $SETUP_DIR/${CIRCUIT_NAME}_final.zkey $SETUP_DIR/verifier.sol

echo_status "Trusted setup completed successfully!"
echo ""
echo "Generated files:"
echo "  - $SETUP_DIR/${CIRCUIT_NAME}_final.zkey"
echo "  - $SETUP_DIR/verification_key.json"
echo "  - $SETUP_DIR/verifier.sol"
echo "  - $SETUP_DIR/pot12_final.ptau"
echo ""
echo_warning "Note: In production, the trusted setup should be performed by multiple independent parties!"
echo_warning "The current setup is suitable for testing purposes only."