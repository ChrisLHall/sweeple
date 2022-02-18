/// @description 
previousRows = [];
currentRow = [];
mineArray = [];
distanceField = [];


function newRowOfButtons() {
	var previousRow = noone;
	if (array_length(currentRow) > 0) {
		previousRow = currentRow;
		array_push(previousRows, currentRow);
		y += 64;
	}
	currentRow = makeSweeperRow(x, y, 64, SLOTS);
	if (previousRow != noone) {
		for (var i = 0; i < SLOTS; i++) {
			if (previousRow[i].image_index == 1) {
				currentRow[i].image_index = 1;
			} else if (previousRow[i].REVEALED) {
				currentRow[i].REVEALED = true;
				currentRow[i].TEXT = previousRow[i].TEXT;
				currentRow[i].CONFIRMED = true;
				currentRow[i].image_blend = previousRow[i].image_blend;
			}
		}
	}
}


// Place the mines in an array. 0 is blank, 1 is mine
function createMineArray(slots, mineCount) {
	var result = array_create(slots, 0);
	mineCount = min(mineCount, slots);
	while (mineCount > 0) {
		var randomSlot = irandom_range(0, slots - 1);
		if (result[randomSlot] == 0) {
			mineCount--;
			result[randomSlot] = 1;
			show_debug_message("Placed a mine");
		}
	}
	return result;
}

// create a distance field of an array of mines. Each cell contains a number which is the distance from the closest mine
function createDistanceField(mineArray) {
	var result = array_create(array_length(mineArray));
	for (var i = 0; i < array_length(result); i++) {
		var closestDistance = 1000;
		for (var j = 0; j < array_length(mineArray); j++) {
			if (mineArray[j] == 1) {
				var dist = abs(j - i);
				if (WRAP_DISTANCE) {
					var edge_dist = abs(i + SLOTS - j);
					var edge_dist_2 = abs(j + SLOTS - i);
					dist = min(dist, min(edge_dist, edge_dist_2));
				}
				if (dist < closestDistance) {
					closestDistance = dist;
				}
			}
		}
		result[i] = closestDistance;
	}
	return result;
}


function makeSweeperRow(startX, startY, spacing, count) {
	var result = array_create(count);
	for (var i = 0; i < count; i++) {
		result[i] = instance_create_layer(startX + i * spacing, startY, "Instances", oSweeperIcon);
	}
	return result;	
}

// recall that image_index 0 is blank, 1 is flag, 2 is poke
// score the whole thing if 
function scoreCurrentRow() {
	for (var i = 0; i < SLOTS; i++) {
		var icon = currentRow[i];
		icon.CONFIRMED = true;
		if (icon.image_index == 1) {
			icon.image_blend = c_yellow;
		} else if (icon.image_index == 2) {
			reveal(i);
		}
	}
}

function reveal(index) {
	var icon = currentRow[index];
	icon.REVEALED = true;
	icon.CONFIRMED = true;
	if (mineArray[index] == 1) {
		// TODO you lose!
		icon.image_blend = c_red;
	} else {
		icon.image_blend = c_aqua;
		icon.TEXT = string(distanceField[index]);
	}
}

// give you at least one non-mine revealed at the start
function revealRandomNonMine(){
	while (true) {
		var index = irandom_range(0, SLOTS - 1);
		if (mineArray[index] == 0) {
			reveal(index);
			break;
		}
	}
}


// called by oGoButton
// TODO maybe force you to poke at least one mine
function goButtonPressed() {
	// first score the existing line
	scoreCurrentRow()
	// next  make a new line (or lose)
	newRowOfButtons();
}

// TODO when to randomize
randomize();
mineArray = createMineArray(SLOTS, MINES);
distanceField = createDistanceField(mineArray);
newRowOfButtons();
if (REVEAL_AT_START) {
	revealRandomNonMine();
}