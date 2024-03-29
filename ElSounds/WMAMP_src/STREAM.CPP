#include <io.h>
#include <fcntl.h>
#include "stream.h"
#include "args.h"
#include "player.h"

// Bitrate index,in order: MPEG version,layer,bitrate index 
int BitRateIndex[2][3][16]=
{{{0,32,64,96,128,160,192,224,256,288,320,352,384,416,448,},
{0,32,48,56,64,80,96,112,128,160,192,224,256,320,384,},
{0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,}},
{{0,32,48,56,64,80,96,112,128,144,160,176,192,224,256,},
{0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,},
{0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,}}};

struct ibuf 
{
    struct ibuf *next;
    struct ibuf *prev;
    unsigned char *buf;
    unsigned char *pnt;
    int len;
};

struct ibuf ibufs[2];
struct ibuf *cibuf;
unsigned char bsspace[2][MAXFRAMESIZE+512],*bsbuf=bsspace[1],*bsbufold;
static HGLOBAL MBHnd;
static char *MappedBuffer = NULL;
static DWORD MappedPointer = 0;
static int framesize;

int bitindex;
unsigned char *wordpointer;
HANDLE StreamHandle;
bool StreamOpen;
unsigned long StreamSize;
ID3TagStruct *ID3;
bool ID3TagSupported; 
int ibufnum, fsize, fsizeold, ssize, bsnum;
unsigned long oldhead,firsthead, MinFrames, MaxFrames;
esInputMode InputMode;

bool StreamInit = false;

bool Init_Stream(){
    StreamSize = 0; 
    char *buf = (char *)malloc(128);
    SECURITY_ATTRIBUTES Sec;
    long numread;
    // Set the security attributes 
    Sec.nLength = sizeof(SECURITY_ATTRIBUTES);
    Sec.lpSecurityDescriptor = false;
    Sec.bInheritHandle = false;
    // Open the stream using CreateFile
    InputMode = Args->InputMode;    
    if (InputMode == imCallback) {
        if (!Args->InOpenCB(Args->InCBData1, &Args->InCBData2, &Args->Seekable)) {
            free(buf); 
            throw 1;
        };
        if (!Args->InGetSizeCB(Args->InCBData1, Args->InCBData2, &StreamSize)) {
            free(buf); 
            throw 1;
        };
    } else {
        // Open the stream using CreateFile
        StreamHandle = CreateFile(Args->InName, GENERIC_READ, FILE_SHARE_READ,&Sec, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_RANDOM_ACCESS, NULL);
        if(StreamHandle == INVALID_HANDLE_VALUE) { 
            free(buf); 
            throw 1;        
        };
        StreamSize = GetFileSize(StreamHandle, NULL);
    }

    // Set "stream is open" flag
    StreamOpen = true;
    
    if (InputMode == imCallback) {
        if (!Args->InSeekCB(Args->InCBData1, Args->InCBData2, -128, FILE_END)) {
            ID3TagSupported=false;
        } else
        if (!Args->InReadCB (Args->InCBData1, Args->InCBData2, buf, 127, (DWORD*) &numread) || (numread != 127)) {
            free(buf);
            throw 1;
        }
    } else {
        // Seek to filelength - 128, the desired position for the ID3V1 Tag struct 
        if (SetFilePointer(StreamHandle,-128, 0, FILE_END) == 0xFFFFFFFF) {
            ID3TagSupported=false;
        } else 
        if (!ReadFile(StreamHandle, buf, 127, (DWORD*) &numread, NULL) || (numread != 127))  {
            free(buf);
            throw 1;
        }
    }    
    // Cast the buf to a ID3Tag structure 
    ID3=(ID3TagStruct *)buf;
    // Check for "TAG" at the beginning,validating the tag
    if (ID3->TagHeader[0]==84&&ID3->TagHeader[1]==65&&ID3->TagHeader[2]==71) ID3TagSupported=true; else ID3TagSupported=false;
    // Sets the file pointer back to file begin
    if (InputMode == imCallback) {
        if (!Args->InSeekCB(Args->InCBData1, Args->InCBData2, 0, FILE_BEGIN)) {
            free(buf);
            throw 1;
        }
    } else {
        // Seek to filelength - 128, the desired position for the ID3V1 Tag struct 
        if (SetFilePointer(StreamHandle, 0, 0, FILE_BEGIN) == 0xFFFFFFFF) {
            free(buf);
            throw 1;
        }
    }    
    // Global initializations
    ibufnum=0;fsize=0,fsizeold=0;bsnum=0;oldhead=0;firsthead=0;
    StreamInit = true;    
    return true;
}

/*
int BackFrame(int num)
{
    long bytes;
    long numread=1;
    unsigned char buf[4];
    unsigned long newhead;
    if(!firsthead)      return 0;
    bytes=(fsize+8)*(num+2);
    
    

    if(SetFilePointer(StreamHandle,-bytes,NULL,FILE_CURRENT)<0) return 0;
    
    bool Res=ReadFile(StreamHandle,buf,4,(DWORD*)&numread,NULL);
    if(!Res||numread!=4) return 0;
    newhead=(buf[0]<<24)+(buf[1]<<16)+(buf[2]<<8)+buf[3];
    while((newhead&HDRCMPMASK)!=(firsthead&HDRCMPMASK)) 
    {
        Res=ReadFile(StreamHandle,buf,1,(DWORD*)&numread,NULL);
        if(!Res||numread!=1) return 0;
        newhead<<=8;
        newhead|=buf[0];
        newhead&=0xffffffff;
    }
    if(SetFilePointer(StreamHandle,-4,NULL,FILE_CURRENT)<0) return 0;
    ReadFrame();
    ReadFrame();
    if(fr.lay==3) SetPointer(512);
    return 0;
}
*/
int head_read(unsigned char *hbuf,unsigned long *newhead)
{
    long numread;
    bool res;
    if (InputMode == imCallback) 
        res = Args->InReadCB (Args->InCBData1, Args->InCBData2, hbuf, 4, (DWORD *)&numread);
    else 
        res=ReadFile(StreamHandle, hbuf, 4, (DWORD *)&numread, NULL);
    
    if(!res||numread!=4) return FALSE;
    *newhead=((unsigned long) hbuf[0] << 24) |
        ((unsigned long) hbuf[1] << 16) |
        ((unsigned long) hbuf[2] << 8)  |
        (unsigned long) hbuf[3];
    return TRUE;
}

int head_check(unsigned long newhead) 
{
    if((newhead&0xffe00000)!=0xffe00000) return FALSE;
    if(!((newhead>>17)&3))      return FALSE;
    if(((newhead>>12)&0xf)==0xf) return FALSE;
    if(((newhead>>10)&0x3)==0x3) return FALSE;
    return TRUE;
}

int ReadFrame()
{
    static unsigned char ssave[34];
    static int halfphase = 0;
    int l;long temp,numread=0;
    int tryme = 0;
    unsigned char hbuf[8];
    static unsigned long newhead;
    bool Res;

read_again:
    int tmpsize=4;
    if(!head_read(hbuf,&newhead)) {
        LastError = peInputError;
        throw 1;
    }
    if(oldhead!=newhead||!oldhead)
    {
        fr.header_change = 1;
init_resync:
        if(!firsthead&&!head_check(newhead)) {
            int i;
            if(newhead==('R'<<24)+('I'<<16)+('F'<<8)+'F')
            {
                char buf[68];
                
                if (InputMode ==imCallback) 
                    Res = Args->InReadCB (Args->InCBData1, Args->InCBData2, buf, 68, (DWORD*) &numread);
                else 
                    Res = ReadFile(StreamHandle, buf, 68, (DWORD*) &numread, NULL);

                if(Res&&numread==0) return -2;
                if(!Res||numread!=68) throw 1;
                goto read_again;
            }
            for(i=0;i<512;i++) 
            {
                if(!head_read(hbuf,&newhead)) throw 1;
                if(head_check(newhead)) break;
            }
            if(i==512) 
            {
                for(i=0;i<2048;i++) 
                {
                    memmove(&hbuf[0],&hbuf[1],3);
                    
                    if (InputMode ==imCallback) 
                        Res = Args->InReadCB (Args->InCBData1, Args->InCBData2, hbuf+3, 1, (DWORD*) &numread);
                    else 
                        Res = ReadFile(StreamHandle, hbuf+3, 1, (DWORD*) &numread, NULL);
                    
                    if(Res&&numread==0) return -2;
                    if(!Res||numread!=1) throw 1;
                    newhead<<=8;
                    newhead|=hbuf[3];
                    newhead&=0xffffffff;
                    if(head_check(newhead)) break;
                }
                if(i==2048) return FALSE; 
            }
        }
        if((newhead&0xffe00000)!=0xffe00000) 
        {
            if(Args->TryResync) 
            {
                do 
                {
                    tryme++;
                    memmove(&hbuf[0],&hbuf[1],7);
                    
                    if (InputMode ==imCallback) 
                        Res = Args->InReadCB (Args->InCBData1, Args->InCBData2, &hbuf[3], 1, (DWORD*) &numread);
                    else 
                        Res = ReadFile(StreamHandle, &hbuf[3], 1, (DWORD*) &numread, NULL);

                    if(Res&&numread==0) return -2;
                    if(!Res||numread!=1) throw 1;
                    newhead=((newhead<<8)|hbuf[3])&0xffffffff;
                    if(!oldhead) goto init_resync;
                } while((newhead&HDRCMPMASK)!=(oldhead&HDRCMPMASK)&&(newhead&HDRCMPMASK)!=(firsthead&HDRCMPMASK));
            } else return (0);
        }
        if(!firsthead) firsthead=newhead;
        if(newhead&(1<<20)) 
        {
            fr.lsf=(newhead&(1<<19))?0x0:0x1;
            fr.mpeg25 = 0;
        } else 
        {
            fr.lsf = 1;
            fr.mpeg25 = 1;
        }
        if(!Args->TryResync||!oldhead) 
        {
            fr.lay = 4-((newhead>>17)&3);
            fr.bitrate_index = ((newhead>>12)&0xf);
            if(((newhead>>10)&0x3)==0x3) {
                throw 1;
            }
            if(fr.mpeg25) fr.sampling_frequency=6+((newhead>>10)&0x3);
            else fr.sampling_frequency=((newhead>>10)&0x3)+(fr.lsf*3);
            fr.error_protection=((newhead>>16)&0x1)^0x1;
        }
        if(fr.mpeg25) fr.bitrate_index = ((newhead>>12)&0xf);
        fr.padding   = ((newhead>>9)&0x1);
        fr.extension = ((newhead>>8)&0x1);
        fr.mode      = ((newhead>>6)&0x3);
        fr.mode_ext  = ((newhead>>4)&0x3);
        fr.copyright = ((newhead>>3)&0x1);
        fr.original  = ((newhead>>2)&0x1);
        fr.emphasis  = newhead & 0x3;
        fr.stereo    = (fr.mode == MPG_MD_MONO) ? 1 : 2;
        if(FreqIndex[fr.sampling_frequency]>44100) fr.sampling_frequency=0;
        oldhead = newhead;
        if(!fr.bitrate_index)
        {
            // No free format allowed ;)
            throw 1;
        }
        switch(fr.lay)
        {
        case 1:
            fr.WhatLayer=1; 
            fr.jsbound=(fr.mode==MPG_MD_JOINT_STEREO)?(fr.mode_ext<<2)+4:32;
            framesize=(long)BitRateIndex[fr.lsf][0][fr.bitrate_index]*12000;
            framesize/=FreqIndex[fr.sampling_frequency];
            framesize=((framesize+fr.padding)<<2)-4;
            break;
        case 2:
            fr.WhatLayer=2; 
            GetLayer2();
            fr.jsbound=(fr.mode==MPG_MD_JOINT_STEREO)?(fr.mode_ext<<2)+4:fr.II_sblimit;
            framesize=(long)BitRateIndex[fr.lsf][1][fr.bitrate_index]*144000;
            framesize/=FreqIndex[fr.sampling_frequency];
            framesize+=fr.padding - 4;
            break;
        case 3:
            fr.WhatLayer=3; 
            if(fr.lsf) ssize=(fr.stereo==1)?9:17;
            else ssize=(fr.stereo==1)?17:32;
            if(fr.error_protection) ssize += 2;
            framesize=(long)BitRateIndex[fr.lsf][2][fr.bitrate_index] * 144000;
            framesize/=FreqIndex[fr.sampling_frequency]<<(fr.lsf);
            framesize=framesize + fr.padding - 4;
            break; 
        default:
            throw 1;            
        }
    } else fr.header_change=0;
    fsizeold=fsize;
    bsbufold=bsbuf;        
    bsbuf=bsspace[bsnum]+512;
    bsnum=(bsnum+1)&1;
    fsize=framesize;

    if (InputMode ==imCallback) 
        Res = Args->InReadCB (Args->InCBData1, Args->InCBData2, bsbuf,fsize, (DWORD*) &numread);
    else 
        Res = ReadFile(StreamHandle, bsbuf,fsize, (DWORD*) &numread, NULL);
    
    if(Res&&numread==0) return -2;
    if(!Res||numread!=fsize) {
        memset(bsbuf+numread,0,fsize-numread);
    } 
    bitindex=0;
    wordpointer=(unsigned char *)bsbuf;
    MaxFrames = GetMaxFrames();
    MinFrames = GetMinFrames();
    return 1;
}

ID3TagStruct* GetID3Tag()
{
    if(ID3TagSupported)
    { 
        ID3->Title[29]=0;ID3->Album[29]=0;ID3->Artist[29]=0;ID3->Comment[29]=0;ID3->Year[4]=0;   
        return(ID3);
    }
    return NULL;
}

// Return stream bitrate
unsigned long GetBitrate()
{
    return BitRateIndex[fr.lsf][fr.lay-1][fr.bitrate_index]*1000;
}

// Return stream samplerate
unsigned long GetSampleRate()
{
    return(FreqIndex[fr.sampling_frequency]);
}

// Get the minimum count of frames in the stream
unsigned long GetMinFrames()
{
    return(StreamSize/(CalcFramesize()+4-fr.padding));
}

// Get the maximum count of frames in the stream
unsigned long GetMaxFrames()
{
    return(StreamSize/(CalcFramesize()+5-fr.padding));
}

// Return framesize
unsigned long CalcFramesize()
{
    return framesize;
}

// Returns the milli seconds one frame has
real Frame2ms()
{
    static real ms_per_frame_array[3][3]={{8.707483f,8.0f,12.0f},{26.12245f,24.0f,36.0f},{26.12245f,24.0f, 36.0f}};
    return(ms_per_frame_array[1][fr.sampling_frequency]);
}

real Totalms()
{
    return(GetMaxFrames()*Frame2ms());
}

unsigned long Currentms()
{
    return(Args->CurrentPos*Frame2ms());
}

bool Seek_Stream(unsigned long Position)
{
    unsigned long Posi = Position/Frame2ms();
    if(Posi>0&&Posi<GetMaxFrames()){

        if (InputMode == imCallback) {
            if (!Args->InSeekCB(Args->InCBData1, Args->InCBData2, CalcFramesize()*Posi, FILE_BEGIN)) {
                return false;
            }
        } else {
            if (SetFilePointer(StreamHandle, CalcFramesize()*Posi, 0, FILE_BEGIN) == 0xFFFFFFFF) 
                return false;
        }

        SetFilePointer(StreamHandle,CalcFramesize()*Posi,0,FILE_BEGIN);
        Args->CurrentPos=Posi;
read_again: 
        int Res = ReadFrame();
        if(Res) Args->CurrentPos++; 
        if(!Res&&Res!=-2) goto read_again;
        return true; 
    }
    return false;
}

void Reset_Stream()
{
    if (InputMode ==imCallback) {
        if (!Args->InSeekCB(Args->InCBData1, Args->InCBData2, 0, FILE_BEGIN)) {
            return;
        }
    } else {
        if (SetFilePointer(StreamHandle, 0, 0, FILE_BEGIN) == 0xFFFFFFFF) 
            return;
    }
    Args->CurrentPos=0;
}

#if !defined(I386_ASSEM)
unsigned long GetBits(int number_of_bits)
{
    unsigned long rval;
    if(!number_of_bits) return 0;
    {
        rval = wordpointer[0];
        rval <<= 8;
        rval |= wordpointer[1];
        rval <<= 8;
        rval |= wordpointer[2];
        rval <<= bitindex;
        rval &= 0xffffff;
        bitindex += number_of_bits;
        rval >>= (24-number_of_bits);
        wordpointer += (bitindex>>3);
        bitindex &= 7;
    }
    return rval;
}

unsigned long GetBitsFast(int number_of_bits)
{
    unsigned long rval;
    {
        rval = wordpointer[0];
        rval <<= 8;     
        rval |= wordpointer[1];
        rval <<= bitindex;
        rval &= 0xffff;
        bitindex += number_of_bits;
        rval >>= (16-number_of_bits);
        wordpointer += (bitindex>>3);
        bitindex &= 7;
    }
    return rval;
}

unsigned long Get1Bit(void)
{
    unsigned char rval;
    rval = *wordpointer << bitindex;
    bitindex++;
    wordpointer += (bitindex>>3);
    bitindex &= 7;
    return rval>>7;
}
#endif

void SetPointer(long backstep)
{
    wordpointer=bsbuf+ssize-backstep;
    if(backstep) memcpy(wordpointer,bsbufold+fsizeold-backstep,backstep);
    bitindex=0; 
}

bool Done_Stream(){
    if(StreamOpen) CloseHandle(StreamHandle);
    StreamInit = false;
    return true;
}
