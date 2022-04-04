/// @description 
if (clickable) {
	//get_string("Copy this text", createGameString());
	eSweepleWeb_copyText(createGameString());
	
	clickable = false;
	alarm_set(0, 15);
}
