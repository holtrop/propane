
TARGET   := imbecile
CXXOBJS  := $(patsubst %.cc,%.o,$(wildcard *.cc)) tmpl.o
CXXDEPS  := $(patsubst %.o,.%.dep,$(CXXOBJS))
CXXFLAGS := -O2
DEPS     := $(CXXDEPS)
OBJS     := $(CXXOBJS)
LDFLAGS  := -lpcre
CPPFLAGS := -I$(shell pwd)/refptr

all: submodule_check tmpl.h $(TARGET)

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
.%.dep: %.c
	@set -e; rm -f $@; \
	  $(CC) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' > $@

.%.dep: %.cc tmpl.h
	@set -e; rm -f $@; \
	  $(CXX) -MM $(CPPFLAGS) $< | sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' > $@

tmpl.cc: $(wildcard tmpl/*)
	echo -n > $@
	for f in $*/*; \
		do xxd -i $$f >> $@; \
	done

tmpl.h: tmpl.cc
	echo '#ifndef $*_h' > $@
	echo '#define $*_h' >> $@
	grep '$*_' $^ | sed -e 's/^/extern /' -e 's/ =.*/;/' >> $@
	echo '#endif' >> $@

.PHONY: tests
tests: PATH := $(shell pwd):$(PATH)
tests: all
	$(MAKE) -C $@

tests-clean:
	$(MAKE) -C tests clean

clean: tests-clean
	-rm -f $(TARGET) *.o .*.dep tmpl.cc tmpl.h

-include $(CXXDEPS)
