#include "shared.h"

DWORD cgame_mp;

extern cvar_t* cg_zoomSensitivity_ratio;
float stockCgZoomSensitivity()
{
	float* fov_visible_percentage = (float*)CGAME_OFF(0x3020d340);	//Visible percentage of cg_fov value
	float* cg_fov_value = (float*)CGAME_OFF(0x3029ca28);
	return (*fov_visible_percentage / *cg_fov_value);				//See instruction 30034688
}
void sensitivityRatioAds()
{
	float* cg_zoomSensitivity = (float*)CGAME_OFF(0x3020f3a8);		//zoomSensitivity var of cg_t struct
	float* ads_anim_progress = (float*)CGAME_OFF(0x3020afcc);		//From 0 to 1
	//See FUN_300344c0
	if (*ads_anim_progress == 1) //ADS animation completed
	{
		//ADS
		*cg_zoomSensitivity = (stockCgZoomSensitivity() * cg_zoomSensitivity_ratio->value);
	}
	else if (*ads_anim_progress != 0) //ADS animation in progress
	{
		bool* ads = (bool*)CGAME_OFF(0x3020d20c);
		if (*ads)
		{
			//ADS
			*cg_zoomSensitivity = (stockCgZoomSensitivity() * cg_zoomSensitivity_ratio->value);
		}
		else
		{
			//NOT ADS
			*cg_zoomSensitivity = stockCgZoomSensitivity();
		}
	}
	else if (*ads_anim_progress == 0)
	{
		//NOT ADS
		*cg_zoomSensitivity = stockCgZoomSensitivity();
	}

	__asm
	{
		fstp st(0)
		retn
	}
}

void CG_Init(DWORD base)
{
	cgame_mp = base;
	__jmp(CGAME_OFF(0x30034688), (int)sensitivityRatioAds);
}