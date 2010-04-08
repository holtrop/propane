
TARGET   := imbecile
CXXOBJS  := $(patsubst %.cc,%.o,$(wildcard *.cc))
CXXDEPS  := $(CXXOBJS:.o=.dep)
CXXFLAGS := -O2
DEPS     := $(CXXDEPS)
OBJS     := $(CXXOBJS)
LDFLAGS  := -lpcre

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) -o $@ $^ $(LDFLAGS)

# Object file rules
%.o: %.cc
	$(CXX) -c -o $@ $(CPPFLAGS) $(CXXFLAGS) $<

# Make dependency files
%.dep: %.c
	@set -e; rm -f $@; \
	  $(CC) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' > $@

%.dep: %.cc
	@set -e; rm -f $@; \
	  $(CXX) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' > $@

clean:
	-rm -f $(TARGET) *.o *.dep
