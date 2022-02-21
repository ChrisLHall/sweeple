/// @description 
show_debug_message(string(oManager.hasGameStarted()) + " " + string(oManager.turns));
if (!oManager.hasGameStarted()) {
	HARDMODE = !HARDMODE;
	image_index = HARDMODE ? 1 : 0;
}