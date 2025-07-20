pragma circom 2.0.0;

include "./poseidon2_utils.circom";

// Main Poseidon2 hash circuit
// Public input: expected hash output
// Private input: preimage to be hashed
template Poseidon2Hash() {
    // Public input: the expected hash value
    signal input expectedHash;
    
    // Private input: the preimage (one field element)
    signal private input preimage;
    
    // Output: computed hash (should equal expectedHash)
    signal output hash;
    
    // Initialize state with zeros (capacity elements)
    signal initialState[3];
    initialState[0] <== 0;  // This will be overwritten during absorption
    initialState[1] <== 0;  // Capacity
    initialState[2] <== 0;  // Capacity
    
    // Absorption phase: absorb preimage into state
    component absorb = Absorb();
    absorb.state <== initialState;
    absorb.input_block <== preimage;
    
    // Apply Poseidon2 permutation
    component permutation = Poseidon2Permutation();
    permutation.state <== absorb.newState;
    
    // Squeezing phase: extract hash output
    component squeeze = Squeeze();
    squeeze.state <== permutation.newState;
    
    // Set output
    hash <== squeeze.hash_output;
    
    // Constraint: computed hash must equal expected hash
    expectedHash === hash;
}

// Alternative template for batch hashing multiple inputs
template Poseidon2HashBatch(n) {
    signal input inputs[n];
    signal output hash;
    
    // For multiple inputs, we need to absorb them sequentially
    signal state[n + 1][3];
    
    // Initialize state
    state[0][0] <== 0;
    state[0][1] <== 0;
    state[0][2] <== 0;
    
    component absorb[n];
    component permutation[n];
    
    for (var i = 0; i < n; i++) {
        // Absorb input
        absorb[i] = Absorb();
        absorb[i].state <== state[i];
        absorb[i].input_block <== inputs[i];
        
        // Apply permutation
        permutation[i] = Poseidon2Permutation();
        permutation[i].state <== absorb[i].newState;
        
        // Update state
        state[i + 1] <== permutation[i].newState;
    }
    
    // Final squeeze
    component squeeze = Squeeze();
    squeeze.state <== state[n];
    hash <== squeeze.hash_output;
}

// Poseidon2 with domain separation for different use cases
template Poseidon2WithDomain(domain) {
    signal input preimage;
    signal output hash;
    
    // Initialize state with domain separator
    signal initialState[3];
    initialState[0] <== domain;  // Domain separator in first element
    initialState[1] <== 0;       // Capacity
    initialState[2] <== 0;       // Capacity
    
    // Absorb preimage
    component absorb = Absorb();
    absorb.state <== initialState;
    absorb.input_block <== preimage;
    
    // Apply permutation
    component permutation = Poseidon2Permutation();
    permutation.state <== absorb.newState;
    
    // Squeeze output
    component squeeze = Squeeze();
    squeeze.state <== permutation.newState;
    hash <== squeeze.hash_output;
}

// Zero-knowledge proof circuit: prove knowledge of preimage
template Poseidon2ZKProof() {
    // Public input: hash value
    signal input hashValue;
    
    // Private input: preimage
    signal private input preimage;
    
    // Compute hash of preimage
    component hasher = Poseidon2Hash();
    hasher.expectedHash <== hashValue;
    hasher.preimage <== preimage;
    
    // The constraint is enforced inside Poseidon2Hash
    // This circuit proves knowledge of preimage without revealing it
}

// Template for testing with known test vectors
template Poseidon2Test() {
    signal input preimage;
    signal input expectedHash;
    signal output isValid;
    
    component hasher = Poseidon2Hash();
    hasher.preimage <== preimage;
    hasher.expectedHash <== expectedHash;
    
    // Output 1 if hash matches, 0 otherwise
    // In practice, this would fail constraint checking if hashes don't match
    isValid <== 1;
}

// Component for incremental hashing (useful for Merkle trees)
template Poseidon2Incremental() {
    signal input left;
    signal input right;
    signal output hash;
    
    component hasher = Poseidon2HashBatch(2);
    hasher.inputs[0] <== left;
    hasher.inputs[1] <== right;
    hash <== hasher.hash;
}

// Main component instantiation for compilation
component main = Poseidon2Hash();