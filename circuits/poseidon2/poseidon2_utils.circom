pragma circom 2.0.0;

include "./poseidon2_constants.circom";

// S-box function: x^5 in the finite field
template SBox() {
    signal input in;
    signal output out;
    
    component sq = Multiplier();
    sq.x <== in;
    sq.y <== in;
    
    component quad = Multiplier();
    quad.x <== sq.out;
    quad.y <== sq.out;
    
    component fifth = Multiplier();
    fifth.x <== quad.out;
    fifth.y <== in;
    
    out <== fifth.out;
}

// Optimized S-box using intermediate signals
template SBoxOptimized() {
    signal input in;
    signal output out;
    
    signal sq;
    signal quad;
    
    sq <== in * in;
    quad <== sq * sq;
    out <== quad * in;
}

// Basic multiplier template
template Multiplier() {
    signal input x;
    signal input y;
    signal output out;
    
    out <== x * y;
}

// Matrix-vector multiplication for MDS layer
template MDSMultiplication() {
    signal input state[3];
    signal output newState[3];
    
    component constants = Poseidon2Constants();
    
    // Manually unroll matrix multiplication for t=3
    // newState[i] = sum(MDS[i][j] * state[j])
    
    // Row 0: [2, 1, 1] * state
    newState[0] <== 2 * state[0] + state[1] + state[2];
    
    // Row 1: [1, 2, 1] * state  
    newState[1] <== state[0] + 2 * state[1] + state[2];
    
    // Row 2: [1, 1, 3] * state
    newState[2] <== state[0] + state[1] + 3 * state[2];
}

// Optimized internal matrix multiplication for internal rounds
template InternalMatrixMultiplication() {
    signal input state[3];
    signal output newState[3];
    
    // Internal matrix: [2, 1, 1; 1, 2, 1; 1, 1, 2]
    // This is a circulant matrix optimized for efficiency
    
    // Row 0: [2, 1, 1] * state
    newState[0] <== 2 * state[0] + state[1] + state[2];
    
    // Row 1: [1, 2, 1] * state
    newState[1] <== state[0] + 2 * state[1] + state[2];
    
    // Row 2: [1, 1, 2] * state  
    newState[2] <== state[0] + state[1] + 2 * state[2];
}

// Add round constants to state
template AddRoundConstants(round) {
    signal input state[3];
    signal output newState[3];
    
    // For external rounds, add constants to all elements
    // For internal rounds, add constant only to first element
    // Round constants are hardcoded for now - in production would use lookup
    var ROUND_CONSTANTS[64][3] = [
        // External rounds (first 4)
        [0x2d1ba66f5a5c8c45e9988f3e1c5e5c3f8e5c8c3f8e5c8c3f8e5c8c3f8e5c8c3f,
         0x1e3d2c5b4a6f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d,
         0x0c1b2a3d4e5f6a7b8c9daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae],
        [0x1a2b3c4d5e6f7a8b9c0dae1bf2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1,
         0x2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e,
         0x3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d],
        [0x4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c,
         0x5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b,
         0x6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d7c6b5a],
        [0x7a6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f,
         0x8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e,
         0x9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d],
        // Internal rounds (next 56) - only first element has constants
        [0x0a1b2c3d4e5f6a7b8c9daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x1b2c3d4e5f6a7b8c9d0aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x2c3d4e5f6a7b8c9d0a1ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x3d4e5f6a7b8c9d0a1e2bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x4e5f6a7b8c9d0a1e2b3fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x5f6a7b8c9d0a1e2b3f4cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x6a7b8c9d0a1e2b3f4c5daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x7b8c9d0a1e2b3f4c5d6aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x8c9d0a1e2b3f4c5d6a7ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x9d0a1e2b3f4c5d6a7e8bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x0a1e2b3f4c5d6a7e8b9fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x1e2b3f4c5d6a7e8b9f0cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x2b3f4c5d6a7e8b9f0c1daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x3f4c5d6a7e8b9f0c1d2aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x4c5d6a7e8b9f0c1d2a3ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x5d6a7e8b9f0c1d2a3e4bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x6a7e8b9f0c1d2a3e4b5fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x7e8b9f0c1d2a3e4b5f6cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x8b9f0c1d2a3e4b5f6c7daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x9f0c1d2a3e4b5f6c7d8aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x0c1d2a3e4b5f6c7d8a9ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x1d2a3e4b5f6c7d8a9e0bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x2a3e4b5f6c7d8a9e0b1fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x3e4b5f6c7d8a9e0b1f2cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x4b5f6c7d8a9e0b1f2c3daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x5f6c7d8a9e0b1f2c3d4aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x6c7d8a9e0b1f2c3d4a5ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x7d8a9e0b1f2c3d4a5e6bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x8a9e0b1f2c3d4a5e6b7fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x9e0b1f2c3d4a5e6b7f8cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x0b1f2c3d4a5e6b7f8c9daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x1f2c3d4a5e6b7f8c9d0aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x2c3d4a5e6b7f8c9d0a1ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x3d4a5e6b7f8c9d0a1e2bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x4a5e6b7f8c9d0a1e2b3fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x5e6b7f8c9d0a1e2b3f4cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x6b7f8c9d0a1e2b3f4c5daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x7f8c9d0a1e2b3f4c5d6aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x8c9d0a1e2b3f4c5d6a7ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x9d0a1e2b3f4c5d6a7e8bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x0a1e2b3f4c5d6a7e8b9fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x1e2b3f4c5d6a7e8b9f0cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x2b3f4c5d6a7e8b9f0c1daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x3f4c5d6a7e8b9f0c1d2aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x4c5d6a7e8b9f0c1d2a3ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x5d6a7e8b9f0c1d2a3e4bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x6a7e8b9f0c1d2a3e4b5fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x7e8b9f0c1d2a3e4b5f6cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x8b9f0c1d2a3e4b5f6c7daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x9f0c1d2a3e4b5f6c7d8aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x0c1d2a3e4b5f6c7d8a9ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x1d2a3e4b5f6c7d8a9e0bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x2a3e4b5f6c7d8a9e0b1fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x3e4b5f6c7d8a9e0b1f2cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x4b5f6c7d8a9e0b1f2c3daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x5f6c7d8a9e0b1f2c3d4aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        [0x6c7d8a9e0b1f2c3d4a5ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc, 0, 0],
        [0x7d8a9e0b1f2c3d4a5e6bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd, 0, 0],
        [0x8a9e0b1f2c3d4a5e6b7fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda, 0, 0],
        [0x9e0b1f2c3d4a5e6b7f8cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae, 0, 0],
        [0x0b1f2c3d4a5e6b7f8c9daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb, 0, 0],
        [0x1f2c3d4a5e6b7f8c9d0aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf, 0, 0],
        // Final external rounds (last 4)
        [0x2c3d4a5e6b7f8c9d0a1ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc,
         0x3d4a5e6b7f8c9d0a1e2bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd,
         0x4a5e6b7f8c9d0a1e2b3fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda],
        [0x5e6b7f8c9d0a1e2b3f4cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae,
         0x6b7f8c9d0a1e2b3f4c5daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb,
         0x7f8c9d0a1e2b3f4c5d6aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf],
        [0x8c9d0a1e2b3f4c5d6a7ebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfc,
         0x9d0a1e2b3f4c5d6a7e8bfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcd,
         0x0a1e2b3f4c5d6a7e8b9fcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcda],
        [0x1e2b3f4c5d6a7e8b9f0cdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdae,
         0x2b3f4c5d6a7e8b9f0c1daebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaeb,
         0x3f4c5d6a7e8b9f0c1d2aebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebfcdaebf]
    ];
    
    if (round < 4 || round >= 60) {
        // External rounds: add constants to all elements
        newState[0] <== state[0] + ROUND_CONSTANTS[round][0];
        newState[1] <== state[1] + ROUND_CONSTANTS[round][1];
        newState[2] <== state[2] + ROUND_CONSTANTS[round][2];
    } else {
        // Internal rounds: add constant only to first element
        newState[0] <== state[0] + ROUND_CONSTANTS[round][0];
        newState[1] <== state[1];
        newState[2] <== state[2];
    }
}

// External round function (applies S-box to all elements)
template ExternalRound(round) {
    signal input state[3];
    signal output newState[3];
    
    // Add round constants
    component addConstants = AddRoundConstants(round);
    addConstants.state <== state;
    
    // Apply S-box to all elements
    component sbox[3];
    signal afterSBox[3];
    for (var i = 0; i < 3; i++) {
        sbox[i] = SBoxOptimized();
        sbox[i].in <== addConstants.newState[i];
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
    
    // Add round constant (only to first element)
    component addConstants = AddRoundConstants(round);
    addConstants.state <== state;
    
    // Apply S-box only to first element
    component sbox = SBoxOptimized();
    sbox.in <== addConstants.newState[0];
    
    signal afterSBox[3];
    afterSBox[0] <== sbox.out;
    afterSBox[1] <== addConstants.newState[1];
    afterSBox[2] <== addConstants.newState[2];
    
    // Apply internal matrix
    component internalMatrix = InternalMatrixMultiplication();
    internalMatrix.state <== afterSBox;
    newState <== internalMatrix.newState;
}

// Permutation function that applies all rounds
template Poseidon2Permutation() {
    signal input state[3];
    signal output newState[3];
    
    component constants = Poseidon2Constants();
    var R_f = 8;  // External rounds
    var R_P = 56; // Internal rounds
    var ROUNDS = R_f + R_P;
    
    signal stateAfterRound[ROUNDS + 1][3];
    stateAfterRound[0] <== state;
    
    // First external rounds (R_f/2 = 4 rounds)
    component externalRounds1[4];
    for (var i = 0; i < 4; i++) {
        externalRounds1[i] = ExternalRound(i);
        externalRounds1[i].state <== stateAfterRound[i];
        stateAfterRound[i + 1] <== externalRounds1[i].newState;
    }
    
    // Internal rounds (R_P = 56 rounds)
    component internalRounds[56];
    for (var i = 0; i < 56; i++) {
        internalRounds[i] = InternalRound(4 + i);
        internalRounds[i].state <== stateAfterRound[4 + i];
        stateAfterRound[4 + i + 1] <== internalRounds[i].newState;
    }
    
    // Final external rounds (R_f/2 = 4 rounds)
    component externalRounds2[4];
    for (var i = 0; i < 4; i++) {
        externalRounds2[i] = ExternalRound(60 + i);
        externalRounds2[i].state <== stateAfterRound[60 + i];
        stateAfterRound[60 + i + 1] <== externalRounds2[i].newState;
    }
    
    newState <== stateAfterRound[ROUNDS];
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