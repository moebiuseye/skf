
SHARE_DIR=/usr/share
BIN_DIR=/usr/bin

all:
	echo "nothing to do here"

install:
	cp -v ./skf* $(BIN_DIR)/
	chmod -v +rx $(BIN_DIR)/skf 
	chmod -v +rx $(BIN_DIR)/skf.gen
	chmod -v +rx $(BIN_DIR)/skf.init
	
	mkdir -p $(SHARE_DIR)/skf
	cp -vR ./plugins $(SHARE_DIR)/skf/
	cp -vR ./themes $(SHARE_DIR)/skf/
