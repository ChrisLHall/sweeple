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
			// copy color state and text, and lock non-mines
			currentRow[i].TEXT = previousRow[i].TEXT;
			currentRow[i].image_blend = previousRow[i].image_blend;
			if (previousRow[i].CONFIRMED && previousRow[i].TEXT != "" && mineArray[i] == 0) {
				currentRow[i].CONFIRMED = true;
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
		currentRow[i].image_blend = c_green;
	}
}

function reveal(index) {
	var icon = currentRow[index];
	icon.REVEALED = true;
	icon.CONFIRMED = true;
	if (mineArray[index] == 1) {
		// TODO you lose!
		icon.image_blend = c_green;
		icon.image_index = 3;
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
	if (checkNumberOfPokes() == MINES) {
		oInfoText.showInfoText("");
		if (entireRowCorrect()) {
			showCorrectRow();
			// hack
			instance_destroy(oGoButton);
			oInfoText.showInfoText("Great job! " + string(array_length(previousRows) + 1) + " guesses.");
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

// TODO when to randomize
randomize();
// TODO values
SLOTS = irandom_range(MIN_SLOTS, MAX_SLOTS);
MINES = irandom_range(SLOTS * MIN_DENSITY, SLOTS * MAX_DENSITY);

mineArray = createMineArray(SLOTS, MINES);
distanceField = createDistanceField(mineArray);
newRowOfButtons();
if (REVEAL_AT_START) {
	revealRandomNonMine();
}