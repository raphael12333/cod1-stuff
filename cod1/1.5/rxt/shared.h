#include "common.h"

#define CVAR_ARCHIVE        1   // set to cause it to be saved to vars.rc
// used for system variables, not for player
// specific configurations
#define CVAR_USERINFO       2   // sent to server on connect or change
#define CVAR_SERVERINFO     4   // sent in response to front end requests
#define CVAR_SYSTEMINFO     8   // these cvars will be duplicated on all clients
#define CVAR_INIT           16  // don't allow change from console at all,
// but can be set from the command line
#define CVAR_LATCH          32  // will only change when C code next does
// a Cvar_Get(), so it can't be changed
// without proper initialization.  modified
// will be set, even though the value hasn't
// changed yet
#define CVAR_ROM            64		// display only, cannot be set by user at all
#define CVAR_USER_CREATED   128		// created by a set command
#define CVAR_TEMP           256		// can be set even when cheats are disabled, but is not archived
#define CVAR_CHEAT          512		// can not be changed if cheats are disabled
#define CVAR_NORESTART      1024    // do not clear when a cvar_restart is issued
#define CVAR_WOLFINFO       2048    // DHM - NERVE :: Like userinfo, but for wolf multiplayer info
#define CVAR_UNSAFE         4096    // ydnar: unsafe system cvars (renderer, sound settings, anything that might cause a crash)
#define CVAR_SERVERINFO_NOUPDATE        8192    // gordon: WONT automatically send this to clients, but server browsers will see it
#define MAX_STRING_CHARS    1024    // max length of a string passed to Cmd_TokenizeString
#define MAX_STRING_TOKENS   256     // max tokens resulting from Cmd_TokenizeString
#define MAX_TOKEN_CHARS     1024    // max length of an individual token
#define MAX_RELIABLE_COMMANDS			64
#define MAX_INFO_STRING     1024
#define MAX_INFO_KEY        1024
#define MAX_INFO_VALUE      1024
#define BIG_INFO_STRING     8192    // used for system info key only
#define BIG_INFO_KEY        8192
#define BIG_INFO_VALUE      8192
#define MAX_NAME_LENGTH     36      // max length of a client name
#define MAX_QPATH 64
#define MAX_OSPATH 256

typedef enum { qfalse, qtrue }    qboolean;

typedef struct cvar_s
{
	char *name;
	char *string;
	char *resetString;			// cvar_restart will reset to this value
	char *latchedString;		// for CVAR_LATCH vars
	int flags;
	qboolean modified;			// set each time the cvar is changed
	int modificationCount;		// incremented each time the cvar is changed
	float value;				// atof( string )
	int integer;				// atoi( string )
	struct cvar_s *next;
	struct cvar_s *hashNext;
} cvar_t;

typedef cvar_t* (*Cvar_Get_t)(const char*, const char*, int);
extern Cvar_Get_t Cvar_Get;

extern DWORD game_mp;
extern DWORD cgame_mp;

#define GAME_OFF(x) (game_mp + (x - 0x20000000))
#define CGAME_OFF(x) (cgame_mp + (x - 0x30000000))