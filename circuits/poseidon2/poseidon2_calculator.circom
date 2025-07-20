pragma circom 2.1.0;

template SBox() {
    signal input in;
    signal output out;
    
    signal sq;
    signal quad;
    
    sq <== in * in;
    quad <== sq * sq;
    out <== quad * in;
}

template MDSMultiplication() {
    signal input state[3];
    signal output newState[3];
    
    newState[0] <== 2 * state[0] + state[1] + state[2];
    newState[1] <== state[0] + 2 * state[1] + state[2];
    newState[2] <== state[0] + state[1] + 3 * state[2];
}

template ExternalRound(round) {
    signal input state[3];
    signal output newState[3];
    
    var constants[3] = [1 + round, 2 + round, 3 + round];
    
    signal afterConstants[3];
    afterConstants[0] <== state[0] + constants[0];
    afterConstants[1] <== state[1] + constants[1];
    afterConstants[2] <== state[2] + constants[2];
    
    component sbox[3];
    signal afterSBox[3];
    for (var i = 0; i < 3; i++) {
        sbox[i] = SBox();
        sbox[i].in <== afterConstants[i];
        afterSBox[i] <== sbox[i].out;
    }
    
    component mds = MDSMultiplication();
    mds.state[0] <== afterSBox[0];
    mds.state[1] <== afterSBox[1];
    mds.state[2] <== afterSBox[2];
    newState[0] <== mds.newState[0];
    newState[1] <== mds.newState[1];
    newState[2] <== mds.newState[2];
}

template InternalRound(round) {
    signal input state[3];
    signal output newState[3];
    
    var constant = 100 + round;
    
    signal afterConstants[3];
    afterConstants[0] <== state[0] + constant;
    afterConstants[1] <== state[1];
    afterConstants[2] <== state[2];
    
    component sbox = SBox();
    sbox.in <== afterConstants[0];
    
    signal afterSBox[3];
    afterSBox[0] <== sbox.out;
    afterSBox[1] <== afterConstants[1];
    afterSBox[2] <== afterConstants[2];
    
    component mds = MDSMultiplication();
    mds.state[0] <== afterSBox[0];
    mds.state[1] <== afterSBox[1];
    mds.state[2] <== afterSBox[2];
    newState[0] <== mds.newState[0];
    newState[1] <== mds.newState[1];
    newState[2] <== mds.newState[2];
}

template Poseidon2Permutation() {
    signal input state[3];
    signal output newState[3];
    
    signal stateAfterRound[9][3];
    stateAfterRound[0][0] <== state[0];
    stateAfterRound[0][1] <== state[1];
    stateAfterRound[0][2] <== state[2];
    
    component externalRounds1[2];
    for (var i = 0; i < 2; i++) {
        externalRounds1[i] = ExternalRound(i);
        externalRounds1[i].state[0] <== stateAfterRound[i][0];
        externalRounds1[i].state[1] <== stateAfterRound[i][1];
        externalRounds1[i].state[2] <== stateAfterRound[i][2];
        stateAfterRound[i + 1][0] <== externalRounds1[i].newState[0];
        stateAfterRound[i + 1][1] <== externalRounds1[i].newState[1];
        stateAfterRound[i + 1][2] <== externalRounds1[i].newState[2];
    }
    
    component internalRounds[4];
    for (var i = 0; i < 4; i++) {
        internalRounds[i] = InternalRound(2 + i);
        internalRounds[i].state[0] <== stateAfterRound[2 + i][0];
        internalRounds[i].state[1] <== stateAfterRound[2 + i][1];
        internalRounds[i].state[2] <== stateAfterRound[2 + i][2];
        stateAfterRound[2 + i + 1][0] <== internalRounds[i].newState[0];
        stateAfterRound[2 + i + 1][1] <== internalRounds[i].newState[1];
        stateAfterRound[2 + i + 1][2] <== internalRounds[i].newState[2];
    }
    
    component externalRounds2[2];
    for (var i = 0; i < 2; i++) {
        externalRounds2[i] = ExternalRound(6 + i);
        externalRounds2[i].state[0] <== stateAfterRound[6 + i][0];
        externalRounds2[i].state[1] <== stateAfterRound[6 + i][1];
        externalRounds2[i].state[2] <== stateAfterRound[6 + i][2];
        stateAfterRound[6 + i + 1][0] <== externalRounds2[i].newState[0];
        stateAfterRound[6 + i + 1][1] <== externalRounds2[i].newState[1];
        stateAfterRound[6 + i + 1][2] <== externalRounds2[i].newState[2];
    }
    
    newState[0] <== stateAfterRound[8][0];
    newState[1] <== stateAfterRound[8][1];
    newState[2] <== stateAfterRound[8][2];
}

template Absorb() {
    signal input state[3];
    signal input input_block;
    signal output newState[3];
    
    newState[0] <== state[0] + input_block;
    newState[1] <== state[1];
    newState[2] <== state[2];
}

template Squeeze() {
    signal input state[3];
    signal output hash_output;
    
    hash_output <== state[0];
}

// Hash calculator without constraint check
template Poseidon2HashCalculator() {
    signal input preimage;
    signal output hash;
    
    signal initialState[3];
    initialState[0] <== 0;
    initialState[1] <== 0;
    initialState[2] <== 0;
    
    component absorb = Absorb();
    absorb.state[0] <== initialState[0];
    absorb.state[1] <== initialState[1];
    absorb.state[2] <== initialState[2];
    absorb.input_block <== preimage;
    
    component permutation = Poseidon2Permutation();
    permutation.state[0] <== absorb.newState[0];
    permutation.state[1] <== absorb.newState[1];
    permutation.state[2] <== absorb.newState[2];
    
    component squeeze = Squeeze();
    squeeze.state[0] <== permutation.newState[0];
    squeeze.state[1] <== permutation.newState[1];
    squeeze.state[2] <== permutation.newState[2];
    
    hash <== squeeze.hash_output;
}

component main = Poseidon2HashCalculator();