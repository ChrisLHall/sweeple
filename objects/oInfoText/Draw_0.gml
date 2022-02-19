/// @description 
draw_set_font(fInfoText);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

draw_text_ext(x, y, "Find " + string(oManager.MINES) + " mines.\n" + infoText, -1, 192);