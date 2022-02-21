/// @description 
if (!CONFIRMED and !LOCKED) {
	// clicking a bomb makes it go to poke
	// otherwise, switch between blank and poke and X
	if (state == GridState.Blank) {
		state = GridState.Poke;
	} else if (state == GridState.Poke) {
		state = GridState.X;
	} else if (state == GridState.Bomb) {
		state = GridState.Poke;
	} else {
		state = GridState.Blank;
	}
}
