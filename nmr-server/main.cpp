#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>

#include "config.h"
#include "log.h"
#include "nmrcore.h"
#include "nmr.h"

int handleConnection(int sock_client);

NMRCore* nmr = NULL;

int main(int argc, char *argv[])
{
	struct sockaddr_in addr;
	uint32_t command, value;
	char buffer[65536];
	int i, size, yes = 1;

	LOG("NMR Server Daemon version %s\n", VERSION);

	nmr = new NMRCore();

	// Get a server socket
	int sock_server;
	if((sock_server = socket(AF_INET, SOCK_STREAM, 0)) < 0)
	{
		ERROR("Cannot instantiate server socket: %s\n", strerror(errno));
		// perror(NULL);
		return EXIT_FAILURE;
	}
	setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, (void *)&yes , sizeof(yes));

	/* setup listening address */
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(SERVER_PORT);

	if(bind(sock_server, (struct sockaddr *)&addr, sizeof(addr)) < 0)
	{
		ERROR("Cannot bind server socket: %s\n", strerror(errno));
		return EXIT_FAILURE;
	}

	LOG("Sending test pulse...");
	nmr->singleShot();

	listen(sock_server, 1024);

	int sock_client;
	while(1)
	{
		LOG("Waiting for connection.\n");
		if((sock_client = accept(sock_server, NULL, NULL)) < 0)
		{
			ERROR("Could not accept socket: %s\n", strerror(errno)); 
			return EXIT_FAILURE;
		};
		if(handleConnection(sock_client))
		{
			LOG("Connection Terminated.");
		};
		close(sock_client);
	} // while(1) server

	printf("Closing server socket.\n");
	close(sock_server);
	delete nmr;
	return EXIT_SUCCESS;
}

int handleConnection(int sock_client)
{
	LOG("\nConnection accepted.\n");

	CommandPacket command;
	CommandReply  reply;
	char command_data[MAX_COMMAND_DATA];
	void* reply_data = NULL;
	int res;
	while(1)
	{
		printf(".\n");
		// recv command len
		res = recv(sock_client, &command, sizeof(command), MSG_WAITALL);
		if(res == 0)
		{
			LOG("Remote closed connection.\n");
			return 0;
		}
		if(res < 0)
		{
			ERROR("Read error while reading command: %s\n", strerror(errno));
			return 1;
		};
		if(command.data_len > MAX_COMMAND_DATA)
		{
			ERROR("Command extra data_len too big. Bailing out.\n");
			return 2;
		}

		// read extra data
		if(command.data_len > 0)
		{
			DBG("before recv\n");
			res = recv(sock_client, &command_data, command.data_len, MSG_WAITALL);
			DBG("after recv\n");
			if(res == 0)
			{
				LOG("Remote closed connection.\n");
				return 0;
			}
			if(res < 0)
			{
				ERROR("Read error while reading data_len: %s\n", strerror(errno));
				return 1;
			};
		};

		// prepare the reply
		reply.id = command.id;
		reply.result = RES_UNKNOWN;
		reply.data_len = 0;
		reply_data = NULL;

		// int command = *((int*)pbuf) >> 28;
		// int param = pbuf & 0x0fffffff;
		switch(command.commandcode)
		{
			case CMD_SET_FREQ:
				LOG("Set Freq %d\n", command.param);
				reply.result = nmr->setFrequency(command.param) ? RES_ERROR : RES_OK;
				break;
			case CMD_SET_RATE:
				reply.result = nmr->setRxRate((NMRDecimationRate) command.param) ? RES_ERROR : RES_OK;
				LOG("Set Rx SampleRate #%d: %d ksps.\n", command.param, nmr->getRxRate());
				break;
			case CMD_SET_AWIDTH:
				LOG("Set A-Width %d usec.\n", command.param);
				reply.result = nmr->setTxAlen(command.param) ? RES_ERROR : RES_OK;
				break;
			case CMD_SET_BWIDTH:
				LOG("Set B-Width %d usec.\n", command.param);
				reply.result = nmr->setTxBlen(command.param) ? RES_ERROR : RES_OK;
				break;
			case CMD_SET_ABDLY:
				LOG("Set AB-Delay %d usec.\n", command.param);
				reply.result = nmr->setTxABdly(command.param) ? RES_ERROR : RES_OK;
				break;
			case CMD_SET_BBDLY:
				LOG("Set BB-Delay %d usec.\n", command.param);
				reply.result = nmr->setTxBBdly(command.param) ? RES_ERROR : RES_OK;
				break;
			case CMD_SET_BBCNT:
				LOG("Set B-Count %d usec.\n", command.param);
				reply.result = nmr->setTxBBcnt(command.param) ? RES_ERROR : RES_OK;
				break;
			case CMD_FIRE:
				LOG("SingleShot.\n");
				if(nmr->singleShot())
				{
					ERROR("singleShot failed.");
					reply.result = RES_ERROR;
					break;
				};
				if(nmr->getRxBuffer(&reply_data, &(reply.data_len)))
				{
					ERROR("Failed to get RxBuffer from NMR Core.\n");
					reply.result = RES_ERROR;
					break;
				}
				reply.result = RES_OK;
				break;
			case CMD_SET_RX_SIZE:
				LOG("Set Rx Size %d\n", command.param);
				reply.result = nmr->setRxSize(command.param) ? RES_ERROR : RES_OK;
				break;
			case CMD_SET_RX_DELAY:
				LOG("Set Rx Delay %d\n", command.param);
				reply.result = nmr->setRxDelay(command.param) ? RES_ERROR : RES_OK;
				break;
			case CMD_KEEPALIVE:
				LOG("Keep-Alive packet received.\n");
				reply.result = RES_OK;
				break;
			default:
				WARNING("Unknown command code: %d\n", command.commandcode);
				break;
		} // switch(command)

		// send reply
		DBG("Sending reply packet (id = %u, result = %u, data_len = %u)\n", reply.id, reply.result, reply.data_len);
		send(sock_client, &reply, sizeof(reply), MSG_NOSIGNAL);
		if(reply.data_len)
			send(sock_client, reply_data, reply.data_len, MSG_NOSIGNAL);
	};
	return 0;
}
