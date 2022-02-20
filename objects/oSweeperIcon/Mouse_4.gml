/// @description 
if (!CONFIRMED and !LOCKED) {
	// clicking a bomb makes it go to poke
	// otherwise, switch between blank and poke and X
	if (image_index == 0) {
		image_index = 2; // poke
	} else if (image_index == 2) {
		image_index = 4; // X
	} else if (image_index == 3) {
		image_index = 2;
	} else {
		image_index = 0;
	}
}
