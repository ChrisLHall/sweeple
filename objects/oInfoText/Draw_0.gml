/// @description 
draw_set_font(fInfoText);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);

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
var textToDraw = mineText;
if (infoText != "") {
	textToDraw = infoText;
}
draw_text_ext(x, y, guessText + textToDraw, -1, 232);