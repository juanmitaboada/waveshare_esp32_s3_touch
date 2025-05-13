BASE_FILES=main.py
ALL_FILES=$(BASE_FILES) \
		config.py
#		logging \
#		codenerix_lib \

# DEVICE=/dev/ttyUSB0
DEVICE=/dev/ttyACM0
SRC=src
# MICROPYTHON_IMAGE=bin/ESP32_GENERIC_S3-20250415-v1.25.0.bin
MICROPYTHON_IMAGE=bin/ESP32_S3_Touch_QSPI_1.43-8.bin
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

idf:
	-git clone -b v5.4.1 --recursive https://github.com/espressif/esp-idf.git
	cd esp-idf &&  ./install.sh esp32s3
	# source esp-idf/export.sh

# lvgl:
# 	# === Preparing LVGL === =================================================
# 	git clone https://github.com/lvgl/lv_micropython || cd lv_micropython && git pull
# 	cd lv_micropython && git submodule update --init --recursive
# 	make -C lv_micropython/ports/esp32 BOARD=ESP32_GENERIC_S3 submodules
# 	@echo "Use 4 ESP32 GENERIX S3 SPIRAM OCT"
# 	cd lv_micropython/scripts && ./build-esp32.sh
# 	# ./deploy-esp32.sh

lvgl:
	# === Preparing LVGL === =================================================
	git clone https://github.com/lvgl-micropython/lvgl_micropython || cd lvgl_micropython && git pull
	(cd lvgl_micropython ; python3 make.py esp32 BOARD=ESP32_S3_Touch_QSPI_1.43)
	# (cd lvgl_micropython ; python3 make.py esp32 BOARD=ESP32_GENERIC_S3)
	#cp lvgl_micropython/build/lvgl_micropy_ESP32_GENERIC_S3-8.bin bin/

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
