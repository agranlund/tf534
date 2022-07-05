REVISION=3
BOARD:=tf520

RTLFOLDER=../../Runtime/
BUSSOURCES="./$(BOARD)r$(REVISION)_bus_top.v $(RTLFOLDER)/bus_top.v  $(RTLFOLDER)/m6800.v $(RTLFOLDER)/bus_delay.v"
RAMSOURCES="./$(BOARD)r$(REVISION)_ram_top.v $(RTLFOLDER)/ram_top.v $(RTLFOLDER)/fastram.v $(RTLFOLDER)/gayle.v $(RTLFOLDER)/zxmmc.v $(RTLFOLDER)/autoconfig_zii.v"


all: $(BOARD)r$(REVISION)
$(BOARD)r$(REVISION): clean $(BOARD)r$(REVISION)_bus
$(BOARD)r$(REVISION)_bus:
	make -f ../Makefile.cpld BOARD=$(BOARD) SOURCES=$(BUSSOURCES) SUBPROJ=bus REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed
zip: distclean $(BOARD)r$(REVISION)
	zip $(BOARD)r$(REVISION)_`date +"%Y_%m_%d"`_alpha.zip *.jed
clean:	
	rm -rf work _xmsgs xlnx_auto* *.zip
distclean: clean
	rm -f *.jed *~ *.svf 
