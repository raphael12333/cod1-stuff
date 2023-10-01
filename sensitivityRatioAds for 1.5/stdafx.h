// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently

#pragma once
#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "Shell32.lib")
#define __TITLE "Call of Duty Extended"
#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files:
#include <windows.h>

#ifdef DEBUG
#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
#endif

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <varargs.h>
#include <ctime>
#include <string>
#include <vector>
#include <map>
#include "mem_util.h"

#define QDECL __cdecl
typedef unsigned char byte;
#define DLL_EXPORT __declspec(dllexport)
#define DLL_IMPORT __declspec(dllimport)

static void MsgBox(const char *msg)
{
	MessageBoxA(NULL, msg, __TITLE, MB_OK | MB_ICONINFORMATION);
}
//#define XCRASH _memset((void*)0x400000, 0, 0xffff);

typedef enum
{
	COD_UNKNOWN,
	COD_1,
	COD_5,
	COD_5_SP_STEAM,
	COD_5_STEAM, //steam version
	CODUO_41,
	CODUO_51,
	COD2_0,
	COD2_1,
	COD2_2,
	COD2_3,
	COD4_7,
	COD_END_OF_LIST
} cod_v;
static const char *codversion_strings[] =
{
	"UNKNOWN",
	"1.1",
	"1.5",
	"1.5 SP Steam",
	"1.5 Steam",
	"UO 1.41",
	"UO 1.51",
	"2.0",
	"2.1",
	"2.2",
	"2.3",
	"4 1.7",
	"end_of_list"
};
extern int codversion;
static const char *get_codversion_string()
{
	return codversion_strings[codversion];
}

static void(*Com_Quit_f)() = (void(*)())0x438220;

typedef struct
{
	std::string key;
	DWORD id;
	HANDLE handle;
} threadInfo_t;
extern std::vector<threadInfo_t> threadsinfo;
extern bool thrIsExit;
std::string GetLastErrorAsString();
std::string GetOpenFileNameS(HWND owner);

static bool FileExists(const char *fn)
{
	DWORD attr = GetFileAttributesA(fn);
	return (attr != INVALID_FILE_ATTRIBUTES && !(attr & FILE_ATTRIBUTE_DIRECTORY));
}

int Sys_GetModulePathInfo(HMODULE module, char **path, char **filename, char **extension);
enum HashType
{
	HashSha1, HashMd5, HashSha256
};
std::string GetHashText(const void * data, const size_t data_size, HashType hashType);

#define __call6to5(x, y) do {\
XUNLOCK((void*)x, 6); \
*(BYTE*)x = 0xe8; \
__call(x, (int)y); \
*(BYTE*)(x + 5) = 0x90; \
} while (0)

static bool is_addr_safe(size_t addr)
{
	__try
	{
		*(unsigned char*)(addr);
	} __except (1)
	{
		return false;
	}
	return true;
}
template <typename T, typename ... Ts> T call(size_t addr, Ts ... ts);
template <typename T, typename ... Ts>
T call(size_t addr, Ts ... ts)
{
	T(*f)(...);
	*(T*)&f = (T)addr;
	return f(ts...);
}