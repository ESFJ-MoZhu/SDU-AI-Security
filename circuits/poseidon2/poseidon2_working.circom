include "circomlib/circuits/poseidon.circom";

template SBox() {
    signal input in;
    signal output out;
    
    signal sq;
    signal quad;
    
    sq <== in * in;
    quad <== sq * sq;
    out <== quad * in;
}

// Matrix-vector multiplication for MDS layer  
template MDSMultiplication() {
    signal input state[3];
    signal output newState[3];
    
    // MDS matrix: [[2,1,1], [1,2,1], [1,1,3]]
    newState[0] <== 2 * state[0] + state[1] + state[2];
    newState[1] <== state[0] + 2 * state[1] + state[2];
    newState[2] <== state[0] + state[1] + 3 * state[2];
}

// External round function (applies S-box to all elements)
template ExternalRound(round) {
    signal input state[3];
    signal output newState[3];
    
    // Simplified round constants
    var constants[3] = [1 + round, 2 + round, 3 + round];
    
    // Add round constants
    signal afterConstants[3];
    afterConstants[0] <== state[0] + constants[0];
    afterConstants[1] <== state[1] + constants[1];
    afterConstants[2] <== state[2] + constants[2];
    
    // Apply S-box to all elements
    component sbox[3];
    signal afterSBox[3];
    for (var i = 0; i < 3; i++) {
        sbox[i] = SBox();
        sbox[i].in <== afterConstants[i];
        afterSBox[i] <== sbox[i].out;
    }
    
    // Apply MDS matrix
    component mds = MDSMultiplication();
    mds.state <== afterSBox;
    newState <== mds.newState;
}

// Internal round function (applies S-box only to first element)
template InternalRound(round) {
    signal input state[3];
    signal output newState[3];
    
    // Simplified round constant (only for first element)
    var constant = 100 + round;
    
    // Add round constant only to first element
    signal afterConstants[3];
    afterConstants[0] <== state[0] + constant;
    afterConstants[1] <== state[1];
    afterConstants[2] <== state[2];
    
    // Apply S-box only to first element
    component sbox = SBox();
    sbox.in <== afterConstants[0];
    
    signal afterSBox[3];
    afterSBox[0] <== sbox.out;
    afterSBox[1] <== afterConstants[1];
    afterSBox[2] <== afterConstants[2];
    
    // Apply internal matrix
    component mds = MDSMultiplication();
    mds.state <== afterSBox;
    newState <== mds.newState;
}

// Simplified permutation function
template Poseidon2Permutation() {
    signal input state[3];
    signal output newState[3];
    
    var R_f = 8;  // External rounds
    var R_P = 8;  // Reduced internal rounds for testing
    
    signal stateAfterRound[17][3]; // R_f + R_P + 1
    stateAfterRound[0] <== state;
    
    // First external rounds (R_f/2 = 4 rounds)
    component externalRounds1[4];
    for (var i = 0; i < 4; i++) {
        externalRounds1[i] = ExternalRound(i);
        externalRounds1[i].state <== stateAfterRound[i];
        stateAfterRound[i + 1] <== externalRounds1[i].newState;
    }
    
    // Internal rounds (R_P = 8 rounds)
    component internalRounds[8];
    for (var i = 0; i < 8; i++) {
        internalRounds[i] = InternalRound(4 + i);
        internalRounds[i].state <== stateAfterRound[4 + i];
        stateAfterRound[4 + i + 1] <== internalRounds[i].newState;
    }
    
    // Final external rounds (R_f/2 = 4 rounds)
    component externalRounds2[4];
    for (var i = 0; i < 4; i++) {
        externalRounds2[i] = ExternalRound(12 + i);
        externalRounds2[i].state <== stateAfterRound[12 + i];
        stateAfterRound[12 + i + 1] <== externalRounds2[i].newState;
    }
    
    newState <== stateAfterRound[16];
}

// Absorption phase: absorb input into state
template Absorb() {
    signal input state[3];
    signal input input_block;
    signal output newState[3];
    
    // Add input to first element of state (rate = 1 for t=3)
    newState[0] <== state[0] + input_block;
    newState[1] <== state[1];
    newState[2] <== state[2];
}

// Squeezing phase: extract output from state
template Squeeze() {
    signal input state[3];
    signal output hash_output;
    
    // Output is first element of state
    hash_output <== state[0];
}

// Main Poseidon2 hash circuit
template Poseidon2Hash() {
    // Public input: the expected hash value
    signal input expectedHash;
    
    // Private input: the preimage (one field element)
    signal private input preimage;
    
    // Output: computed hash (should equal expectedHash)
    signal output hash;
    
    // Initialize state with zeros
    signal initialState[3];
    initialState[0] <== 0;
    initialState[1] <== 0;
    initialState[2] <== 0;
    
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

// Main component for compilation
component main = Poseidon2Hash();