// Save data about today's daily from 
// "dailyDate" YYYY-MM-DD
// "dailyWon" bool
// "dailyGuessHistory" list of lists
function scrSaveGame(){
	if (!oManager.todayDailyFinished) {
		show_debug_message("Don't save if the daily is not finished");
		return;
	}
	var save = ds_map_create();
	ds_map_add(save, "dailyDate", scrTodayString());
	ds_map_add(save, "dailyWon", oManager.todayDailyWon);
	ds_map_add_list(save, "dailyGuessHistory", oManager.todayDailyGuessHistory);
    
	var saveString = json_encode(save);
	ds_map_destroy(save);
	show_debug_message("SAVING JSON STRING: " + saveString);
	
	var saveBuffer = buffer_create(string_byte_length(saveString) + 1, buffer_fixed, 1);
	buffer_write(saveBuffer, buffer_string, saveString);
	buffer_save(saveBuffer, "sweepleSave.json");
	buffer_delete(saveBuffer);
}