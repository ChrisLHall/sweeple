/// @description 
draw_set_font(fInfoText);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);

// Show "Guess N/6. Select M more bombs"
// If someone shows info text, put that under "Guess N/6" (?)
// If someone shows permanent text, just show that.
// If it is the daily challenge, ALWAYS show that on top.

var pokes = oManager.checkNumberOfPokes();
var guessText = "";
if (!oManager.gameFinished) {
	guessText = "Guess " + string(oManager.turns + 1) + "/6\n";
}

var mineText = "";
if (pokes == 0) {
	mineText = "Find " + string(oManager.MINES) + " bombs.";
} else if (pokes < oManager.MINES) {
	var remaining = oManager.MINES - pokes;
	var squares = (remaining == 1) ? "square." : "squares.";
	mineText = "Select " + string(oManager.MINES - pokes) + " more " + squares;
} else if (pokes == oManager.MINES) {
	mineText = "Press go!";
} else {
	mineText = "Select fewer squares."
}
var textAfterGuess = mineText;
if (infoText != "") {
	textAfterGuess = infoText;
}
var finalText = guessText + textAfterGuess;
if (permanentText != "") {
	finalText = permanentText;
}
if (global.isDailyChallenge) {
	finalText = "Daily " + scrTodayString() + "\n" + finalText;
}
draw_text_ext(x, y, finalText, -1, 232);