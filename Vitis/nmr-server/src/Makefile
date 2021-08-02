
# CXX=arm-xilinx-linux-gnueabi-g++
CXX=arm-linux-gnueabihf-g++
# CXXFLAGS= -static -std=c++11 -O3 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard -mfp=vfpv3-fp16
CXXFLAGS= -static -std=c++11 -O3 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard -Wall
# TODO: cc1plus.real: warning: switch '-mcpu=cortex-a9' conflicts with '-march=armv7-a' switch
LIBS=-lm -lpthread
DEPS = 
TARGET = nmr-server
OBJECTS = nmrcore.o
CURRENTDATE = $(shell date +%m%d%H%M.%S)

all: $(TARGET)

clean:
	rm -f $(TARGET) *.o

$(TARGET): $(OBJECTS)
	$(CXX) -o $@ $^ main.cpp $(LIBS) $(CXXFLAGS)

%.o: %.cpp %.h $(DEPS)
	$(CXX) -o $@ -c $< $(LIBS) $(CXXFLAGS)

upload: $(TARGET)
	scp $(TARGET) root@nmr:/root

remote: upload-src build-src

upload-src: set-date
	scp -p * root@nmr:/root/build

build-src:
	ssh root@nmr 'cd /root/build; make clean all'

bit: upload-bit update-bit

upload-bit:
	scp ../../../PulsedNMR_wrapper.bit root@nmr:/root

update-bit:
	ssh root@nmr 'cat /root/PulsedNMR_wrapper.bit >/dev/xdevcfg'

set-date:
	ssh root@nmr 'date ${CURRENTDATE}'	