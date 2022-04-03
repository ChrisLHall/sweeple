// Got this from this page https://en.wikipedia.org/wiki/Linear_congruential_generator#Python_code
// The params are from the "cc65" with fewer bits
// should be good enough, honestly it doesn't have to be good at all...lol

seed = 0;

a = 65793;
c = 4282663;
modulus = 8388608;
MAX_OUTPUT = 32767;

function setSeed(newSeed) {
	seed = newSeed;	
}

function randomSeed() {
	randomize();
	seed = irandom(modulus - 1);
}

function getNext() {
	seed = (a * seed + c) % modulus;
	return truncateBits(seed);
}

// return bits 22-8 of NUMBER - 0 to 32767
function truncateBits(number) {
	// right shift 8, bitwise and 0x7FFF
	return (number >> 8) & 0x7FFF;
}

// Returns 0 to 1 exclusive
function randomFloat() {
	return getNext() / (MAX_OUTPUT + 1);
}

// Returns something in range MINVALUE, MAXVALUE excluding MAXVALUE itself
function randomIntRange(minValue, maxValue) {
	return floor(minValue + (maxValue - minValue) * randomFloat());
}

