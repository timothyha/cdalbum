#include "common.h"
#include <io.h>
#include <fcntl.h>
#include "stream.h"
#include "args.h"
#include "player.h"

unsigned char bsspace[2][MAXFRAMESIZE+512],*bsbuf=bsspace[1],*bsbufold;
static HGLOBAL MBHnd;
static char *MappedBuffer = NULL;
static DWORD MappedPointer = 0;
static int framesize;

int bitindex;
unsigned char *wordpointer;
HANDLE StreamHandle;
unsigned long StreamSize;
int ibufnum, fsize, fsizeold, ssize, bsnum;
unsigned long oldhead,firsthead, MinFrames, MaxFrames;
esInputMode InputMode;

bool StreamInit = false;

bool Init_Stream(){
    StreamSize = 0; 
    char *buf = (char *)malloc(128);
    SECURITY_ATTRIBUTES Sec;
    // Set the security attributes 
    Sec.nLength = sizeof(SECURITY_ATTRIBUTES);
    Sec.lpSecurityDescriptor = false;
    Sec.bInheritHandle = false;
    // Open the stream using CreateFile
    InputMode = Args->InputMode;    
    if (InputMode == imCallback) 
    {
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
        StreamHandle = CreateFile(Args->InName, GENERIC_READ, FILE_SHARE_READ, &Sec, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_RANDOM_ACCESS, NULL);
        if(StreamHandle == INVALID_HANDLE_VALUE) 
        { 
            free(buf); 
            throw 1;        
        };
        StreamSize = GetFileSize(StreamHandle, NULL);
    }

    // Set "stream is open" flag
    LONG XPosi = 0;
    
    // Global initializations
    ibufnum=0;fsize=0,fsizeold=0;bsnum=0;oldhead=0;firsthead=0;
    StreamInit = true;    
    return true;
}

bool Seek_Stream(unsigned long Position)
{
    unsigned long Posi = Position;
    unsigned long OldPosi, XPosi;
    
    if(Posi >= 0 && Posi <= Stream_GetSize())
    {
        XPosi =  Posi + 44;
            
        if (InputMode == imCallback) 
        {
            OldPosi = 0;
            Args->InSeekCB(Args->InCBData1, Args->InCBData2, (LPDWORD) &OldPosi, FILE_CURRENT) ;
            
            if (!Args->InSeekCB(Args->InCBData1, Args->InCBData2, (LPDWORD)&XPosi, FILE_BEGIN)) 
            {
                Args->InSeekCB(Args->InCBData1, Args->InCBData2, (LPDWORD)&OldPosi, FILE_BEGIN);
                return false;
            }
        } else 
        {
            OldPosi =  SetFilePointer(StreamHandle, 0, 0, FILE_CURRENT);
            if (SetFilePointer(StreamHandle, XPosi, 0, FILE_BEGIN) == 0xFFFFFFFF) 
            {
                SetFilePointer(StreamHandle, OldPosi, 0, FILE_BEGIN);
                return false;
            }
        }
        
        Args->CurrentPos = Stream_GetPosition() / Args->AudioBits * 8 /  Args->SampleRate / Args->Channels * 1000;
        return true; 
    }
    return false;
}

void Reset_Stream()
{
    LONG XPosi = 0;
    if (InputMode ==imCallback) {
        if (!Args->InSeekCB(Args->InCBData1, Args->InCBData2, (LPDWORD) &XPosi, FILE_BEGIN)) {
            return;
        }
    } else {                            
        if (SetFilePointer(StreamHandle, XPosi, 0, FILE_BEGIN) == 0xFFFFFFFF) 
            return;
    }
    Args->CurrentPos=0;
}

bool Done_Stream()
{
    if (InputMode == imCallback) 
    {
           if (StreamInit) Args->InCloseCB(Args->InCBData1, Args->InCBData2);
    }
    else 
    {
        if (StreamInit) CloseHandle(StreamHandle);
    }

    StreamInit = false;
    return true;
}

bool Stream_Read(void *p, unsigned long BytesToRead)
{
    unsigned long numread;
    if (Args->InputMode == imCallback) 
    {
        if (!Args->InReadCB (Args->InCBData1, Args->InCBData2, p, BytesToRead, (DWORD*) &numread) || (numread != BytesToRead)) 
        {
            return false;
        }
        return true;
    } 
    else 
    {
        if (!ReadFile(StreamHandle, p, BytesToRead, (DWORD*) &numread, NULL) || (numread != BytesToRead))  
        {
            return false;
        }
        return true;
    }    
}

long Stream_GetSize()
{
    unsigned long StreamSize = 0;
    InputMode = Args->InputMode;    
    if (Args->InputMode == imCallback) 
    {
        if (!Args->InGetSizeCB(Args->InCBData1, Args->InCBData2, &StreamSize)) 
        {
            throw 1;
        };
    } else 
    {
        StreamSize = GetFileSize(StreamHandle, NULL);
    }        
    return StreamSize;
}

extern long Stream_GetPosition()
{
    unsigned long FilePos = 0;
    if (Args->InputMode == imCallback) 
    {
        Args->InSeekCB(Args->InCBData1, Args->InCBData2, (LPDWORD) &FilePos, FILE_CURRENT) ;
    } else 
    {
        FilePos =  SetFilePointer(StreamHandle, 0, 0, FILE_CURRENT);
    }
    return FilePos;
}

typedef struct _RIFFHEADER
{
    ULONG RIFFSig;
    ULONG BytesInFile;
    ULONG WAVESig;
    ULONG FmtSig;
    ULONG Len;
    __int16 Style;
    __int16 Channels;
    ULONG Rate;
    ULONG AvgBps;
    __int16 Align;
    __int16 BitSize;
} RIFFHEADER, *LPRIFFHEADER;


typedef struct _RIFFDATAHEADER
{
    ULONG DataSig;
    ULONG Len;
} RIFFDATAHEADER, *LPRIFFDATAHEADER;

bool Stream_ReadHeader()
{
    bool res = false;
    RIFFHEADER RH;
    RIFFDATAHEADER RDH;
    if (Stream_Read(&RH, sizeof(RH)))
    {
        if (Stream_Read(&RDH, sizeof(RDH)))
        {
            res = true;
            Args->AudioBits = RH.BitSize;
            Args->Channels = RH.Channels;
            Args->SampleRate = RH.Rate;
            Args->Format = RH.Style;
            res = true;
        }
    }
    return res;
}