
/*
 *
 * types.h
 *
 */

#ifndef TYPES_H
#define TYPES_H

#ifndef DEPUTY
 #define COUNT(n)
 #define NT
 #define NTS
 #define NONNULL
 #define ASSUMECONST
 #define SAFE
 #define BND(x,y)
#endif



/*
 * Built-in type synonyms.
 */

#define	ulong	unsigned long
#define	ushort	unsigned short
#define	uchar	unsigned char


/*
 * Useful constants.
 */

#ifndef TRUE
#define TRUE	1
#endif	/* TRUE */

#ifndef FALSE
#define FALSE	0
#endif	/* FALSE */

#endif	/* TYPES_H */
