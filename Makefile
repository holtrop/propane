
TARGET   := imbecile
CXXOBJS  := $(patsubst %.cc,%.o,$(wildcard *.cc))
CXXDEPS  := $(CXXOBJS:.o=.dep)
CXXFLAGS := -O2
DEPS     := $(CXXDEPS)
OBJS     := $(CXXOBJS)
LDFLAGS  := -lpcre

all: submodule_check $(TARGET)

.PHONY: submodule_check
submodule_check:
	@if [ ! -e refptr/refptr.h ]; then \
		echo Error: \"refptr\" folder is not populated.; \
		echo Perhaps you forgot to do \"git checkout --recursive\"?; \
		echo You can remedy the situation with \"git submodule update --init\".; \
		exit 1; \
	fi

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
