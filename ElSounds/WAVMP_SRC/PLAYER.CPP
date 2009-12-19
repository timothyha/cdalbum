#include "common.h"
#include "args.h"
#include "player.h"
#include "helper.h"
#include "stream.h"
#include "audio.h"
#include <stdio.h>

MPArgs *Args;
esPlayerError LastError = peNoError;
HANDLE ThreadQueueEvent = NULL;
HANDLE SeekEvent, SeekEvent2;
unsigned long NewSeekPosition;

int xxx = 0;

unsigned long __stdcall PlayThread(void *ptr) 
{
    
    MSG msg;
    PeekMessage(&msg, NULL, WM_USER, WM_USER, PM_NOREMOVE);
    try 
    {
        Init_MPAudio();
    }
    catch(...)
    {
        LastError = peOutputError;
        SetEvent(ThreadQueueEvent);
        return false;
    }
    SetEvent(ThreadQueueEvent);
    MPPlayer *Player = (MPPlayer *)ptr;    
    try 
    {
        unsigned long BytesLeft;
        void *p;
        BytesLeft = Stream_GetSize() - Stream_GetPosition();
        if (BytesLeft > 16384) BytesLeft = 16384;
        while (BytesLeft > 0) 
        {
            int NumLeft = Stream_GetSize() - Stream_GetPosition();
            Args->CurrentPos = Stream_GetPosition() / Args->AudioBits * 8 /  Args->SampleRate / Args->Channels * 1000;
            ProcessAudioMessages();
            if (WaitForSingleObject(SeekEvent, 0) == WAIT_OBJECT_0) 
            {
                if (Args->OutputMode == omMMSystem) 
                {
                    waveOutReset(WaveDevice);
                    ProcessAudioMessages();
                    BufferCount = 0;
                }
                if (Seek_Stream(NewSeekPosition))
                    NewSeekPosition = -1;
                else
                    NewSeekPosition = 0;
                SetEvent(SeekEvent2);
            }
            try
            {
                if (Args->CurrentPos < Args->StartPos) 
                {
                    continue;
                }
                if (Args->CurrentPos > Args->EndPos)  break; 
                
                p = malloc(BytesLeft);
                if (Stream_Read(p, BytesLeft))
                {
                    PlaySamples((unsigned char *)p, BytesLeft);
                    BytesLeft = 0;
                } 
                else
                {
                    free(p);
                    throw 1;
                }
                free(p);
                BytesLeft = Stream_GetSize() - Stream_GetPosition();
                if (BytesLeft > 16384) BytesLeft = 16384;

                if (Player->PauseFlag) 
                {
                    if (Args->OutputMode = omMMSystem) Pause_Audio();
                    Player->ThreadSync = 1;  
                    while(Player->PauseFlag)
                    {
                        Sleep(77);
                        if (Player->UserBreak) break;
                        if (WaitForSingleObject(SeekEvent, 0) == WAIT_OBJECT_0) 
                        {
                            if (Args->OutputMode == omMMSystem) 
                            {
                                waveOutReset(WaveDevice);
                                ProcessAudioMessages();
                                BufferCount = 0;
                            }
                            if (Seek_Stream(NewSeekPosition))
                                NewSeekPosition = -1;
                            else
                                NewSeekPosition = 0;
                            SetEvent(SeekEvent2);
                        }
                    }
                    if (Args->OutputMode = omMMSystem) Resume_Audio();                    
                } 
                if(Player->UserBreak) break;
            }
            catch (...)
            {
                throw;
            }
        }                                
    } catch (...) 
    {
        int kkk = 1;
    }
    Player->EndOfTune = false;
    if(!Player->UserBreak)
    {
        try 
        { 
            FinishBuffer(); 
        } 
        catch (...) 
        {
        }
        Player->EndOfTune = true;
        Reset_Stream();
        Done_MPAudio();
        Player->FPlayerMode = pmStopped;
    }
    else
    {
        if (Args->OutputMode == omMMSystem)
        {
            waveOutReset(WaveDevice);
            ProcessAudioMessages();
        }
        Reset_Stream(); 
        Done_MPAudio();
        Player->FPlayerMode = pmOpened;
    }
    Player->UserBreak=0; 
    return 0;
}

MPPlayer::~MPPlayer() {
    if (PlayerMode() > pmClosed) Close();
    if (Args) delete Args;
    CloseHandle(SeekEvent);
    CloseHandle(SeekEvent2);
}

MPPlayer::MPPlayer() {
    ModuleTag = 0x14581458;
    Args = new MPArgs();
    if (!Args) throw 1;
    Args->InputMode=imFile;
    Args->OutputMode=omMMSystem;  
    Args->Player = this;
    EndOfTune = false;
    FPlayerMode = pmClosed;
    UserBreak = false;
    LastError = peNoError;
    SeekEvent = CreateEvent(NULL, false, false, NULL);
    SeekEvent2 = CreateEvent(NULL, false, false, NULL);    
};

esPlayerError MPPlayer::ESGetLastError() {
    esPlayerError res = LastError;
    LastError = peNoError;
    return res;
}

bool MPPlayer::SetInName (const char *FileName){
    if (PlayerMode() != pmClosed) {
        LastError = peIncorrectMode;
        return false;
    }  
    if (Args->InName) free(Args->InName);
    Args->InName = (char *) xstrdup((LPTSTR) FileName);
    return true;
}

bool MPPlayer::SetOutName(const char *FileName){
    if (PlayerMode() >= pmPlaying) {
        LastError = peIncorrectMode;
        return false;
    }  
    if (Args->OutName) free(Args->OutName);
    Args->OutName = (char *) xstrdup((LPTSTR) FileName);
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

bool MPPlayer::Open(){
    if ((PlayerMode() != pmClosed) || ((Args->InputMode == imFile) && (!Args->InName))) {
        if (PlayerMode() != pmClosed) 
            LastError = peIncorrectMode; 
        else 
            LastError = peInputError;
        return false;
    }
    PauseFlag = 0;
    try {
        Init_Stream();            
    } catch (...) {
        LastError = peInputError;
        return false;
    }
    FPlayerMode = pmOpened;
    return true;
}

bool MPPlayer::InitStream(){
    if ((PlayerMode() != pmOpened) && (PlayerMode() != pmStopped))
    {
        LastError = peIncorrectMode;
        return false;
    }
    try 
    {
        if (!Stream_ReadHeader()) 
        {
            Reset_Stream();
            return false;
        }
    } 
    catch ( ... ) 
    {
        return false;
    }
    if(Args->ForceMono) 
    {
        Args->Channels=1;
    }
    if ((Args->SampleRate >= 48000)  && (Args->OutputMode == omMMSystem)) 
    {
        Args->SampleRate = Args->SampleRate/2;
        Args->ForceFreq = Args->SampleRate;
    }
    FPlayerMode = pmReady;
    return true;
}

bool MPPlayer::Play() {
    if (PlayerMode() != pmReady) 
    {
        LastError = peIncorrectMode;
        return false;
    }
    if ((Args->OutputMode == omCallback) && ((!Args->BufferCB) || (!Args->OutActionCB))) 
    {
        LastError = peNoCallback;
        return false;
    }
    if (Args->EndPos == 0) SetLimits(Args->StartPos, Args->EndPos);
    
    ThreadQueueEvent = CreateEvent(NULL, false, false, NULL);
    if (!ThreadQueueEvent) 
    {
        LastError = peInternalError;
        return false;
    }
    PlayThreadHan = CreateThread(NULL, 0, PlayThread, this, 0, &PlayerThreadID);
    WaitForSingleObject(ThreadQueueEvent, INFINITE);
    CloseHandle(ThreadQueueEvent);
    if (!PlayThreadHan) 
    {
        LastError = peInternalError;
        return false;           
    }
    if (LastError != peNoError)
        return false;
    SetThreadPriority(PlayThreadHan, Args->PlayPriority);
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
    if ((PlayerMode() == pmPlaying) || (PlayerMode() == pmPaused)) 
    {
        UserBreak = 1;        
        WaitForSingleObject(PlayThreadHan, INFINITE);
        CloseHandle(PlayThreadHan);
        LastError = peNoError;
        return true;
    } 
    if (PlayerMode() == pmStopped) 
    {
            FPlayerMode = pmOpened;             
            return true;
    } else {
        LastError = peIncorrectMode;
        return false;
    }
}

bool MPPlayer::Close(){
    if ((PlayerMode() == pmPlaying) || (PlayerMode() == pmPaused)) Stop();
    if (StreamInit) {
        Done_Stream();
        StreamInit = false;
    }    
    FPlayerMode = pmClosed;
    return true;
}

unsigned long MPPlayer::GetSize(){
    if (PlayerMode() > pmOpened) {
        return Stream_GetSize() / Args->AudioBits * 8 /  Args->SampleRate / Args->Channels * 1000;
    } else {
        LastError = peIncorrectMode;
        return -1;
    }
}

unsigned long MPPlayer::GetPos()
{
    if (PlayerMode() >= pmStopped) 
    {
        if (PlayerMode() == pmStopped) 
        {
            return Stream_GetSize() / Args->AudioBits * 8 /  Args->SampleRate / Args->Channels * 1000;
        }
        return Stream_GetPosition() / Args->AudioBits * 8 /  Args->SampleRate / Args->Channels * 1000;
    } 
    else 
    {
        LastError = peIncorrectMode;
        return -1;
    }
}

bool MPPlayer::CanSetPos() 
{
    if (PlayerMode() >= pmOpened) 
    {
        return Args->Seekable;
    } 
    else 
    {
        LastError = peIncorrectMode;
        return false;
    }
}

bool MPPlayer::SetPos(unsigned long NewPos){
    if ((PlayerMode() == pmPlaying) || (PlayerMode() == pmPaused)) 
    {
        NewSeekPosition = NewPos;
        SetEvent(SeekEvent);
        WaitForSingleObject(SeekEvent2, INFINITE);
        return (NewSeekPosition == -1);
    } else {
        LastError = peIncorrectMode;
        return false;
    }
}

bool MPPlayer::SetAudioBuffers(unsigned long buffers, unsigned long size){
    if (PlayerMode() >= pmReady) 
    {
        LastError = peIncorrectMode;
        return false;        
    } else 
    {
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

bool MPPlayer::SetLimits(unsigned long StartPos, unsigned long EndPos) 
{
    Args->StartPos = StartPos;
    EndPos < StartPos ? Args->EndPos = StartPos : Args->EndPos = EndPos;
    if (PlayerMode() >= pmReady) 
    {
        if ((!Args->EndPos)  || (Args->EndPos == 0xFFFFFFFF))
        {
            Args->EndPos = 0xFFFFFFFF; 
        }            
    } 
    return true;
}

bool MPPlayer::SetPriority(long Priority) 
{
    if (PlayerMode() >= pmPlaying)
    {
        return SetThreadPriority(PlayThreadHan, Priority);        
    } 
    else 
    {
        Args->PlayPriority = Priority;
        return true;
    }
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