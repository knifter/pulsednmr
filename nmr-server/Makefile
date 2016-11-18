
# CXX=arm-xilinx-linux-gnueabi-g++
CXX=arm-linux-gnueabihf-g++
# CXXFLAGS= -static -std=c++11 -O3 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard -mfp=vfpv3-fp16
CXXFLAGS= -static -std=c++11 -O3 -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard
LIBS=-lm -lpthread
DEPS = 
TARGET = nmr-server
OBJECTS = nmrcore.o

all: $(TARGET)

clean:
	rm -f $(TARGET) *.o

$(TARGET): $(OBJECTS)
	$(CXX) -o $@ $^ main.cpp $(LIBS) $(CXXFLAGS)

%.o: %.cpp %.h $(DEPS)
	$(CXX) -o $@ -c $< $(LIBS) $(CXXFLAGS)

upload: $(TARGET)
	scp $(TARGET) root@redp:/root