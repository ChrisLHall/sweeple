// Load game
// if it is not today's daily, then don't worry about it
function scrLoadGame() {
	if (!file_exists("sweepleSave.json")) {
		show_debug_message("No save; as you were");
		return;
	}
	
	var loadBuffer = buffer_load("sweepleSave.json");
	var saveString = buffer_read(loadBuffer, buffer_string);
	buffer_delete(loadBuffer);
	show_debug_message("LOADED JSON STRING: " + saveString);
	
	var json = json_decode(saveString);
	
	var todayDate = scrTodayString();
	var saveDate = json[? "dailyDate"];
	if (todayDate == saveDate) {
		oManager.todayDailyFinished = true;
		oManager.todayDailyWon = json[? "dailyWon"];
		oManager.todayDailyGuessHistory = json[? "dailyGuessHistory"];
	} else {
		show_debug_message("No save for today.");
	}
	
	ds_map_destroy(json);
}