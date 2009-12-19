#ifndef BITSTREAM_H
#define BITSTREAM_H

#include "common.h"
#include "args.h"

// Header mask definition
#define HDRCMPMASK 0xfffffd00

// Maximum frame size
#define MAXFRAMESIZE 1792

extern int head_read(unsigned char *hbuf,unsigned long *newhead);
extern int head_check(unsigned long newhead); 
extern bool Init_Stream();
extern bool Done_Stream();
extern long Stream_GetSize();
extern long Stream_GetPosition();
extern bool Stream_Read(void *p, unsigned long BytesToRead);
extern bool Stream_ReadHeader();
  // Seek to stream position in frames
  extern bool Seek_Stream(unsigned long Position);
  // Gets the stream bits for the decoder
  extern unsigned long  __inline Get1Bit(void);
  extern unsigned long __inline GetBits(int);
  extern unsigned long __inline GetBitsFast(int);
  // Sets the bit pointer
  extern void SetPointer(long);
  // Resets bitstream potision to zero 
  extern void Reset_Stream();

extern bool StreamInit;

extern unsigned long MaxFrames, MinFrames;

extern long freqs[];

#endif
