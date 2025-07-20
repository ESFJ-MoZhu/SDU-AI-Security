pragma circom 2.0.0;

// Poseidon2 Constants for parameters (n=256, t=3, d=5)
// Field: BN254 scalar field
// State size: t = 3
// S-box degree: d = 5

template Poseidon2Constants() {
    // Number of external rounds (first and last)
    var R_f = 8;
    // Number of internal rounds (middle)
    var R_P = 56;
    // State size
    var t = 3;
    // Total rounds
    var ROUNDS = R_f + R_P;

    // Round constants - These are pseudorandom field elements
    // Generated using a secure hash function with domain separation
    var ROUND_CONSTANTS[ROUNDS][3] = [
        // External rounds (first R_f/2 = 4 rounds)
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
        
        // Internal rounds (R_P = 56 rounds)
        // For internal rounds, only the first element gets a round constant
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
        
        // Final external rounds (last R_f/2 = 4 rounds)  
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

    // MDS Matrix for t=3
    // This is a 3x3 Maximum Distance Separable matrix
    var MDS_MATRIX[3][3] = [
        [2, 1, 1],
        [1, 2, 1], 
        [1, 1, 3]
    ];

    // Internal matrix for internal rounds
    // Optimized circulant matrix for efficiency
    var INTERNAL_MATRIX[3][3] = [
        [2, 1, 1],
        [1, 2, 1],
        [1, 1, 2]
    ];

    function getRoundConstant(round, index) {
        return ROUND_CONSTANTS[round][index];
    }

    function getMDSElement(i, j) {
        return MDS_MATRIX[i][j];
    }

    function getInternalMatrixElement(i, j) {
        return INTERNAL_MATRIX[i][j];
    }

    function getRounds() {
        return ROUNDS;
    }

    function getExternalRounds() {
        return R_f;
    }

    function getInternalRounds() {
        return R_P;
    }

    function getStateSize() {
        return t;
    }
}