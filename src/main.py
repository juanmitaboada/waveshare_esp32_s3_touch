import time

print("Starting...")


for i in range(0, 2):
    print(f"{time.time()} - Hello world")
    time.sleep(1)

print("LVGL Example")

from micropython import const  # NOQA
import lcd_bus  # NOQA


_WIDTH = const(480)
_HEIGHT = const(320)

bus = lcd_bus.SDLBus(flags=0)

buf1 = bus.allocate_framebuffer(_WIDTH * _HEIGHT * 3, 0)

import lvgl as lv  # NOQA
import sdl_display  # NOQA


display = sdl_display.SDLDisplay(
    data_bus=bus,
    display_width=_WIDTH,
    display_height=_HEIGHT,
    frame_buffer1=buf1,
    color_space=lv.COLOR_FORMAT.RGB888,
)
display.init()

import sdl_pointer
import task_handler

mouse = sdl_pointer.SDLPointer()

# the duration needs to be set to 5 to have a good response from the mouse.
# There is a thread that runs that facilitates double buffering.
th = task_handler.TaskHandler(duration=5)

scrn = lv.screen_active()
scrn.set_style_bg_color(lv.color_hex(0x000000), 0)

slider = lv.slider(scrn)
slider.set_size(300, 25)
slider.center()

# Sleep
for i in range(0, 10):
    print(f"{time.time()} - Ready!")
    time.sleep(1)
