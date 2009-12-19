#ifndef PLAYER_H
#define PLAYER_H

#include "..\SDK\include\wmaudiosdk.h"
#include "..\..\ESP\ElSound.h"
#include "args.h"
#include "common.h"

// Header mask definition
#define HDRCMPMASK 0xfffffd00

// Maximum frame size
#define MAXFRAMESIZE 1792

#define MPG_MD_STEREO           0
#define MPG_MD_JOINT_STEREO     1
#define MPG_MD_DUAL_CHANNEL     2
#define MPG_MD_MONO             3

class MPPlayer;

extern MPPlayer *Player;

class MPPlayer :
    public IWMAudioReadCallback {

public:
    unsigned long ModuleTag;

    // IUnknown
public:
    virtual HRESULT STDMETHODCALLTYPE QueryInterface(
        REFIID riid,
        void **ppvObject );

    virtual ULONG STDMETHODCALLTYPE AddRef();
    virtual ULONG STDMETHODCALLTYPE Release();

    // IWMAudioReadCallback
public:
    virtual HRESULT STDMETHODCALLTYPE OnSample(
        /* [in] */ const BYTE * pData,
        /* [in] */ DWORD cbData,
        /* [in] */ DWORD dwMsTime
                        );

    virtual HRESULT STDMETHODCALLTYPE OnStatus(
        /* [in] */ WMT_STATUS Status,
        /* [in] */ HRESULT hr,
        /* [in] */ const VARIANT *pParam
                        );
    
public:
    esPlayerMode FPlayerMode;   
    IWMAudioReader *m_pReader;
    HRESULT hr;
    LONG    m_cRef;

    HANDLE StopEvent;
    bool PauseFlag;

    TextInfo StreamInfo;

    bool ThreadSync, UserBreak, EndOfTune;

    MPPlayer();
    ~MPPlayer();

    esPlayerError ESGetLastError();
    bool SetInName (char *FileName);
    bool SetOutName(char *FileName);
    bool SetInMode (esInputMode InMode);
    bool SetOutMode(esOutputMode OutMode);
    bool SetOutputDevice(unsigned long DevNum);
    bool Open();
    bool InitStream(); // initializes input stream record
    bool Play();
    bool Pause();
    bool Resume();
    bool Stop();
    bool Close();
    unsigned long GetPos();
    unsigned long GetSize();
    bool CanSetPos();
    bool SetPos(unsigned long NewPos);
    esPlayerMode PlayerMode();
    bool SetAudioBuffers(unsigned long buffers, unsigned long size);
    bool SetLimits(unsigned long buffers, unsigned long size);
    bool SetOutCB(WaveOutCB OutCB, WaveOutActionCB OutActionCB, unsigned long UserData);
    bool SetInCB(InFileOpenCB openCB, InFileCloseCB closeCB, InFileGetSizeCB getsizeCB,
                 InFileSeekCB seekCB, InFileReadCB readCB, unsigned long UserData1);
    bool CanSetVolume(bool *Separate); 
    bool SetVolume(unsigned long Volume);
    bool GetVolume(unsigned long *Volume);
    bool SetDevNum(unsigned long DevNum);
    bool SetWindow(HWND Wnd);
    bool UseOutCB(bool UseCB);
};

extern esPlayerError LastError;
extern DWORD OLEInit;

#endif