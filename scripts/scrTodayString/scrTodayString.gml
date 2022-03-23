// return a string of today YYYY-MM-DD
function scrTodayString() {
	var now = date_current_datetime();
	var year = date_get_year(now);
	var month = date_get_month(now);
	var day = date_get_day(now);
	return string(year) + "-" + string(month) + "-" + string(day);
}