#ifndef ARGS_H
#define ARGS_H

#include "common.h"
#include "..\ESP\ElSound.h"
#include <windows.h>

class MPArgs {
public:
    unsigned long CurrentPos;   // Current player position in frames
    unsigned long StartPos, EndPos;
    unsigned long SampleRate;   // Samplerate - samples per second
    unsigned long BufferSize;   // The size of the output buffer
    unsigned long Buffers;      // The number of buffers 
    long Channels;              // Channels(1=mono;2=stereo)
    long AudioBits;             // Bits per sample(ex. 16 bit)
    long Format;                // ex. PCM_FORMAT
    long AudioDevice;           // The audio device number which should be opened
    long AudioMode;             // Audio type(ex. 16bit signed),currently not used  
    long ForceFreq;             // Force frequency?
    bool BufferedInput;         // Not used
    bool Seekable;              // Is the stream seekable?
    bool UseHdrCB;              // Use output header callback
    char *InName;               // Input stream filename 
    char *OutName;              // Output filename for wave output
    long OutDeviceNum;          // Device number for MMSystem output
    long ForceMono;             // Force mono output?
    long Force8bit;             // Force 8-Bit output?
    long ForceStereo;           // Force stereo output? 
    long DownSample;            // Downsample Modes
    long UseEqualizer;          // Activate equalizer? 
    long PlayPriority;          // Play thread priority
    void *Player;
    void *Decoder;
    esInputMode  InputMode;    
    esOutputMode OutputMode;
    WaveOutCB BufferCB;
    WaveOutActionCB OutActionCB;
    InFileOpenCB InOpenCB;
    InFileCloseCB InCloseCB;
    InFileGetSizeCB InGetSizeCB;
    InFileSeekCB InSeekCB;
    InFileReadCB InReadCB;

    // user-defined data for output callbacks
    unsigned long OutCBData;
    
    // user-defined data for input callbacks
    unsigned long InCBData1;
    unsigned long InCBData2;

    HWND wnd;

    MPArgs() {
        InName = NULL;
        OutName= NULL;
        OutDeviceNum = 0;
        BufferedInput = true;
        CurrentPos = 0;
        StartPos = 0;
        EndPos = 0;
        // No downsampling
        DownSample = 0;
        // Force Stereo output
        ForceStereo = 0;
        Format = 1;
        AudioBits = 16;
        SampleRate = 44100;
        Channels = 2;
        AudioMode = 1;
        AudioDevice = 0;
        BufferSize = 16384;
        Buffers = 8;
        BufferCB    = NULL;
        UseHdrCB    = false;
        Seekable    = true;
        Force8bit   = 0;
        ForceFreq   = -1;
        ForceMono   = 0;
        UseEqualizer= false;
        PlayPriority= THREAD_PRIORITY_NORMAL;
        OutCBData   = 0;
        InCBData1   = 0;
        InCBData2   = 0; 
        OutActionCB = NULL;
        BufferCB    = NULL;
        wnd         = 0;
    }

    ~MPArgs() {
        if (InName) free(InName);
        if (OutName) free(OutName);
    }
};

typedef int (*synthProc)(real *, int, unsigned char *, int *);
typedef int (*synth_monoProc)(real *, unsigned char *, int *);

struct MPInfo {
    long stereo;
    long frequency;
    long bitspersample;
};

extern MPArgs *Args;

#endif
