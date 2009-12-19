#ifndef COMMON_H 
#define COMMON_H 

#define real double
#define M_PI    3.14159265358979323846
#define M_SQRT2 1.41421356237309504880
#define SBLIMIT                 32
#define SCALE_BLOCK             12
#define SSLIMIT                 18

struct TextInfo 
{
    char Title[512];
    char Artist[512];
    char Album[512];
    char Copyright[512];
    char Comment[512];
    char Genre[512];
    char Year[512];    
};

#endif 
