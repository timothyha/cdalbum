#include "args.h"
#include "player.h"
#include "helper.h"
#include "audio.h"
#include <stdio.h>
#include "..\SDK\include\wmaudiosdk.h"

MPArgs *Args;
esPlayerError LastError;

void HardAudioReset(MPPlayer *ptr){
    if(ptr !=NULL) {
        try {
            Done_MPAudio();
        }
        catch(...) {}
        try {
            Init_MPAudio();
        }
        catch(...) {
            LastError = peOutputError;            
            throw 1;            
            return;
        }
    }
}
/*
unsigned long __stdcall PlayThread(void *ptr) {
    
    long FreqIndex[7]={44100,48000,32000,22050,24000,16000,11025};
    int clip;
    
    long OldRate = 0, NewRate = 0;
    int OldBits = 0, OldChannel = 0;
    //unsigned long left,right;
    unsigned long FrameNum = 0;
    long OldScaleFactor = 32768;
    MPPlayer *Player = (MPPlayer *)ptr;    
    try {
        while(numframes) {
          once_more:  
            BOOL Res = ReadFrame();
            if(Res) Args->CurrentPos++;
            if(Args->CurrentPos >= MaxFrames) 
                break; 
            if (Args->CurrentPos < Args->StartFrame) {
                if(fr.lay == 3) SetPointer(512);
                continue;
            }
            if(Args->CurrentPos > Args->EndFrame) 
                break; 
            if(!Res && Res !=-2) goto once_more;            
            numframes--;
            if(OldScaleFactor != Args->ScaleFactor) {
                make_decode_tables(Args->ScaleFactor);
                OldScaleFactor = Args->ScaleFactor;
            }
            if(fr.header_change){
                int reset_audio=0;
                if(Args->ForceFreq < 0) {
                    if(Args->SampleRate != FreqIndex[fr.sampling_frequency>>(fr.down_sample)]) {
                        Args->SampleRate = FreqIndex[fr.sampling_frequency>>(fr.down_sample)];
                            reset_audio=1;
                    }
                } else 
                if(Args->SampleRate != Args->ForceFreq) {
                    Args->SampleRate = Args->ForceFreq;
                    reset_audio=1;
                }
                if(reset_audio) {
                    HardAudioReset(Player);
                }
                fr.header_change = 0;
            } 
            if(fr.error_protection) GetBits(16);
            if(fr.WhatLayer==3) clip=do_layer3(); else
            if(fr.WhatLayer==2) clip=do_layer2(); else 
            if(fr.WhatLayer==1) clip=do_layer1();
            if (Player->PauseFlag) {
                Player->ThreadSync = 1;  
                while(Player->PauseFlag){
                    Sleep(77);
                    if (Player->UserBreak) break;
                }
            } 
            if(Player->UserBreak) break;
        }
    } catch (...) {
    }
    Player->EndOfTune = false;
    if(!Player->UserBreak){
        try { FinishBuffer(); } catch (...) {}
        Player->EndOfTune = true;
        Player->FPlayerMode = pmStopped;
    }
    else
    {
        Player->FPlayerMode = pmOpened;
    }
    Reset_Stream(); 
    Done_MPAudio();
    Player->UserBreak=0; 
    return 0;
}
*/
MPPlayer::~MPPlayer() {
    if (PlayerMode() > pmClosed) Close();
    if( m_pReader != NULL )
    {
        m_pReader->Release();
        m_pReader = NULL;
    }
    if (Args) delete Args;
}

MPPlayer::MPPlayer() {
    ModuleTag = 0x14581458;
    m_pReader = NULL;
    Args = new MPArgs();
    if (!Args) throw 1;
    Args->InputMode=imFile;
    Args->OutputMode=omMMSystem;  
    EndOfTune = false;
    FPlayerMode = pmClosed;
    UserBreak = false;
    LastError = peNoError;
    m_cRef = 1;
    /*equalizer_cnt=0;
    for(int i=0; i<32; i++) {
        equalizer[0][i]=equalizer[1][i]=1.0;
        equalizer_sum[0][i]=equalizer_sum[1][i]=0.0;
    }*/
};


HRESULT STDMETHODCALLTYPE MPPlayer::QueryInterface(
    REFIID riid,
    void **ppvObject )
{
    return( E_NOINTERFACE );
}


///////////////////////////////////////////////////////////////////////////////
ULONG STDMETHODCALLTYPE MPPlayer::AddRef()
{
    return( InterlockedIncrement( &m_cRef ) );
}


///////////////////////////////////////////////////////////////////////////////
ULONG STDMETHODCALLTYPE MPPlayer::Release()
{
    ULONG uRet = InterlockedDecrement( &m_cRef );

    if( 0 == uRet )
    {
        delete this;
    }

    return( uRet );
}


///////////////////////////////////////////////////////////////////////////////
HRESULT STDMETHODCALLTYPE MPPlayer::OnSample( 
        /* [in] */ const BYTE *pData,
        /* [in] */ DWORD cbData,
        /* [in] */ DWORD dwMsTime )
{
    try 
    {
        int i; 
        Args->BufferSize = cbData;  
        i = cbData * 1000 / (Args->Channels * Args->SampleRate * Args->AudioBits / 8);
        Args->Position += i;
        //Args->Position += dwMsTime;
        if (Player->PauseFlag) 
        {
            while(Player->PauseFlag)
            {
                Sleep(77);
                if (Player->UserBreak) break;
            }
        } 
        if (Args->Position > Args->EndPos)
        {
            m_pReader->Stop();
            try 
            {
                FinishBuffer();
            }
            catch (...) {}
            Done_MPAudio();
            FPlayerMode = pmStopped;
            return S_OK;
        }
        PlaySamples((unsigned char *) pData, cbData);
        return S_OK;
    }
    catch ( ... ) 
    {
        return E_FAIL;
    }    
}

esPlayerError MPPlayer::ESGetLastError() {
    esPlayerError res = LastError;
    LastError = peNoError;
    return res;
}

bool MPPlayer::SetInName (char *FileName){
    if (PlayerMode() != pmClosed) {
        LastError = peIncorrectMode;
        return false;
    }  
    if (Args->InName) free(Args->InName);
    Args->InName = xstrdup(FileName);
    return true;
}

bool MPPlayer::SetOutName(char *FileName){
    if (PlayerMode() >= pmPlaying) {
        LastError = peIncorrectMode;
        return false;
    }  
    if (Args->OutName) free(Args->OutName);
    Args->OutName = xstrdup(FileName);
    return true;
}

bool MPPlayer::SetInMode (esInputMode InMode){
    if (PlayerMode() > pmClosed) {
        LastError = peIncorrectMode;
        return false;
    }
    Args->InputMode = InMode;
    return true;
}

bool MPPlayer::SetOutMode(esOutputMode OutMode){
    if (PlayerMode() >= pmPlaying) {
        LastError = peIncorrectMode;
        return false;
    }
#ifndef _DIRECTX
    if (OutMode == omDirectSound) {
        LastError = peNotImplemented;
        return false;
    }
#endif
    Args->OutputMode = OutMode;
    return true;
}

HRESULT STDMETHODCALLTYPE MPPlayer::OnStatus( 
        /* [in] */ WMT_STATUS Status, 
        /* [in] */ HRESULT hr,
        /* [in] */ const VARIANT *pParam )
{
    switch( Status )
    {
    case WMT_NO_RIGHTS:
    case WMT_MISSING_CODEC:
    case WMT_ERROR:
        LastError = peInternalError;
        m_pReader->Stop();
        try 
        {
            FinishBuffer();
        }
        catch (...) 
        {
        }
        Done_MPAudio();
        FPlayerMode = pmOpened;
        break;

    case WMT_BUFFERING_START:
        break;

    case WMT_BUFFERING_STOP:
        break;

    case WMT_EOF:
        try 
        {
            FinishBuffer();
        }
        catch (...) 
        {
        }
        m_pReader->Stop();        
        Done_MPAudio();
        FPlayerMode = pmStopped;
        break;

    case WMT_LOCATING:
        break;

    case WMT_CONNECTING:
        break;
    };

    return( S_OK );
}

bool MPPlayer::Open()
{
    ZeroMemory(&StreamInfo, sizeof TextInfo);
    if ((PlayerMode() != pmClosed) || ((Args->InputMode == imFile) && (!Args->InName))) {
        if (PlayerMode() != pmClosed) 
            LastError = peIncorrectMode; 
        else 
            LastError = peInputError;
        return false;
    }
    PauseFlag = 0;
    Args->Position = 0;
    WCHAR szUrl[1024];
    try 
    {
        if( 0 == MultiByteToWideChar( CP_ACP, 0, Args->InName, strlen(Args->InName) + 1, szUrl, 1024 ) )
        {
            LastError = peInternalError;
            return false;
        }
        if (FAILED(WMAudioCreateReader(szUrl, this, &m_pReader, NULL))) 
        {
            LastError = peInputError;
            return false;
        }
    } catch (...) {
        LastError = peInputError;
        return false;
    }
    FPlayerMode = pmOpened;
    return true;
}

bool MPPlayer::InitStream(){
    if (PlayerMode() != pmOpened) {
        LastError = peIncorrectMode;
        return false;
    }
    
    WORD i, AttrCount;

    hr = m_pReader->GetAttributeCount(&AttrCount);
    if (hr != S_OK) 
    {
        LastError = peInputError;
        return false;
    }

    Args->SampleRate = 0;

    WCHAR  wName[512];
    WORD cbNamelen;
    WMT_ATTR_DATATYPE type;
    BYTE pValue[512];
    WORD cbLength;
    char buff[512];
        
    for (i = 0; i < AttrCount; i++) 
    {   
        cbNamelen = sizeof ( wName );
        cbLength = sizeof( pValue );

        hr = m_pReader->GetAttributeByIndex(i, wName, &cbNamelen, &type, pValue, &cbLength );
        if (FAILED(hr)) 
        {
            if ( hr == E_NOTIMPL )
            {
                continue;
            }
            LastError = peInputError;
            return false;
        }
        switch ( type )
        {
        case WMT_TYPE_DWORD:
            if (wcscmp(wName, g_wszWMADuration) == 0) 
            {
                Args->SLength = *((DWORD *) pValue);
            }
            if (wcscmp(wName, g_wszWMABitrate) == 0) 
            {
                Args->bitrate = *((DWORD *) pValue);
            }

            break;
        case WMT_TYPE_STRING:
            if( 0 == WideCharToMultiByte( CP_ACP, 0, (WCHAR *)pValue, -1, buff, 511, NULL, NULL ) )
            {
                continue;
            }
            if (wcscmp(wName, g_wszWMAAlbumTitle) == 0)    
            {
                strcpy(StreamInfo.Album, buff);
            }
            if (wcscmp(wName, g_wszWMATitle) == 0)    
            {
                strcpy(StreamInfo.Title, buff);
            }
            if (wcscmp(wName, g_wszWMAAuthor) == 0)    
            {
                strcpy(StreamInfo.Artist, buff);
            }
            if (wcscmp(wName, g_wszWMACopyright) == 0)    
            {
                strcpy(StreamInfo.Copyright, buff);
            }
            if (wcscmp(wName, g_wszWMADescription) == 0)    
            {
                strcpy(StreamInfo.Comment, buff);
            }
            if (wcscmp(wName, g_wszWMAGenre) == 0)    
            {
                strcpy(StreamInfo.Genre, buff);
            }
            if (wcscmp(wName, L"WM/Year") == 0)    
            {
                strcpy(StreamInfo.Year, buff);
            }            
            break;
        case WMT_TYPE_BOOL:
            if (wcscmp(wName, g_wszWMASeekable) == 0) 
            {
                Args->Seekable = *((BOOL *) pValue);
            }
            break;
        default:
            break;
        }
    } // for
    Args->Position = 0;
    
    WAVEFORMATEX waveFmt;
    hr = m_pReader->GetOutputFormat(&waveFmt, sizeof waveFmt);
    if (hr != S_OK) 
    {
        LastError = peInputError;
        return false;
    }
    Args->Channels = waveFmt.nChannels;
    Args->SampleRate = waveFmt.nSamplesPerSec;
    Args->AudioBits = waveFmt.wBitsPerSample;
    

    FPlayerMode = pmReady;
    return true;
}

bool MPPlayer::Play() {
    if (PlayerMode() != pmReady) {
        LastError = peIncorrectMode;
        return false;
    }
    if ((Args->OutputMode == omCallback) && ((!Args->BufferCB) || (!Args->OutActionCB))) {
        LastError = peNoCallback;
        return false;
    }
    try {
        Init_MPAudio();
    }
    catch(...){        
        return false;
    }    
    if (Args->EndPos == 0) SetLimits(Args->StartPos, Args->EndPos);
    hr = m_pReader->Seek(Args->StartPos);
    if (hr == S_OK) 
    {
        Args->Position = Args->StartPos;
    } 
    else 
    {
        hr = m_pReader->Seek(0);
        if (hr != S_OK) 
        {
            LastError = peInputError;
            return false;
        }    
        Args->Position = 0;
    }
    hr = m_pReader->Start();
    if (hr != S_OK) 
    {
        LastError = peInputError;
        return false;
    }    
    FPlayerMode = pmPlaying;
    return true;    
}

bool MPPlayer::Pause(){
    if ((PlayerMode() == pmPlaying) || (PlayerMode() == pmPaused)) {
        PauseFlag = true;
        FPlayerMode = pmPaused;
        return true;
    } else {
        LastError = peIncorrectMode;
        return false;
    }
}

bool MPPlayer::Resume(){
    if ((PlayerMode() == pmPlaying) || (PlayerMode() == pmPaused)) {
        PauseFlag = false;   
        FPlayerMode = pmPlaying;
        return true;
    } else {
        LastError = peIncorrectMode;
        return false;
    }
}

bool MPPlayer::Stop(){
    if ((PlayerMode() == pmPlaying) || (PlayerMode() == pmPaused)) {
        UserBreak = 1;
        m_pReader->Stop();
        Done_MPAudio();
        UserBreak = 0;
        FPlayerMode = pmOpened;
        return true;
    } 
    if (PlayerMode() == pmStopped) 
    {
        FPlayerMode = pmOpened;             
        return true;
    } 
    else 
    {
        LastError = peIncorrectMode;
        return false;
    }
}

bool MPPlayer::Close(){
    if ((PlayerMode() == pmPlaying) || (PlayerMode() == pmPaused)) Stop();
    if (m_pReader) {
        m_pReader->Release();
        m_pReader = NULL;
    }    
    FPlayerMode = pmClosed;
    return true;
}

unsigned long MPPlayer::GetSize(){
    if (PlayerMode() > pmOpened) {
        return Args->SLength;
    } else {
        LastError = peIncorrectMode;
        return -1;
    }
}

unsigned long MPPlayer::GetPos(){
    if (PlayerMode() >= pmStopped) {
        if (PlayerMode() == pmStopped) {
            return Args->SLength;
        }
        return Args->Position;
    } else {
        LastError = peIncorrectMode;
        return -1;
    }
}

bool MPPlayer::CanSetPos() {
    if (PlayerMode() >= pmOpened) {
        return Args->Seekable;
    } else {
        LastError = peIncorrectMode;
        return false;
    }
}

bool MPPlayer::SetPos(unsigned long NewPos){
    if ((PlayerMode() == pmPlaying) || (PlayerMode() == pmPaused)) {
        MPAudioEvents[2] = 1;
        if (Args->OutputMode != omDirectSound) 
            FinishBuffer();
        MPAudioEvents[2] = 0;
        m_pReader->Stop();
        hr = m_pReader->Seek(NewPos);
        m_pReader->Start();        
        if (hr == S_OK) 
        {
            Args->Position = NewPos;
        }
        return true;
    } else {
        LastError = peIncorrectMode;
        return false;
    }
}

bool MPPlayer::SetAudioBuffers(unsigned long buffers, unsigned long size){
    if (PlayerMode() >= pmPlaying) {
        LastError = peIncorrectMode;
        return false;        
    } else {
        if (buffers) Args->Buffers = buffers;
        if (size) Args->BufferSize = size;
    }
    return true;
}

bool MPPlayer::SetOutputDevice(unsigned long DevNum) {
    if (PlayerMode() != pmClosed) {
        LastError = peIncorrectMode;
        return false;        
    } else {
        Args->AudioDevice = DevNum;
        return true;
    }
}

bool MPPlayer::SetLimits(unsigned long StartPos, unsigned long EndPos) {
    Args->StartPos = StartPos;
    EndPos < StartPos ? Args->EndPos = StartPos : Args->EndPos = EndPos;
    if (PlayerMode() >= pmReady) {
        if (Args->EndPos == 0) {
            Args->EndPos = 0xFFFFFFFF; 
        }
    } 
    return true;
}

esPlayerMode MPPlayer::PlayerMode() {
    //esPlayerMode mode = FPlayerMode;
    //if (mode == pmStopped) FPlayerMode = pmOpened;
    return FPlayerMode;
}

bool MPPlayer::SetInCB(InFileOpenCB openCB, InFileCloseCB closeCB, InFileGetSizeCB getsizeCB,
             InFileSeekCB seekCB, InFileReadCB readCB, unsigned long UserData1) {
    if (PlayerMode() != pmClosed) {
        LastError = peIncorrectMode;
        return false;
    }
    Args->InOpenCB = openCB;
    Args->InCloseCB = closeCB;
    Args->InGetSizeCB = getsizeCB;
    Args->InSeekCB = seekCB;
    Args->InReadCB = readCB;
    Args->InCBData1 = UserData1;
    return true;
}

bool MPPlayer::SetOutCB(WaveOutCB OutCB, WaveOutActionCB OutActionCB, unsigned long UserData) {
    if (PlayerMode() >= pmPlaying) {
        LastError = peIncorrectMode;
        return false;
    } else {
        Args->BufferCB = (WaveOutCB) OutCB;
        Args->OutActionCB = (WaveOutActionCB) OutActionCB;
        Args->OutCBData = UserData;
        return true;
    }
}

bool MPPlayer::CanSetVolume(bool *Separate) {
    return Audio_CanSetVolume(Separate);    
}

bool MPPlayer::SetVolume(unsigned long Volume) {
    return Audio_SetVolume(Volume);
}

bool MPPlayer::GetVolume(unsigned long *Volume){
    return Audio_GetVolume(Volume);    
}

bool MPPlayer::SetDevNum(unsigned long DevNum) {
    if (PlayerMode() >= pmPlaying) {
        LastError = peIncorrectMode;
        return false;
    } else {
        Args->AudioDevice = DevNum;
        return true;
    }
}

bool MPPlayer::SetWindow(HWND Wnd) {
    if (PlayerMode() >= pmPlaying) {
        LastError = peIncorrectMode;
        return false;
    } else {
        Args->wnd = Wnd;
        return true;
    }
}

bool MPPlayer::UseOutCB(bool UseCB) {
    if (PlayerMode() >= pmPlaying) {
        LastError = peIncorrectMode;
        return false;
    } else {
        Args->UseHdrCB = UseCB;
        return true;
    }
}