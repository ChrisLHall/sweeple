/// @description 

infoText = "";

function showInfoText(text) {
	infoText = text;
	// clear after a bit
	alarm_set(0, 120);
}