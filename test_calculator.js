const chai = require("chai");
const path = require("path");
const assert = chai.assert;
const wasm_tester = require("circom_tester").wasm;

describe("Poseidon2 Hash Calculator Test", function () {
    let circuit;

    this.timeout(100000);

    before(async () => {
        circuit = await wasm_tester(path.join(__dirname, "circuits", "poseidon2", "poseidon2_calculator.circom"));
    });

    it("Should calculate hash for various preimages", async () => {
        const testInputs = [0, 1, 2, 42, 100];
        
        for (const preimage of testInputs) {
            const input = { preimage: preimage };
            
            const witness = await circuit.calculateWitness(input, true);
            console.log(`preimage = ${preimage}, hash = ${witness[1].toString()}`);
            
            // Verify constraints are satisfied
            await circuit.checkConstraints(witness);
        }
    });
});