#include "shared.h"
#include <WinSock2.h>

bool apply_hooks();

void codextended()
{
	srand(time(NULL));

	if (!apply_hooks())
	{
		MsgBox("Failed to hook. \n");
		Com_Quit_f();
	}
}