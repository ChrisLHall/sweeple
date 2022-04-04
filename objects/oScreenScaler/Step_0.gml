/// @description detect resolution changes

//if (browser_width != lastBrowserWidth || browser_height != lastBrowserHeight) {
	lastBrowserWidth = browser_width;
	lastBrowserHeight = browser_height;
    width = min(base_width, browser_width - 2 * PADDING_X);
    height = min(base_height, browser_height - 2 * PADDING_Y);
    scaleCanvas(base_width, base_height, width, height, true);
	//scaleCanvas(base_width, base_height, browser_width, browser_height, true);
//}
