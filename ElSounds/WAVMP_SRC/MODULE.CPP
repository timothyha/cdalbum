#include "common.h"
#include "player.h"
#include "..\ESP\ElSound.h"
#include "stream.h"
#include <windows.h>

#ifdef _DIRECTX
#include <objbase.h>
#endif
                          
DWORD OLEInit;

bool IsValidHandle(HANDLE handle) {
    try 
    {
        return (((MPPlayer *) handle)->ModuleTag == 0x14581458);
    } catch (...) 
    {
        return false;
    }
}

LPCTSTR NameString = "Wave Audio";

bool __declspec(dllexport) _stdcall ESGetName(char *buffer, unsigned long *buflen){
    if ((!buffer) || (strlen(NameString) > *buflen - 1)) {
        *buflen = strlen(NameString);
        return false;
    };
    strcpy(buffer, NameString);
    *buflen = strlen(NameString);
    return true;
}

LPCTSTR ExtsString = "*.wav";

bool __declspec(dllexport) _stdcall ESGetExts(char *buffer, unsigned long *buflen){
    if ((!buffer) || (strlen(ExtsString) > *buflen - 1)) {
        *buflen = strlen(ExtsString);
        return false;
    };
    strcpy(buffer, ExtsString);
    *buflen = strlen(ExtsString);
    return true;
}

const char *AboutString = "EldoS Wave Audio player (c) 1999 EldoS";

bool __declspec(dllexport) _stdcall ESGetAbout(char *buffer, unsigned long *buflen) {
    if ((!buffer) || (strlen(AboutString) > *buflen - 1)) {
        *buflen = strlen(AboutString);
        return false;
    };
    strcpy(buffer, AboutString);
    *buflen = strlen(AboutString);
    return true;
}

long __declspec(dllexport) _stdcall ESGetVersion() {
    return 120;
}

bool __declspec(dllexport) _stdcall ESSetBuffers(HANDLE handle, unsigned long buffers, unsigned long size){
    if (IsValidHandle(handle)) 
        return ((MPPlayer *)handle)->SetAudioBuffers(buffers, size);
    else 
        return false;
}

bool __declspec(dllexport) _stdcall ESSetLimits(HANDLE handle, unsigned long StartPos, unsigned long EndPos){
    if (IsValidHandle(handle)) 
        return ((MPPlayer *)handle)->SetLimits(StartPos, EndPos);
    else 
        return false;
}

bool __declspec(dllexport) _stdcall ESSetPriority(HANDLE handle, long Priority) {
    if (IsValidHandle(handle)) 
        return ((MPPlayer *)handle)->SetPriority(Priority);
    else 
        return false;
}

unsigned long __declspec(dllexport) _stdcall ESGetPlayerMode(HANDLE handle) {
    if (IsValidHandle(handle)) {
        if (((MPPlayer *)handle)->FPlayerMode == pmStopped) {
            ((MPPlayer *)handle)->FPlayerMode = pmOpened;
            return pmStopped;
        }
        return (unsigned long)((MPPlayer *)handle)->FPlayerMode;
    } else 
        return -1;
}

bool __declspec(dllexport) _stdcall ESSetInputName(HANDLE handle, char *Name) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetInName(Name);
    } else return false;
}

bool __declspec(dllexport) _stdcall ESSetOutputName(HANDLE handle, char *Name) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetOutName(Name);
    } else return false;
}

bool __declspec(dllexport) _stdcall ESSetInputMode(HANDLE handle, unsigned long InMode) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetInMode((esInputMode)InMode);
    } else return false;
}

bool __declspec(dllexport) _stdcall ESSetOutputMode(HANDLE handle, unsigned long OutMode) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetOutMode((esOutputMode)OutMode);
    } else return false;
}

bool __declspec(dllexport) _stdcall ESSetOutputDev(HANDLE handle, unsigned long DevNum) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetOutputDevice(DevNum);
    } else return false;
}

long __declspec(dllexport) _stdcall ESLastError(HANDLE handle){
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->ESGetLastError();
    } else return -1;
}

bool __declspec(dllexport) _stdcall ESDeInitModule(HANDLE handle) {
    if (IsValidHandle(handle)) {
        delete (MPPlayer *)handle;
#ifdef _DIRECTX
    if (OLEInit) {
        CoUninitialize();
        OLEInit--;
    }
#endif
        return true;
    } else return false;
}

HANDLE __declspec(dllexport) _stdcall ESInitModule(){
    try {
        HANDLE res = new MPPlayer();    
#ifdef _DIRECTX
        if (res) {
            if (!OLEInit) 
            {
                HRESULT hr = CoInitialize(NULL);
                if ((hr != E_INVALIDARG) && (hr !=  E_OUTOFMEMORY) && (hr != E_UNEXPECTED))
                    OLEInit++;
                else 
                {
                    delete (MPPlayer *) res;
                    return 0;
                }
            }
        }
#endif
        return res;
    } catch (...) {
        return 0;
    }
}

bool __declspec(dllexport) _stdcall ESOpen(HANDLE handle){
    if (!IsValidHandle(handle)) return false;
    else return ((MPPlayer *)handle)->Open();
}

bool __declspec(dllexport) _stdcall ESInitStream(HANDLE handle){
    if (!IsValidHandle(handle)) return false;
    else return ((MPPlayer *)handle)->InitStream();
}

bool __declspec(dllexport) _stdcall ESClose(HANDLE handle) {
    if (!IsValidHandle(handle)) return false;
    else return ((MPPlayer *)handle)->Close();
}

bool __declspec(dllexport) _stdcall ESPlay(HANDLE handle) {
    if (!IsValidHandle(handle)) return false;
    else return ((MPPlayer *)handle)->Play();
}

bool __declspec(dllexport)  _stdcall ESStop(HANDLE handle) {
    if (!IsValidHandle(handle)) return false;
    else return ((MPPlayer *)handle)->Stop();
}

bool __declspec(dllexport)  _stdcall ESPause(HANDLE handle) {
    if (!IsValidHandle(handle)) return false;
    else return ((MPPlayer *)handle)->Pause();
}

bool __declspec(dllexport)  _stdcall ESResume(HANDLE handle) {
    if (!IsValidHandle(handle)) return false;
    else return ((MPPlayer *)handle)->Resume();
}

unsigned long __declspec(dllexport) _stdcall ESGetSize(HANDLE handle){
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->GetSize();
    } else return -1;
}

bool __declspec(dllexport) _stdcall ESCanSetPos(HANDLE handle){
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->CanSetPos();
    } else return false;
}

unsigned long __declspec(dllexport) _stdcall ESGetPos(HANDLE handle){
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->GetPos();
    } else return -1;
}

bool __declspec(dllexport) _stdcall ESSetPos(HANDLE handle, unsigned long NewPos){
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetPos(NewPos);
    } else return false;
}

bool __declspec(dllexport) _stdcall ESSetInCB(HANDLE handle, InFileOpenCB openCB, 
                                              InFileCloseCB closeCB, InFileGetSizeCB getsizeCB,
                                              InFileSeekCB seekCB, InFileReadCB readCB,
                                              unsigned long UserData1){
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetInCB(openCB, closeCB, getsizeCB, seekCB, readCB, UserData1);
    } else return false;
}

bool __declspec(dllexport) _stdcall ESSetOutCB(HANDLE handle, WaveOutCB OutCB, WaveOutActionCB OutActionCB, unsigned long UserData) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetOutCB(OutCB, OutActionCB, UserData);
    } else return false;
}

bool __declspec(dllexport) _stdcall ESGetInfo2(HANDLE handle, unsigned long *Info2) {
    if (IsValidHandle(handle)) {
        if (((MPPlayer *)handle)->PlayerMode() > pmClosed) {
            *Info2 = 0;
            return true;
        } else {
            LastError = peIncorrectMode;
            Info2 = 0;
            return false;
        }
    } else {
        Info2 = 0;
        return false;
    }
}

bool __declspec(dllexport) _stdcall ESGetInfo1(HANDLE handle, void *InfoBuf, unsigned long *buflen) {
    MPInfo *Buf = (MPInfo *)InfoBuf;
    if (IsValidHandle(handle)) {
        if ((!InfoBuf) || (*buflen < sizeof(MPInfo))) {
            *buflen = sizeof(MPInfo);
            LastError = peNoError;
            return false;
        }
        if (((MPPlayer *)handle)->PlayerMode() < pmReady) {
            *buflen = sizeof(MPInfo);
            LastError = peIncorrectMode;
            return false;
        }
        Buf->bitspersample = Args->AudioBits;
        Buf->frequency = Args->SampleRate;
        Buf->stereo = Args->Channels;
        *buflen = sizeof(MPInfo);
        return true;
    } else return false;
}

bool __declspec(dllexport) _stdcall ESCanPause(HANDLE handle) {
    return IsValidHandle(handle);
}

bool __declspec(dllexport) _stdcall ESSetVolume(HANDLE handle, unsigned long Volume){
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetVolume(Volume);
    } else {
        return false;
    }
}

bool __declspec(dllexport) _stdcall ESGetVolume(HANDLE handle, unsigned long *Volume){
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->GetVolume(Volume);
    } else {
        return false;
    }
}

bool __declspec(dllexport) _stdcall ESCanSetVolume(HANDLE handle, bool *Separate) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->CanSetVolume(Separate);
    } else {
        return false;
    }
}

bool __declspec(dllexport) _stdcall ESSetDevNum(HANDLE handle, unsigned long DevNum) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetDevNum(DevNum);
    } else {
        return false;
    }
}

bool __declspec(dllexport) _stdcall ESSetWindow(HANDLE handle, HWND Wnd) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->SetWindow(Wnd);
    } else {
        return false;
    }
}

bool __declspec(dllexport) _stdcall ESSetExtras(HANDLE handle, void *Param) {
    return IsValidHandle(handle);
}

bool __declspec(dllexport) _stdcall ESUseOutCB(HANDLE handle, bool UseCB) {
    if (IsValidHandle(handle)) {
        return ((MPPlayer *)handle)->UseOutCB(UseCB);
    } else {
        return false;
    }
}

bool __declspec(dllexport) _stdcall ESHasEQ(HANDLE handle, bool *ItDoes) {
    return false;
}                        

bool __declspec(dllexport) _stdcall ESEQ(HANDLE handle, LPVOID *EQData, unsigned long *channels, unsigned long *bands){
    LastError = peNotImplemented;
    return false;
}

bool __declspec(dllexport) _stdcall ESUseEQ(HANDLE handle, bool UseEQ) {
    LastError = peNotImplemented;
    return false;
}
