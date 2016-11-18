#ifndef _NMR_H
#define _NMR_H

#include <stdint.h>

#define MAX_COMMAND_LEN		16
#define MAX_COMMAND_DATA	0	// not supported currently

typedef enum CommandCode_enum : uint32_t {
	CMD_SET_FREQ 	= 0,
	CMD_SET_RATE 	= 1,
	CMD_SET_AWIDTH 	= 2,
	CMD_FIRE		= 3,
	CMD_SET_RX_SIZE = 4,

    CMD_SET_AADLY 	= 5, // currently host side, not implemented in PL
    CMD_SET_ABDLY 	= 6,
    CMD_SET_BWIDTH 	= 7,
    CMD_SET_BBDLY 	= 8,
    CMD_SET_BBCNT 	= 9
} CommandCode;

typedef struct {
	uint32_t id;
	CommandCode commandcode;
	uint32_t param;
	uint32_t data_len;
} CommandPacket;

typedef enum CommandResultCode_enum : uint32_t {
	RES_OK = 0,
	RES_ERROR = 1,
	RES_UNKNOWN = 99,
} ResultCode;

typedef struct {
	uint32_t id;
	ResultCode result;
	uint32_t data_len;
} CommandReply;

#endif // _NMR_H