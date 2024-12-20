# Makefile generated by imake - do not edit!

 #***********************************************************************
 #
 # This makefile is automatically generated by imake.  If you need to change
 # the makefile, edit the .imake file and re-run imake, or contact the VICAR
 # system programmer to change the imake templates.
 #
 # *** DO NOT EDIT THIS FILE!! ***
 #
 #***********************************************************************

 #

UNIT_NAME = xyz_to_uvw
 # VICAR subroutine xyz_to_uvw

 #
 #***********************************************************************

CCC = g++

SHELL = /bin/sh
CP = cp
CHMOD_X = chmod +x

AR = ar r

ARX = ar x

RM = rm -f

LN = ln -fs

RANLIB = ranlib

RUN_TM  = taetm
MSGBLD  = $$TAEPDF/msgbld

.cc.o:
	$(CCC) $(CCCFLAGS) $(CPPFLAGS) -c  $<

CCCFLAGS = -O      -Wno-implicit -Wno-invalid-offsetof -Wno-write-strings  -ffriend-injection

CPPFLAGS =  -I$(V2INC)     -I$(P1INC)     -I$(P2INC) -I$(P2GENINC)     -I$(MARSINC)   -I$(MERIDDLIB) -I$(MERIDDLIB)/merfsw_stubs -I$(MERIDDLIB)/idd

OBJS = xyz_to_uvw.o

INCLUDES =

CLEANOBJS = xyz_to_uvw.o

CLEANSRC = xyz_to_uvw.cc

CLEANOTHER =

CLEANINC =

 # Note that SYSTEMINC is used only for includes that are installed,
 # e.g. from a TAO/IDL build.

LOCALLIB = sublib.a

SYSTEMLIB = $(V2OLB)/libmarssub.a
SYSTEMINC = $(MARSINC)

std: library.local

all: library.local doc

system: library.system  doc clean.obj clean.src

compile:  $(OBJS)

library.local: library.local.only

library.local.only:  $(OBJS)
	-$(AR) $(LOCALLIB) $(OBJS)
	$(RANLIB) $(LOCALLIB)

library.system: library.system.only

library.system.only:  $(OBJS)
	-$(AR) $(SYSTEMLIB) $(OBJS)
	$(RANLIB) $(SYSTEMLIB)

doc:

clean.obj:
	-$(RM) $(CLEANOBJS)

clean.src:
	-$(RM) $(CLEANSRC) $(CLEANINC) $(CLEANOTHER)
	-$(RM) $(UNIT_NAME).make $(UNIT_NAME).bld $(UNIT_NAME).imake

$(OBJS): $(INCLUDES)

