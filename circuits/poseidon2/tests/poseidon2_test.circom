pragma circom 2.0.0;

include "../poseidon2.circom";
include "../poseidon2_utils.circom";

// Test circuit for basic Poseidon2 functionality
template Poseidon2BasicTest() {
    // Test with known values
    signal input preimage;
    signal input expectedHash;
    signal output success;
    
    component hasher = Poseidon2Hash();
    hasher.preimage <== preimage;
    hasher.expectedHash <== expectedHash;
    
    // If we reach here, the hash matched
    success <== 1;
}

// Test circuit for S-box functionality
template SBoxTest() {
    signal input x;
    signal output y;
    
    component sbox = SBoxOptimized();
    sbox.in <== x;
    y <== sbox.out;
    
    // Verify that y = x^5
    signal x2 <== x * x;
    signal x4 <== x2 * x2;
    signal x5 <== x4 * x;
    
    // Constraint check
    y === x5;
}

// Test circuit for MDS matrix multiplication
template MDSTest() {
    signal input state[3];
    signal output newState[3];
    
    component mds = MDSMultiplication();
    mds.state <== state;
    newState <== mds.newState;
    
    // Manual verification of MDS matrix multiplication
    // MDS = [[2,1,1], [1,2,1], [1,1,3]]
    signal expected[3];
    expected[0] <== 2 * state[0] + state[1] + state[2];
    expected[1] <== state[0] + 2 * state[1] + state[2];
    expected[2] <== state[0] + state[1] + 3 * state[2];
    
    // Verify results
    for (var i = 0; i < 3; i++) {
        newState[i] === expected[i];
    }
}

// Test circuit for round function
template RoundTest() {
    signal input state[3];
    signal input round;
    signal output newState[3];
    
    // Test external round (assuming round < 4 or round >= 60)
    component extRound = ExternalRound(0);
    extRound.state <== state;
    newState <== extRound.newState;
}

// Test circuit for full permutation
template PermutationTest() {
    signal input state[3];
    signal output newState[3];
    
    component perm = Poseidon2Permutation();
    perm.state <== state;
    newState <== perm.newState;
}

// Test circuit for absorption and squeezing
template AbsorbSqueezeTest() {
    signal input initialState[3];
    signal input inputBlock;
    signal output hashOutput;
    
    // Absorb
    component absorb = Absorb();
    absorb.state <== initialState;
    absorb.input_block <== inputBlock;
    
    // Apply permutation
    component perm = Poseidon2Permutation();
    perm.state <== absorb.newState;
    
    // Squeeze
    component squeeze = Squeeze();
    squeeze.state <== perm.newState;
    hashOutput <== squeeze.hash_output;
}

// Test circuit for batch hashing
template BatchHashTest() {
    signal input inputs[2];
    signal output hash;
    
    component batchHasher = Poseidon2HashBatch(2);
    batchHasher.inputs <== inputs;
    hash <== batchHasher.hash;
}

// Test circuit for domain separation
template DomainSeparationTest() {
    signal input preimage;
    signal input domain;
    signal output hash;
    
    component domainHasher = Poseidon2WithDomain(1);
    domainHasher.preimage <== preimage;
    hash <== domainHasher.hash;
}

// Test circuit for incremental hashing (Merkle tree use case)
template IncrementalHashTest() {
    signal input left;
    signal input right;
    signal output hash;
    
    component incrementalHasher = Poseidon2Incremental();
    incrementalHasher.left <== left;
    incrementalHasher.right <== right;
    hash <== incrementalHasher.hash;
}

// Test circuit for zero-knowledge proof
template ZKProofTest() {
    signal input hashValue;
    signal private input preimage;
    
    component zkProof = Poseidon2ZKProof();
    zkProof.hashValue <== hashValue;
    zkProof.preimage <== preimage;
}

// Comprehensive test circuit combining multiple tests
template ComprehensiveTest() {
    // Test basic hashing
    signal input testPreimage;
    signal input testExpectedHash;
    signal output basicTestPassed;
    
    // Test S-box
    signal input sboxInput;
    signal output sboxOutput;
    
    // Test MDS
    signal input mdsState[3];
    signal output mdsOutput[3];
    
    // Test batch hashing
    signal input batchInputs[2];
    signal output batchOutput;
    
    // Basic hash test
    component basicTest = Poseidon2BasicTest();
    basicTest.preimage <== testPreimage;
    basicTest.expectedHash <== testExpectedHash;
    basicTestPassed <== basicTest.success;
    
    // S-box test
    component sboxTest = SBoxTest();
    sboxTest.x <== sboxInput;
    sboxOutput <== sboxTest.y;
    
    // MDS test
    component mdsTest = MDSTest();
    mdsTest.state <== mdsState;
    mdsOutput <== mdsTest.newState;
    
    // Batch test
    component batchTest = BatchHashTest();
    batchTest.inputs <== batchInputs;
    batchOutput <== batchTest.hash;
}

// Simple test for compilation and constraint checking
component main = Poseidon2BasicTest();