// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scrStringToGuesses(guessString) {
	var result = [];
	var currentRow = [];
	var currentNumber = 0;
	var rowStrings = scrStringSplit(guessString, ";");
	for (var rowIndex = 0; rowIndex < array_length(rowStrings); rowIndex++) {
		currentRow = [];
		var rowNumberStrings = scrStringSplit(rowStrings[rowIndex], ",");
		for (var colIndex = 0; colIndex < array_length(rowNumberStrings); colIndex++) {
			array_push(currentRow, real(rowNumberStrings[colIndex]));
		}
		array_push(result, currentRow);
	}
	return result;
}