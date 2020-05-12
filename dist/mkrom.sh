#!/bin/sh
ROM=VIC-20

  if [ -f $ROM.bin ]
  then
    rm -rf $ROM.bin
  fi

  for i in 1 2 3 4
  do
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat characters.901460-03.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat basic.901486-01.bin >> $ROM.bin
    cat VIC-20_NTSC_kernal.901486-06.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat characters.901460-03.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat 4kbfiller.bin >> $ROM.bin
    cat basic.901486-01.bin >> $ROM.bin
    cat JiffyDOS_VIC-20_6.01_NTSC.bin >> $ROM.bin
  done

