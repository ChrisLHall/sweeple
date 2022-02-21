/// @description 
draw_sprite_ext(sButton, 0, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
if (state != GridState.Blank) {
	draw_sprite_ext(sButton, state, x, y, image_xscale, image_yscale, image_angle, c_black, image_alpha);
}

draw_set_font(fNumber);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y, TEXT);
