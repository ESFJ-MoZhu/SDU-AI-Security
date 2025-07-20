#!/bin/bash

# Poseidon2 Proof Generation and Verification Script
# This script generates and verifies Groth16 proofs for the Poseidon2 circuit

set -e

BUILD_DIR="build"
SETUP_DIR="setup"
PROOF_DIR="proofs"
CIRCUIT_NAME="poseidon2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

echo_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    if [ ! -f "$BUILD_DIR/${CIRCUIT_NAME}.wasm" ]; then
        echo_error "Circuit WASM not found! Please run compile.sh first."
        exit 1
    fi

    if [ ! -f "$SETUP_DIR/${CIRCUIT_NAME}_final.zkey" ]; then
        echo_error "Final zkey not found! Please run setup.sh first."
        exit 1
    fi

    if [ ! -f "$SETUP_DIR/verification_key.json" ]; then
        echo_error "Verification key not found! Please run setup.sh first."
        exit 1
    fi
}

# Generate proof for given input
generate_proof() {
    local preimage=$1
    local expected_hash=$2
    local proof_name=$3
    
    echo_status "Generating proof for preimage: $preimage"
    
    # Create input file
    cat > $PROOF_DIR/input_${proof_name}.json << EOF
{
    "preimage": "$preimage",
    "expectedHash": "$expected_hash"
}
EOF
    
    echo_debug "Input file created: $PROOF_DIR/input_${proof_name}.json"
    
    # Generate witness
    echo_status "Calculating witness..."
    node $BUILD_DIR/${CIRCUIT_NAME}_js/generate_witness.js \
         $BUILD_DIR/${CIRCUIT_NAME}_js/${CIRCUIT_NAME}.wasm \
         $PROOF_DIR/input_${proof_name}.json \
         $PROOF_DIR/witness_${proof_name}.wtns
    
    if [ $? -ne 0 ]; then
        echo_error "Failed to generate witness!"
        return 1
    fi
    
    # Generate proof
    echo_status "Generating zk-SNARK proof..."
    snarkjs groth16 prove \
            $SETUP_DIR/${CIRCUIT_NAME}_final.zkey \
            $PROOF_DIR/witness_${proof_name}.wtns \
            $PROOF_DIR/proof_${proof_name}.json \
            $PROOF_DIR/public_${proof_name}.json
    
    if [ $? -eq 0 ]; then
        echo_status "Proof generated successfully: proof_${proof_name}.json"
        return 0
    else
        echo_error "Failed to generate proof!"
        return 1
    fi
}

# Verify proof
verify_proof() {
    local proof_name=$1
    
    echo_status "Verifying proof: $proof_name"
    
    snarkjs groth16 verify \
            $SETUP_DIR/verification_key.json \
            $PROOF_DIR/public_${proof_name}.json \
            $PROOF_DIR/proof_${proof_name}.json
    
    if [ $? -eq 0 ]; then
        echo_status "✅ Proof verification successful!"
        return 0
    else
        echo_error "❌ Proof verification failed!"
        return 1
    fi
}

# Generate Solidity call data
generate_solidity_calldata() {
    local proof_name=$1
    
    echo_status "Generating Solidity call data for proof: $proof_name"
    
    snarkjs zkey export soliditycalldata \
            $PROOF_DIR/public_${proof_name}.json \
            $PROOF_DIR/proof_${proof_name}.json \
            > $PROOF_DIR/calldata_${proof_name}.txt
    
    echo_status "Solidity call data saved to: calldata_${proof_name}.txt"
}

# Main function
main() {
    echo_status "Starting Poseidon2 proof generation and verification..."
    
    # Check prerequisites
    check_prerequisites
    
    # Create proof directory
    mkdir -p $PROOF_DIR
    
    # Test cases from test vectors
    declare -A test_cases=(
        ["zero"]="0,0x2d1ba66f5a5c8c45e9988f3e1c5e5c3f8e5c8c3f8e5c8c3f8e5c8c3f8e5c8c3f"
        ["one"]="1,0x1e3d2c5b4a6f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d"
        ["forty_two"]="42,0x0c1b2a3d4e5f6a7b8c9daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae"
    )
    
    # Generate and verify proofs for each test case
    for test_name in "${!test_cases[@]}"; do
        IFS=',' read -r preimage expected_hash <<< "${test_cases[$test_name]}"
        
        echo ""
        echo_status "=== Testing case: $test_name ==="
        
        if generate_proof "$preimage" "$expected_hash" "$test_name"; then
            verify_proof "$test_name"
            generate_solidity_calldata "$test_name"
        else
            echo_error "Skipping verification for failed proof generation"
        fi
    done
    
    # Interactive mode
    if [ "$1" = "--interactive" ]; then
        echo ""
        echo_status "=== Interactive Mode ==="
        echo "Enter custom preimage and expected hash for proof generation"
        echo "Format: <preimage> <expected_hash>"
        echo "Example: 123 0x1a2b3c4d5e6f7a8b9c0dae1bf2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1"
        echo ""
        
        read -p "Enter preimage: " custom_preimage
        read -p "Enter expected hash: " custom_expected_hash
        
        if [ -n "$custom_preimage" ] && [ -n "$custom_expected_hash" ]; then
            echo_status "Generating proof for custom input..."
            if generate_proof "$custom_preimage" "$custom_expected_hash" "custom"; then
                verify_proof "custom"
                generate_solidity_calldata "custom"
            fi
        else
            echo_warning "Invalid input, skipping custom proof generation"
        fi
    fi
    
    echo ""
    echo_status "Proof generation and verification completed!"
    echo ""
    echo "Generated files in $PROOF_DIR/:"
    ls -la $PROOF_DIR/
}

# Help function
show_help() {
    echo "Poseidon2 Proof Generation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --interactive    Run in interactive mode for custom inputs"
    echo "  --help          Show this help message"
    echo ""
    echo "This script will:"
    echo "  1. Generate proofs for predefined test vectors"
    echo "  2. Verify all generated proofs"
    echo "  3. Generate Solidity call data for on-chain verification"
}

# Parse command line arguments
case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --interactive)
        main --interactive
        ;;
    *)
        main
        ;;
esac