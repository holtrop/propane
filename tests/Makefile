
all:
	for d in *; do \
		if [ -d $$d ]; then \
			make -C $$d; \
		fi; \
	done

clean:
	for d in *; do \
		if [ -d $$d ]; then \
			make -C $$d clean; \
		fi; \
	done
