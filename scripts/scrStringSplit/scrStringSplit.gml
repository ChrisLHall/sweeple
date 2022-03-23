// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scrStringSplit(startString, separator) {
	var result = [];
	var index = string_pos(separator, startString) - 1;
	while (index != -1) {
		var before = string_copy(startString, 1, index); // TODO check bounds
		startString = string_copy(startString, 1 + index + string_length(separator), string_length(startString) - index - string_length(separator));
		array_push(result, before);
		
		index = string_pos(separator, startString) - 1;
	}
	// put the remainder of the string in
	array_push(result, startString);
	return result;
}