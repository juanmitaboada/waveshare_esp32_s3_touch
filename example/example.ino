#include "lcd_bsp.h"
#include "FT3168.h"

// Font
// #include "lv_font_montserrat_192.c"
#include "lv_font_montserrat_192b.c"

lv_obj_t* label;
lv_timer_t* countdown_timer;
int counter = 10;

void update_counter(lv_timer_t* timer) {
  // Change label text
  char buf[4];
  sprintf(buf, "%d", counter);
  lv_label_set_text(label, buf);

  // Set color based on value
  lv_color_t color;
  if (counter >= 5) {
    color = lv_color_hex(0x00FF00);  // Green
  } else if (counter >= 2) {
    color = lv_color_hex(0xFFA500);  // Orange
  } else {
    color = lv_color_hex(0xFF0000);  // Red
  }

  lv_obj_set_style_text_color(label, color, LV_PART_MAIN);

  // Stop at 0
  if (counter == 0) {
    // lv_timer_pause(timer);
    // return;
    counter = 11;
  }

  counter--;
}

void setup()
{
  Serial.begin(115200);
  Touch_Init();         // Initialize I2C and FT3168
  lcd_lvgl_Init();      // Initialize LCD and LVGL

  // Set background to black
  lv_obj_set_style_bg_color(lv_scr_act(), lv_color_hex(0x000000), LV_PART_MAIN);

  // Create centered label
  label = lv_label_create(lv_scr_act());
  lv_obj_set_style_text_font(label, &lv_font_montserrat_192b, LV_PART_MAIN); // Larger font
  lv_obj_align(label, LV_ALIGN_CENTER, 0, 0);

  // Start countdown every 1000ms (1 second)
  countdown_timer = lv_timer_create(update_counter, 1000, NULL);
  update_counter(countdown_timer); // Call immediately for first value
}

void loop() {
  // GUI is handled in background task
}
