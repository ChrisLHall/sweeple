/// @description 
previousRows = [];
currentRow = [];
mineArray = [];
distanceField = [];
turns = 0;

function slotIndexToRow(slotIndex) {
	return floor(slotIndex / COLS);
}

function slotIndexToCol(slotIndex) {
	return slotIndex mod COLS;
}

function rowColToSlotIndex(row, col) {
	return row * COLS + col;
}

// oops previousRow should now be like previousGrid or something like that
function newRowOfButtons() {
	var previousRow = noone;
	if (array_length(currentRow) > 0) {
		previousRow = currentRow;
		array_push(previousRows, currentRow);
		y += 8 + 32 * ROWS;
	}
	currentRow = makeSweeperRow(x, y, 32);
	if (previousRow != noone) {
		for (var i = 0; i < SLOTS; i++) {
			// copy color state and text, and lock non-mines
			//currentRow[i].TEXT = previousRow[i].TEXT;
			//currentRow[i].image_blend = previousRow[i].image_blend;
			// todo check mines better than hardcoded color
			if (previousRow[i].image_blend == oColorScheme.FOUND_BOMB) {
				currentRow[i].image_blend = oColorScheme.FOUND_BOMB;
			}
			if (previousRow[i].LOCKED) {
				currentRow[i].LOCKED = true;
				currentRow[i].image_blend = oColorScheme.LOCKED;
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
	var result = array_create(SLOTS);
	for (var i = 0; i < SLOTS; i++) {
		var closestDistance = 1000;
		for (var j = 0; j < SLOTS; j++) {
			if (mineArray[j] == 1) {
				// taxicab distance
				var dist = abs(slotIndexToRow(i) - slotIndexToRow(j)) + abs(slotIndexToCol(i) - slotIndexToCol(j));
				if (dist < closestDistance) {
					closestDistance = dist;
				}
			}
		}
		result[i] = closestDistance;
	}
	return result;
}

// old distance field (1d) function
/* var dist = abs(j - i);
				if (WRAP_DISTANCE) {
					var edge_dist = abs(i + SLOTS - j);
					var edge_dist_2 = abs(j + SLOTS - i);
					dist = min(dist, min(edge_dist, edge_dist_2));
				} */


function makeSweeperRow(startX, startY, spacing) {
	var result = array_create(SLOTS);
	for (var i = 0; i < SLOTS; i++) {
		result[i] = instance_create_layer(startX + slotIndexToCol(i) * spacing, startY + slotIndexToRow(i) * spacing, "Instances", oSweeperIcon);
	}
	return result;	
}

// ensure the number of pokes on the current row is the same as the number of mines
function checkNumberOfPokes() {
	var total = 0;
	for (var i = 0; i < SLOTS; i++) {
		if (currentRow[i].image_index == 2) {
			total++;
		}
	}
	return total;
}

// ensure that if you are playing hard mode, you must click bombs you clicked before
function checkHardModeRule() {
	if (!oHardModeCheckBox.HARDMODE or array_length(previousRows) == 0) {
		return true;
	}
	var mostRecentRow = previousRows[array_length(previousRows) - 1];
	// if there was a bomb there must be a poke
    for (var i = 0; i < SLOTS; i++) {
		if (mostRecentRow[i].image_index == 3 and currentRow[i].image_index != 2) {
			return false;
		}
	}
	return true;
}

// recall that image_index 0 is blank, 1 is flag, 2 is poke
// score the whole thing if 
function scoreCurrentRow() {
	for (var i = 0; i < SLOTS; i++) {
		var icon = currentRow[i];
		icon.CONFIRMED = true;
		if (icon.image_index != 0) {
			reveal(i);
		}
	}
}

function entireRowCorrect() {
	var allCorrect = true;
	for (var i = 0; i < SLOTS; i++) {
		var correctImage = (mineArray[i] == 1) ? 2 : 0;
		if (currentRow[i].image_index != correctImage) {
			allCorrect = false;
			break;
		}
	}
	return allCorrect;
}

function showCorrectRow() {
	for (var i = 0; i < SLOTS; i++) {
		currentRow[i].image_index = (mineArray[i] == 1) ? 3 : 0;
		currentRow[i].TEXT = "";
		// TODO pick some real colors
		currentRow[i].image_blend = oColorScheme.FOUND_BOMB;
	}
}

function reveal(index) {
	var icon = currentRow[index];
	icon.REVEALED = true;
	icon.CONFIRMED = true;
	if (mineArray[index] == 1) {
		icon.image_blend = oColorScheme.FOUND_BOMB;
		icon.image_index = 3;
	} else {
		icon.image_index = 0;
		// color based on distance
		if (distanceField[index] <= 2) {
			icon.image_blend = oColorScheme.CLOSE_DISTANCE;
		} else {
			icon.image_blend = oColorScheme.FAR_DISTANCE;
		}
		icon.TEXT = string(distanceField[index]);
		icon.LOCKED = true;
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
	if (!checkHardModeRule()) {
		oInfoText.showInfoText("In hard mode, you must choose every bomb you found before.");
	} else if (checkNumberOfPokes() == MINES) {
		oInfoText.showInfoText("");
		turns++;
		if (entireRowCorrect()) {
			showCorrectRow();
			// hack
			instance_destroy(oGoButton);
			oInfoText.showInfoText("Great job! You won in " + string(turns) + " turns.");
		} else {
			// first score the existing line
			scoreCurrentRow()
			// next  make a new line (or lose)
			newRowOfButtons();
		}
	} else {
		oInfoText.showInfoText("Choose exactly " + string(MINES) + " squares.");
	}
}

function hasGameStarted() {
	return array_length(previousRows) > 0;
}

// TODO when to randomize
randomize();
// TODO values
ROWS = irandom_range(MIN_ROWS, MAX_ROWS);
COLS = irandom_range(MIN_COLS, MAX_COLS);
SLOTS = ROWS * COLS;
MINES = max(2, irandom_range(SLOTS * MIN_DENSITY, SLOTS * MAX_DENSITY));

mineArray = createMineArray(SLOTS, MINES);
distanceField = createDistanceField(mineArray);
newRowOfButtons();
if (REVEAL_AT_START) {
	revealRandomNonMine();
}