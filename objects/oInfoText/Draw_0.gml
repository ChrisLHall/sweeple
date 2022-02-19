/// @description 
draw_set_font(fInfoText);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

var pokes = oManager.checkNumberOfPokes();
var mineText = "";
if (pokes == 0) {
	mineText = "Find " + string(oManager.MINES) + " mines.";
} else if (pokes < oManager.MINES) {
	mineText = "Select " + string(oManager.MINES - pokes) + " more squares.";
} else if (pokes == oManager.MINES) {
	mineText = "Press go!";
} else {
	mineText = "Select fewer squares."
}
draw_text_ext(x, y, mineText + "\n" + infoText, -1, 192);