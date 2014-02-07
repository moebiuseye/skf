
SHARE_DIR=$(DESTDIR)/usr/share
BIN_DIR=$(DESTDIR)/usr/bin

all:
	echo "nothing to do here"

install:
	echo $(DESTDIR)
	
	mkdir -p $(BIN_DIR)
	cp ./skf* $(BIN_DIR)/
	chmod +rx $(BIN_DIR)/skf 
	chmod +rx $(BIN_DIR)/skf.gen
	chmod +rx $(BIN_DIR)/skf.init
	
	mkdir -p $(SHARE_DIR)/skf
	cp -R ./share/ $(SHARE_DIR)/skf
