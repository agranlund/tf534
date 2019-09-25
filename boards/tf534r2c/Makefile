REVISION=2c
BOARD=tf534

ifndef TARGET
	TARGET=AMIGA
endif

RTLFOLDER=../../rtl/
BUSSOURCES="$(RTLFOLDER)/bus_top.v  $(RTLFOLDER)/m6800.v $(RTLFOLDER)/ata.v  $(RTLFOLDER)/bus_delay.v"
RAMSOURCES="$(RTLFOLDER)/ram_top.v $(RTLFOLDER)/fastram.v $(RTLFOLDER)/gayle.v $(RTLFOLDER)/zxmmc.v $(RTLFOLDER)/autoconfig.v $(RTLFOLDER)/intreqr.v"


all: $(BOARD)r$(REVISION)
$(BOARD)r$(REVISION): clean $(BOARD)r$(REVISION)_ram $(BOARD)r$(REVISION)_bus
$(BOARD)r$(REVISION)_ram:
	make -f ../Makefile.cpld TARGET=$(TARGET) BOARD=$(BOARD) SOURCES=$(RAMSOURCES) SUBPROJ=ram REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed TOP=ram_top
$(BOARD)r$(REVISION)_bus:
	make -f ../Makefile.cpld TARGET=$(TARGET) BOARD=$(BOARD) SOURCES=$(BUSSOURCES) SUBPROJ=bus REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed TOP=bus_top
zip: distclean $(BOARD)r$(REVISION)
	zip $(BOARD)r$(REVISION)_$(TARGET)_`date +"%Y_%m_%d"`_alpha.zip *.jed
clean:	
	rm -rf work _xmsgs *.zip
distclean: clean
	rm -f *.jed *~ *.svf 
