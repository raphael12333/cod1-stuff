#include "stdafx.h"
#include "shared.h"

void sub_40ef70()
{
	void(*o)();
	*(UINT32*)&o = 0x40ef70;
	o();

	void Sys_Unload();
	Sys_Unload();
}

void Main_UnprotectModule(HMODULE hModule)
{
	PIMAGE_DOS_HEADER header = (PIMAGE_DOS_HEADER)hModule;
	PIMAGE_NT_HEADERS ntHeader = (PIMAGE_NT_HEADERS)((DWORD)hModule + header->e_lfanew);
	// unprotect the entire PE image
	SIZE_T size = ntHeader->OptionalHeader.SizeOfImage;
	DWORD oldProtect;
	VirtualProtect((LPVOID)hModule, size, PAGE_EXECUTE_READWRITE, &oldProtect);
}

bool apply_hooks()
{
	HMODULE hModule;
	if (SUCCEEDED(GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, (LPCSTR)apply_hooks, &hModule)))
	{
		Main_UnprotectModule(hModule);
	}

	void patch_opcode_loadlibrary();
	patch_opcode_loadlibrary();

	__call(0x4684c5, (int)sub_40ef70); //cleanup exit

	int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow);
	__call(0x560f99, (int)WinMain);
	
	void CL_Init();
	__call(0x439fca, (int)CL_Init);
	__call(0x43a617, (int)CL_Init);

	return true;
}