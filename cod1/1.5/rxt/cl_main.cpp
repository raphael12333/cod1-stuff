#include "shared.h"

cvar_t *cl_running;
cvar_t *cg_zoomSensitivity_ratio;

void CL_Init(void)
{
	void(*oCL_Init)();
	*(int*)(&oCL_Init) = 0x413380;
	oCL_Init();

	cg_zoomSensitivity_ratio = Cvar_Get("sensitivityRatioAds", "1.0", CVAR_ARCHIVE);
}