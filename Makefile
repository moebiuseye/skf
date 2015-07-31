
SHARE_DIR=$(DESTDIR)/usr/share
BIN_DIR=$(DESTDIR)/usr/bin

install:
	mkdir -p $(BIN_DIR)
	install -m 755 ./skf ./skf.gen ./skf.init -t $(BIN_DIR)/
	
	mkdir -p $(SHARE_DIR)/skf
	cp -R ./share/* -t $(SHARE_DIR)/skf/
	find $(SHARE_DIR)/skf -type f -exec chmod 644 {} \;
	find $(SHARE_DIR)/skf -type d -exec chmod 755 {} \;
