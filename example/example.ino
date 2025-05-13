#include "lcd_bsp.h"
#include "FT3168.h"

// Font
#include "lv_font_montserrat_192b.c"

#define BUZZER_PIN 2  // Set to -1 to disable buzzer logic

lv_obj_t* label;
lv_obj_t* helper_label;
lv_obj_t* progress_arc;
lv_timer_t* countdown_timer;
int counter = 10;
bool countdown_done = false;

void trigger_beep() {
#if BUZZER_PIN >= 0
  digitalWrite(BUZZER_PIN, HIGH);
  delay(100);
  digitalWrite(BUZZER_PIN, LOW);
#endif
}

void animate_fade_in(lv_obj_t* obj) {
  lv_anim_t a;
  lv_anim_init(&a);
  lv_anim_set_var(&a, obj);
  lv_anim_set_values(&a, LV_OPA_TRANSP, LV_OPA_COVER);
  lv_anim_set_time(&a, 300);
  lv_anim_set_exec_cb(&a, (lv_anim_exec_xcb_t)lv_obj_set_style_opa);
  lv_anim_set_path_cb(&a, lv_anim_path_ease_in);
  lv_anim_start(&a);
}

void update_counter(lv_timer_t* timer) {
  char buf[4];
  sprintf(buf, "%d", counter);
  lv_label_set_text(label, buf);
  // // animate_fade_in(label);  // Temporarily disabled to avoid flickering issue

  lv_color_t color;
  if (counter >= 5) {
    color = lv_color_hex(0x00FF00);  // Green
  } else if (counter >= 2) {
    color = lv_color_hex(0xFFA500);  // Orange
  } else {
    color = lv_color_hex(0xFF0000);  // Red
    trigger_beep();
  }

  lv_obj_set_style_text_color(label, color, LV_PART_MAIN);
  lv_arc_set_value(progress_arc, counter);

  if (counter == 0) {
    lv_timer_pause(timer);
    countdown_done = true;
    return;
  }

  counter--;
}

void setup() {
  Serial.begin(115200);
#if BUZZER_PIN >= 0
  pinMode(BUZZER_PIN, OUTPUT);
#endif
  Touch_Init();
  lcd_lvgl_Init();

  lv_obj_set_style_bg_color(lv_scr_act(), lv_color_hex(0x000000), LV_PART_MAIN);

  helper_label = lv_label_create(lv_scr_act());
  lv_label_set_text(helper_label, "Starting in...");
  lv_obj_align(helper_label, LV_ALIGN_TOP_MID, 0, 40);
  lv_obj_set_style_text_color(helper_label, lv_color_hex(0xAAAAAA), LV_PART_MAIN);

  label = lv_label_create(lv_scr_act());
  lv_obj_set_style_text_font(label, &lv_font_montserrat_192b, LV_PART_MAIN);
  lv_obj_set_style_opa(label, LV_OPA_COVER, LV_PART_MAIN);
  lv_obj_align(label, LV_ALIGN_CENTER, 0, 0);

  progress_arc = lv_arc_create(lv_scr_act());
lv_obj_clear_flag(progress_arc, LV_OBJ_FLAG_CLICKABLE);  // Disable touch interaction
  lv_obj_set_size(progress_arc, 280, 280);
  lv_obj_align(progress_arc, LV_ALIGN_CENTER, 0, 0);
  lv_arc_set_rotation(progress_arc, 270);
  lv_arc_set_bg_angles(progress_arc, 0, 360);
  lv_arc_set_range(progress_arc, 0, 10);
  lv_arc_set_value(progress_arc, 10);
  lv_obj_remove_style(progress_arc, NULL, LV_PART_KNOB);
  lv_obj_set_style_arc_color(progress_arc, lv_color_hex(0x0077FF), LV_PART_INDICATOR);
  lv_obj_move_foreground(label);
  lv_obj_move_foreground(helper_label);

  countdown_timer = lv_timer_create(update_counter, 1000, NULL);
  update_counter(countdown_timer);
}

void loop() {
  // Empty - LVGL handled in background task
}

// Add this to your touch callback:
extern "C" void example_lvgl_touch_cb(lv_indev_drv_t* drv, lv_indev_data_t* data) {
  static bool was_released = true;
  uint16_t tp_x, tp_y;
  uint8_t touched = getTouch(&tp_x, &tp_y);
  if (touched) {
    if (was_released) {
      was_released = false;
      Serial.println("Touch detected");
      data->point.x = tp_x;
      data->point.y = tp_y;
      data->state = LV_INDEV_STATE_PRESSED;

      if (countdown_done) {
        countdown_done = false;
        counter = 10;
        lv_arc_set_value(progress_arc, 10);
        char restart_buf[4];
        sprintf(restart_buf, "%d", counter);
        lv_label_set_text(label, restart_buf);
        lv_obj_set_style_text_color(label, lv_color_hex(0x00FF00), LV_PART_MAIN);
        // animate_fade_in(label);
        lv_timer_resume(countdown_timer);
      }
    } else {
      data->state = LV_INDEV_STATE_PRESSED;
    }

    if (countdown_done) {
      countdown_done = false;
      counter = 10;
      lv_arc_set_value(progress_arc, 10);
      char restart_buf[4];
sprintf(restart_buf, "%d", counter);
lv_label_set_text(label, restart_buf);
      lv_obj_set_style_text_color(label, lv_color_hex(0x00FF00), LV_PART_MAIN);
      animate_fade_in(label);
      lv_timer_resume(countdown_timer);
    }
  } else {
    was_released = true;
    data->state = LV_INDEV_STATE_RELEASED;
  }
}
