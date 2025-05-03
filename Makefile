BASE_FILES=main.py
ALL_FILES=$(BASE_FILES) \
		config.py
#		logging \
#		codenerix_lib \

# DEVICE=/dev/ttyUSB0
DEVICE=/dev/ttyACM0
SRC=src
MICROPYTHON_IMAGE=bin/ESP32_GENERIC_S3-20250415-v1.25.0.bin
FACTORY_IMAGE=bin/ESP32-S3-Touch-AMOLED-1.43-factory.bin

FILES = $(shell . ./env/bin/activate && ampy --port $(DEVICE) ls)

default:
	make clean_base
	make upload_base
	make run

all:
	make clean_all
	make upload_all
	make run

clean_base:
	# === Uploading === ======================================================
	$(foreach FILE, $(BASE_FILES), \
		echo "Cleaning $(FILE)..."; \
		. ./env/bin/activate && ampy --port $(DEVICE) rm $(FILE) 2>/dev/null || ampy --port $(DEVICE) rmdir $(FILE); \
	)

clean_all:
	# === Cleaning === =======================================================
	$(foreach FILE, $(FILES), \
		echo "Cleaning $(FILE)..."; \
		. ./env/bin/activate && ampy --port $(DEVICE) rm $(FILE) 2>/dev/null || ampy --port $(DEVICE) rmdir $(FILE); \
	)

upload_base:
	# === Uploading === ======================================================
	$(foreach FILE, $(BASE_FILES), \
		echo "Uploading $(FILE)..."; \
		. ./env/bin/activate && ampy --port $(DEVICE) put $(SRC)/$(FILE); \
	)

upload_all:
	# === Uploading === ======================================================
	$(foreach FILE, $(ALL_FILES), \
		echo "Uploading $(FILE)..."; \
		. ./env/bin/activate && ampy --port $(DEVICE) put $(SRC)/$(FILE); \
	)

run:
	# === Executing === ======================================================
	. ./env/bin/activate && ampy --port $(DEVICE) run $(SRC)/main.py

monitor:
	# === Monitoring === =====================================================
	screen $(DEVICE) 115200

stubs:
	pip install -U  micropython-esp32-stubs --target ./typings --no-user

env:
	virtualenv -p python3 env
	(. ./env/bin/activate && pip install -r requirements.txt)

lvgl_prepare:
	git clone --recursive https://github.com/lvgl/lv_micropython.git
	cd lv_micropython
	make -C ports/esp32 submodules
	make -C ports/esp32 BOARD=ESP32_GENERIC_S3

erase_flash:
	# === Erasing MicroPython === ===========================================
	# Erasing MicroPython into MicroPython board
	(. ./env/bin/activate && esptool.py --port $(DEVICE) erase_flash )

factory:
	# === Flashing MicroPython === ===========================================
	# Flashing Factory into ESP32-S3 board
	(. ./env/bin/activate && esptool.py --port $(DEVICE) --baud 460800 write_flash -z 0x0 $(FACTORY_IMAGE) )


flash:
	# === Flashing MicroPython === ===========================================
	# Flashing MicroPython into MicroPython board
	(. ./env/bin/activate && esptool.py --port $(DEVICE) --baud 460800 write_flash -z 0x0 $(MICROPYTHON_IMAGE) )
