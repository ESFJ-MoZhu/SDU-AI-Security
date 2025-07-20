#!/bin/bash

# Test script for Poseidon2 proof generation and verification
# This script demonstrates the complete workflow

set -e

echo "=== Poseidon2 Hash ZK-Proof Demo ==="
echo ""

# Test vector from our calculator
PREIMAGE="1"
EXPECTED_HASH="10873177085824572700385408574928812589171572044812381592180157192267271867544"

echo "Testing with:"
echo "  Preimage: $PREIMAGE" 
echo "  Expected Hash: $EXPECTED_HASH"
echo ""

# Create input file
mkdir -p proofs
cat > proofs/demo_input.json << EOF
{
    "preimage": "$PREIMAGE",
    "expectedHash": "$EXPECTED_HASH"
}
EOF

echo "✓ Created input file"

# Generate witness
echo "Generating witness..."
node build/poseidon2_minimal_js/generate_witness.js \
     build/poseidon2_minimal_js/poseidon2_minimal.wasm \
     proofs/demo_input.json \
     proofs/demo_witness.wtns

if [ $? -eq 0 ]; then
    echo "✓ Witness generated successfully"
else
    echo "✗ Witness generation failed"
    exit 1
fi

# Generate proof
echo "Generating zk-SNARK proof..."
snarkjs groth16 prove \
        setup/poseidon2_final.zkey \
        proofs/demo_witness.wtns \
        proofs/demo_proof.json \
        proofs/demo_public.json

if [ $? -eq 0 ]; then
    echo "✓ Proof generated successfully"
else
    echo "✗ Proof generation failed"
    exit 1
fi

# Verify proof
echo "Verifying proof..."
snarkjs groth16 verify \
        setup/verification_key.json \
        proofs/demo_public.json \
        proofs/demo_proof.json

if [ $? -eq 0 ]; then
    echo "✓ Proof verification successful!"
    echo ""
    echo "=== Demonstration Complete ==="
    echo "Successfully proved knowledge of preimage that hashes to the expected value"
    echo "without revealing the preimage itself!"
else
    echo "✗ Proof verification failed"
    exit 1
fi

echo ""
echo "Generated files:"
echo "  - proofs/demo_proof.json (zk-SNARK proof)"
echo "  - proofs/demo_public.json (public inputs)"
echo "  - proofs/demo_witness.wtns (witness)"
echo ""
echo "This proves that the prover knows a value that hashes to:"
echo "$EXPECTED_HASH"
echo "without revealing that the value is: $PREIMAGE"