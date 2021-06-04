DESTDIR ?=
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

all:
	@ echo "Use: make install, make uninstall"

install:
	install -p -d $(DESTDIR)$(BINDIR)
	install -p -m0755 cache-bench $(DESTDIR)$(BINDIR)/cache-bench
	install -p -m0755 drop-caches $(DESTDIR)$(BINDIR)/drop-caches

uninstall:
	rm -fv $(DESTDIR)$(BINDIR)/cache-bench
	rm -fv $(DESTDIR)$(BINDIR)/drop-caches
