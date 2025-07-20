#!/bin/bash

# Poseidon2 Proof Generation and Verification Script
# This script generates and verifies Groth16 proofs for the Poseidon2 circuit

set -e

BUILD_DIR="build"
SETUP_DIR="setup"
PROOF_DIR="proofs"
CIRCUIT_NAME="poseidon2_minimal"

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
    if [ ! -f "$BUILD_DIR/${CIRCUIT_NAME}_js/${CIRCUIT_NAME}.wasm" ]; then
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
    
    # Test cases from computed test vectors
    declare -A test_cases=(
        ["zero"]="0,19676093267877135006483277928402821719540487397293977489684345512695759256995"
        ["one"]="1,10873177085824572700385408574928812589171572044812381592180157192267271867544"
        ["two"]="2,8675823116313732863748746391779796025462774936051849097543990142471444930359"
        ["forty_two"]="42,3542640441664455739866023919146616377964054109416071263842038564605950605979"
        ["hundred"]="100,14547262618919899152955641774116421510653434746987707337480614161520257133151"
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
        echo "Enter custom preimage for proof generation"
        echo "The circuit will compute the hash automatically"
        echo ""
        
        read -p "Enter preimage: " custom_preimage
        
        if [ -n "$custom_preimage" ]; then
            echo_status "Computing hash for preimage: $custom_preimage"
            
            # Use calculator circuit to get the hash
            echo '{"preimage": '$custom_preimage'}' > $PROOF_DIR/calc_input.json
            
            if [ -f "$BUILD_DIR/poseidon2_calculator_js/poseidon2_calculator.wasm" ]; then
                node $BUILD_DIR/poseidon2_calculator_js/generate_witness.js \
                     $BUILD_DIR/poseidon2_calculator_js/poseidon2_calculator.wasm \
                     $PROOF_DIR/calc_input.json \
                     $PROOF_DIR/calc_witness.wtns
                
                # Extract hash from witness (it's at index 1)
                echo_status "Hash computed successfully"
                echo_status "Generating proof for custom input..."
                
                # Note: In a real implementation, you'd extract the hash from the witness
                # For now, we'll use a placeholder
                echo_warning "Please run the calculator circuit separately to get the expected hash"
            else
                echo_warning "Calculator circuit not found. Please compile it first."
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
    echo ""
    echo "Test vectors used:"
    echo "  preimage=0   -> hash=19676093267877135006483277928402821719540487397293977489684345512695759256995"
    echo "  preimage=1   -> hash=10873177085824572700385408574928812589171572044812381592180157192267271867544"
    echo "  preimage=2   -> hash=8675823116313732863748746391779796025462774936051849097543990142471444930359"
    echo "  preimage=42  -> hash=3542640441664455739866023919146616377964054109416071263842038564605950605979"
    echo "  preimage=100 -> hash=14547262618919899152955641774116421510653434746987707337480614161520257133151"
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