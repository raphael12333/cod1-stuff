#include "stdafx.h"

void codextended();

HMODULE hModule;
HANDLE hLogFile = INVALID_HANDLE_VALUE;

BOOL APIENTRY DllMain(
	HMODULE hMod,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved)
{
	char szModuleName[MAX_PATH + 1];
	GetModuleFileName(NULL, szModuleName, MAX_PATH);
	if (strstr(szModuleName, "rundll32") != NULL)
	{
		return TRUE;
	}

	switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		{
			DisableThreadLibraryCalls(hMod);
			hModule = hMod;
			codextended();
		}
		break;
	}
	return TRUE;
}