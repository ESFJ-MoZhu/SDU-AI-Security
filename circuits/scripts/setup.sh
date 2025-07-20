#!/bin/bash

# Poseidon2 Trusted Setup Script
# This script performs the trusted setup for Groth16 proofs

set -e

BUILD_DIR="build"
SETUP_DIR="setup"
CIRCUIT_NAME="poseidon2_minimal"

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
POWER=12  # 2^12 = 4096 constraints (sufficient for our 42 constraint circuit)
snarkjs powersoftau new bn128 $POWER $SETUP_DIR/pot12_0000.ptau -v

# Step 2: Contribute to the ceremony
echo_status "Step 2: Contributing to powers of tau ceremony..."
snarkjs powersoftau contribute $SETUP_DIR/pot12_0000.ptau $SETUP_DIR/pot12_0001.ptau --name="First contribution" -v -e="$(date)"

# Step 3: Provide a second contribution
echo_status "Step 3: Adding second contribution..."
snarkjs powersoftau contribute $SETUP_DIR/pot12_0001.ptau $SETUP_DIR/pot12_final.ptau --name="Final contribution" -v -e="$(date)+final"

# Step 4: Prepare phase 2
echo_status "Step 4: Preparing phase 2..."
snarkjs powersoftau prepare phase2 $SETUP_DIR/pot12_final.ptau $SETUP_DIR/pot12_final_prepared.ptau -v

# Step 5: Verify the final ptau
echo_status "Step 5: Verifying final ptau..."
snarkjs powersoftau verify $SETUP_DIR/pot12_final_prepared.ptau

# Step 6: Generate the reference zkey
echo_status "Step 6: Generating reference zkey..."
snarkjs groth16 setup $BUILD_DIR/${CIRCUIT_NAME}.r1cs $SETUP_DIR/pot12_final_prepared.ptau $SETUP_DIR/${CIRCUIT_NAME}_final.zkey

# Step 7: Verify the final zkey
echo_status "Step 7: Verifying final zkey..."
snarkjs zkey verify $BUILD_DIR/${CIRCUIT_NAME}.r1cs $SETUP_DIR/pot12_final_prepared.ptau $SETUP_DIR/${CIRCUIT_NAME}_final.zkey

# Step 8: Export the verification key
echo_status "Step 8: Exporting verification key..."
snarkjs zkey export verificationkey $SETUP_DIR/${CIRCUIT_NAME}_final.zkey $SETUP_DIR/verification_key.json

# Step 9: Export Solidity verifier
echo_status "Step 9: Generating Solidity verifier..."
snarkjs zkey export solidityverifier $SETUP_DIR/${CIRCUIT_NAME}_final.zkey $SETUP_DIR/verifier.sol

echo_status "Trusted setup completed successfully!"
echo ""
echo "Generated files:"
echo "  - $SETUP_DIR/${CIRCUIT_NAME}_final.zkey"
echo "  - $SETUP_DIR/verification_key.json"
echo "  - $SETUP_DIR/verifier.sol"
echo "  - $SETUP_DIR/pot12_final_prepared.ptau"
echo ""
echo_warning "Note: This setup is for testing purposes only!"
echo_warning "For production, use a multi-party ceremony with multiple independent contributors."
echo ""
echo "Next step: Run prove.sh to generate and verify proofs"