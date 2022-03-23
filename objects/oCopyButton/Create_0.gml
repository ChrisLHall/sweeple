/// @description Don't be clickable for like .2 seconds

clickable = false;
alarm_set(0, 15);


function createGameString() {
	var copyString = "#Sweeple https://chrislhall.itch.io/sweeple\n";
	if (global.isDailyChallenge) {
		copyString += "Daily Challenge " + scrTodayString() + "\n";
	}
	copyString += string(oManager.COLS) + "x" + string(oManager.ROWS) + " - " + string(oManager.MINES) + " bombs\n";
	copyString += (oHardModeCheckBox.HARDMODE) ? "*" : "";
	if (oManager.won) {
		copyString += string(oManager.turns) + "/6 guesses\n\n";
	} else {
		copyString += "X/6 guesses\n\n";
	}
	for (var i = 0; i < array_length(oManager.guessHistory); i++) {
		var guessRow = oManager.guessHistory[i];
		copyString += guessRowToEmojis(guessRow) + "\n";
	}
	return copyString;
}


function guessRowToEmojis(guessRow) {
	var result = "";
	for (var i = 0; i < array_length(guessRow); i++) {
		var distance = guessRow[i];
		if (distance == 0) {
			result += "🟩";
		} else if (distance <= 2) {
			result += "🟨";
		} else {
			result += "🟧";
		}
	}
	return result;
}
