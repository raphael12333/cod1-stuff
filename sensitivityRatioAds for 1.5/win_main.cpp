#include "shared.h"
#include "Commctrl.h"
#include "ShlObj.h"
#include "Shlwapi.h"
#include "Shellapi.h"

static int(__stdcall *main)(HINSTANCE, HINSTANCE, LPSTR, int) = (int(__stdcall*)(HINSTANCE, HINSTANCE, LPSTR, int))0x4694b0;

char sys_cmdline[MAX_STRING_CHARS];
char szAppData[MAX_PATH + 1];
std::vector<threadInfo_t> threadsinfo;
bool thrIsExit = false;
extern HMODULE hModule;
HINSTANCE hInst;
bool bNullClient = false;
HWND g_Dialog = nullptr;

BOOL CALLBACK DlgProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_CLOSE:
		if (g_Dialog != nullptr)
		{
			DestroyWindow(g_Dialog);
			g_Dialog = nullptr;
		}
		PostQuitMessage(0);
		break;
	return 0;
	default:
		return FALSE;
	}
	return TRUE;
}

void RemoveThread(threadInfo_t *ti)
{
	if (!ti)
		return;
	DWORD exitCode;
	for (auto it = threadsinfo.begin(); it != threadsinfo.end();)
	{
		if (it->handle == ti->handle)
		{
			if (GetExitCodeThread(it->handle, &exitCode) != 0)
			{
				if (exitCode == STILL_ACTIVE)
				{
					if (WaitForSingleObject(it->handle, INFINITE) != WAIT_OBJECT_0)
						MsgBox("fail wait");
				}
				CloseHandle(it->handle);
			}
			it = threadsinfo.erase(it);
			break;
		}
		else
			++it;
	}
}

void CleanupThreads()
{
	thrIsExit = true;
	DWORD exitCode;
	for (std::vector<threadInfo_t>::iterator it = threadsinfo.begin(); it != threadsinfo.end();)
	{
		if (!it->handle)
			goto just_del;
		if (GetExitCodeThread(it->handle, &exitCode) != 0)
		{
			if (exitCode == STILL_ACTIVE)
			{
				if (WaitForSingleObject(it->handle, INFINITE) != WAIT_OBJECT_0)
					MsgBox("fail wait");
			}
			CloseHandle(it->handle);
			just_del:
			it->handle = NULL;
			it = threadsinfo.erase(it);
			continue;
		}
		++it;
	}
}

threadInfo_t *AddThread(std::string key, DWORD(WINAPI *thr_func)(LPVOID))
{
	threadInfo_t ti;
	ti.key = key;
	ti.handle = (HANDLE)CreateThread(0, 0, thr_func, 0, 0, &ti.id);
	int idx = threadsinfo.size();
	threadsinfo.push_back(ti);
	return &threadsinfo[idx];
}

extern "C" bool bClosing = false;
void Sys_Unload()
{
	bClosing = true;
	static bool unloaded = false;
	if (unloaded)
		return;
	unloaded = true;
	void CleanupThreads();
	CleanupThreads();
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	hInst = hInstance;
	strncpy(sys_cmdline, lpCmdLine, sizeof(sys_cmdline) - 1);

	void MSS32_Hook();
	MSS32_Hook();
	extern bool miles32_loaded;
	if (!miles32_loaded)
		return 0;

	return main(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
}