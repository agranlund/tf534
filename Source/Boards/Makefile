ifndef TARGET
	TARGET=AMIGA
endif
export TARGET

ifeq ($(TARGET), ATARI)
BOARDS:=tf534r2c tf530r3
else
BOARDS:=tf520 tf530r2 tf530r3 tf534r2c
endif


.PHONY: $(BOARDS)
FOLDER:=tf53x_`date +"%Y_%m_%d"`
all: clean
	rm -rf ./tf53x_*
	mkdir ./$(FOLDER)
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD); \
	cp $(BOARD)/*.jed ./$(FOLDER);)
	zip $(FOLDER)_$(TARGET)_alpha.zip ./$(FOLDER)/*
	rm -rf $(FOLDER)
clean: 
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD) clean;)
distclean: 
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD) distclean;)
