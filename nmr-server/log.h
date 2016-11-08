#ifndef LOG_H
#define LOG_H

#include "config.h"

//workaround for making __LINE__(int) work as string, first one turns __LINE__-> 62, second 62 -> "62"
#ifndef __STRINGIFY
#  define __STRINGIFY(x)    #x
#endif
#define ___STRINGIFY(x) __STRINGIFY(x)
#define __LINESTR__ ___STRINGIFY(__LINE__)

#ifdef DEBUG
# define DEBUGLOG
#endif

#ifdef DEBUGLOG
# define DBG(msg, ...)      printf("%s: " msg, __FUNCTION__, ##__VA_ARGS__)
#else
#define DBG(msg, ...)
#endif

//#define LOG(msg, ...)	    qDebug   ("%s: "msg, __FUNCTION__, ##__VA_ARGS__)
#define LOG(msg, ...)	    printf   ("%s: " msg, __FUNCTION__, ##__VA_ARGS__)
#define WARNING(msg, ...)   printf   ("WARN :" __FILE__ ".%s(" __LINESTR__ "): " msg, __FUNCTION__, ##__VA_ARGS__)
//#define CRITICAL(msg, ...)  qCritical(__FILE__ ".%s(" __LINESTR__ "): " msg, __FUNCTION__, ##__VA_ARGS__)
#define ERROR(msg, ...)     printf   ("ERROR:" __FILE__ ".%s(" __LINESTR__ "): " msg, __FUNCTION__, ##__VA_ARGS__)

#endif // LOG_H
