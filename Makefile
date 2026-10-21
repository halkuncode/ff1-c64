# ==============================================================================
# Makefile for Final Fantasy 1 (Commodore 64 EasyFlash Cartridge)
# ==============================================================================

AS          = ca65
LD          = ld65
CARTCONV       = .\cartconv.exe
RETRO_DEBUGGER = ..\tools\Retro Debugger v0.64.74\Retro Debugger.exe
VICE_EMU       = ..\tools\GTK3VICE-3.10-win64\bin\x64sc.exe

SRCDIR      = src
OBJDIR      = obj
CFG         = ff1c64.cfg
TARGET      = ff1.crt
LABELFILE   = ff1.lbl
RETRO_LABELS = ff1.labels

ASFLAGS     = -g -I $(SRCDIR)
LDFLAGS     = -C $(CFG) -Ln $(LABELFILE)

INCS        = $(SRCDIR)/c64.inc $(SRCDIR)/constants.inc $(SRCDIR)/variables.inc

# Link order matching original cartridge mapping
OBJS = \
    $(OBJDIR)/bank0F.o \
    $(OBJDIR)/cartboot.o \
    $(OBJDIR)/bank00.o \
    $(OBJDIR)/bank01.o \
    $(OBJDIR)/bank02.o \
    $(OBJDIR)/bank03.o \
    $(OBJDIR)/bank04.o \
    $(OBJDIR)/bank05.o \
    $(OBJDIR)/bank06.o \
    $(OBJDIR)/bank07.o \
    $(OBJDIR)/bank08.o \
    $(OBJDIR)/bank09.o \
    $(OBJDIR)/bank0A.o \
    $(OBJDIR)/bank0B.o \
    $(OBJDIR)/bank0C.o \
    $(OBJDIR)/bank0D.o \
    $(OBJDIR)/bank0E.o

# Order of banks in EasyFlash image
BIN_ORDER = \
    bootlo.bin+boothi.bin+\
    bank01.bin+bank02.bin+bank03.bin+bank04.bin+\
    bank05.bin+bank06.bin+bank07.bin+bank08.bin+\
    bank09.bin+bank0A.bin+bank0B.bin+bank0C.bin+\
    bank0D.bin+bank0E.bin+bank0F.bin+bank00.bin+\
    padding.bin

.PHONY: all build clean run vice

all: $(TARGET)

build: all

$(OBJDIR):
	cmd.exe /c if not exist $(OBJDIR) mkdir $(OBJDIR)

$(OBJDIR)/%.o: $(SRCDIR)/%.asm $(INCS) | $(OBJDIR)
	$(AS) $(ASFLAGS) $< -o $@

$(OBJDIR)/bank09.o: res/menu/menufont.chr
$(OBJDIR)/bank0D.o: res/menu/orbs.chr
$(OBJDIR)/bank07.o: res/monsters/imp.chr res/monsters/wolf.chr res/monsters/iguana.chr res/monsters/giant.chr

$(TARGET): $(OBJS) $(CFG)
	$(LD) $(LDFLAGS) $(OBJS)
	powershell -ExecutionPolicy Bypass -File makelabels.ps1
	powershell -Command "[IO.File]::WriteAllBytes('padding.bin', [byte[]](,0xFF * 770048))"
	cmd.exe /c copy /B $(BIN_ORDER) ff1c64.out
	cmd.exe /c del *.bin
	cmd.exe /c rename ff1c64.out ff1c64.bin
	$(CARTCONV) -t easy -i ff1c64.bin -o $(TARGET)
	cmd.exe /c del ff1c64.bin

clean:
	cmd.exe /c if exist $(OBJDIR) rmdir /s /q $(OBJDIR)
	cmd.exe /c if exist *.bin del /q *.bin
	cmd.exe /c if exist *.out del /q *.out
	cmd.exe /c if exist $(LABELFILE) del /q $(LABELFILE)
	cmd.exe /c if exist $(RETRO_LABELS) del /q $(RETRO_LABELS)
	cmd.exe /c if exist $(TARGET) del /q $(TARGET)

run: all
	cmd.exe /c start "" "$(RETRO_DEBUGGER)" -crt $(TARGET) -symbols ff1.labels

vice: all
	cmd.exe /c start "" "$(VICE_EMU)" -moncommands debug.mon -cartcrt $(TARGET)
