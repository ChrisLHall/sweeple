/// @description 
if (!variable_global_exists("isDailyChallenge")) {
	global.isDailyChallenge = true;
} else {
	global.isDailyChallenge = false;
}


previousRows = [];
currentRow = [];
mineArray = [];
distanceField = [];
turns = 0;
minesGuessed = [];
gameFinished = false;
won = false;

// 2D array. Each time you guess a set of N mines, a list of N guesses is added to this array.
// Each item in the list is how far that "poke" was from the nearest mine.
guessHistory = [];

// TODO FINISH : Tracking for the daily
todayDailyFinished = false;
todayDailyWon = false;
// guessHistory, recorded when finishing today's daily
todayDailyGuessHistory = [];


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
		y += 8 + (GRID_SIZE + PADDING) * ROWS;
	}
	var totalGridWidth = (GRID_SIZE + PADDING) * (COLS - 1);
	currentRow = makeSweeperRow((room_width - totalGridWidth) / 2, GRID_SIZE / 2 + PADDING, (GRID_SIZE + PADDING));
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
		if (currentRow[i].state == GridState.Poke) {
			total++;
		}
	}
	return total;
}

// ensure that if you are playing hard mode, you must click bombs you clicked before
function checkHardModeRule() {
	if (!oHardModeCheckBox.HARDMODE or turns == 0) {
		return true;
	}
	// if there was a bomb there must be a poke
    for (var i = 0; i < SLOTS; i++) {
		if (minesGuessed[i] == 1 and currentRow[i].state != GridState.Poke) {
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
		//icon.CONFIRMED = true;
		if (icon.state == GridState.Poke) {
			reveal(i);
		}
	}
}

function addGuessHistoryEntry() {
	var thisGuess = [];
	for (var i = 0; i < SLOTS; i++) {
		if (currentRow[i].state == GridState.Poke) {
			array_push(thisGuess, distanceField[i]);
		}
	}
	array_push(guessHistory, thisGuess);
	show_debug_message(thisGuess);
}

function entireRowCorrect() {
	var allCorrect = true;
	for (var i = 0; i < SLOTS; i++) {
		// checking XOR because they need to both be true or both be false
		if (currentRow[i].state == GridState.Poke xor mineArray[i] == 1) {
			allCorrect = false;
			break;
		}
	}
	return allCorrect;
}

function showCorrectRow() {
	for (var i = 0; i < SLOTS; i++) {
		currentRow[i].state = (mineArray[i] == 1) ? GridState.Bomb : GridState.Blank;
		currentRow[i].TEXT = "";
		currentRow[i].image_blend = oColorScheme.FOUND_BOMB;
		currentRow[i].LOCKED = true;
	}
}

function showDefeat() {
	for (var i = 0; i < SLOTS; i++) {
		currentRow[i].state = GridState.X;
		currentRow[i].TEXT = "";
		currentRow[i].image_blend = oColorScheme.LOSE;
		currentRow[i].LOCKED = true;
	}
}

function recolorPreviousGuesses() {
	for (var i = 0; i < SLOTS; i++) {
		if (currentRow[i].image_blend == oColorScheme.CLOSE_DISTANCE || currentRow[i].image_blend == oColorScheme.FAR_DISTANCE) {
			currentRow[i].image_blend = oColorScheme.LOCKED;
		}
		if (currentRow[i].state == GridState.Bomb) {
			currentRow[i].state = GridState.Blank;
		}
	}
}

function reveal(index) {
	var icon = currentRow[index];
	icon.REVEALED = true;
	if (mineArray[index] == 1) {
		icon.image_blend = oColorScheme.FOUND_BOMB;
		icon.state = GridState.Bomb;
		minesGuessed[index] = 1;
	} else {
		icon.CONFIRMED = true;
		icon.state = GridState.Blank;
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
function revealRandomNonMine() {
	while (true) {
		var index = irandom_range(0, SLOTS - 1);
		if (mineArray[index] == 0) {
			reveal(index);
			break;
		}
	}
}

function clearMineIcons() {
	for (var i = 0; i < SLOTS; i++) {
		if (currentRow[i].state == GridState.Bomb) {
			if (oHardModeCheckBox.HARDMODE) {
				currentRow[i].state = GridState.Poke;
			} else {
				currentRow[i].state = GridState.Blank;
			}
		}
	}
}


function hasGameStarted() {
	return (turns > 0);
}

function replaceGoButton() {
	//var copyButton = instance_create_layer(oGoButton.x, oGoButton.y, oGoButton.layer, oCopyButton);
	//copyButton.image_xscale = oGoButton.image_xscale;
	//copyButton.image_yscale = oGoButton.image_yscale;
	//instance_destroy(oGoButton);
	instance_deactivate_object(oGoButton);
	instance_activate_object(oCopyButton);
	instance_activate_object(oRestartButton);
}

// called by oGoButton
// TODO maybe force you to poke at least one mine
function goButtonPressed() {
	if (!checkHardModeRule()) {
		oInfoText.showInfoText("You must choose every bomb already found.");
	} else if (checkNumberOfPokes() == MINES) {
		turns++;
		addGuessHistoryEntry();
		recolorPreviousGuesses();
		if (entireRowCorrect()) {
			gameFinished = true;
			won = true;
			showCorrectRow();
			replaceGoButton();
			oInfoText.showPermanentText("Great job! You won in " + string(turns) + " turns.");
		} else if (turns == 6) {
			// TODO test
			gameFinished = true;
			showDefeat();
			replaceGoButton();
			oInfoText.showPermanentText("You did not find the bombs in time.");
		} else {
			// first score the existing line
			scoreCurrentRow()
			// then remove the bomb icons after a bit
			alarm_set(0, 60);
			// next  make a new line (or lose)
			//newRowOfButtons();
		}
		
		if (gameFinished) {
			if (global.isDailyChallenge) {
				todayDailyFinished = true;
				todayDailyWon = won;
				todayDailyGuessHistory = guessHistory;
				
				show_debug_message("FINISHED - SAVING GAME");
				scrSaveGame();
			}	
		}
	} else {
		oInfoText.showInfoText("Choose exactly " + string(MINES) + " squares.");
	}
}

// TODO TESTINGGGGG
var arr = scrStringToGuesses("0,5,8,4,4,2;3,0,0,0,0,1;3,5,2,0,1,0");
show_debug_message(string(arr));


if (global.isDailyChallenge) {
	show_debug_message("LOADING GAME for the daily");
	scrLoadGame();
}

// TODO when to randomize
//randomize();
if (global.isDailyChallenge) {
	// Generate a seed from today's date 
	var now = date_current_datetime();
	var day = date_get_day(now);
	var month = date_get_month(now);
	var year = date_get_year(now);
	//literally just use the date as a seed ig?
	show_debug_message("Daily challenge " + string(year * 10000 + month * 100 + day));
	random_set_seed(year * 10000 + month * 100 + day);
} else {
	randomize();
}


// TODO values
ROWS = irandom_range(MIN_ROWS, MAX_ROWS);
COLS = irandom_range(MIN_COLS, MAX_COLS);
SLOTS = ROWS * COLS;
MINES = max(2, irandom_range(SLOTS * MIN_DENSITY, SLOTS * MAX_DENSITY));

mineArray = createMineArray(SLOTS, MINES);
distanceField = createDistanceField(mineArray);
minesGuessed = array_create(SLOTS, 0);
newRowOfButtons();
if (REVEAL_AT_START) {
	revealRandomNonMine();
}