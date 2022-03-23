// convert a 2D array to a string of integers separated by commas and semicolons
function scrGuessesToString(guessArray) {
	var result = "";
	for (var rowIndex = 0; rowIndex < array_length(guessArray); rowIndex++) {
		var row = guessArray[rowIndex];
		for (var colIndex = 0; colIndex < array_length(row); colIndex++) {
			result += string(row[colIndex]);
			if (colIndex != array_length(row) - 1) {
				result += ",";
			}
		}
		
		if (rowIndex != array_length(guessArray) - 1) {
			result += ";"	
		}
	}
	return result;
}