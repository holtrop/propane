
TARGET   := test
I_SOURCE := itest
CXXFLAGS := -O2
LDFLAGS  := -lpcre

all: $(TARGET)
	./$(TARGET)

$(TARGET): $(shell which imbecile) $(I_SOURCE).I $(wildcard *.cc)
	imbecile $(I_SOURCE).I
	$(CXX) -o $@ *.cc $(LDFLAGS)

clean:
	-rm -f $(TARGET) *.o $(I_SOURCE).cc $(I_SOURCE).h
