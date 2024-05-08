/* sleep - delay for a specified amount of time.
   Copyright (C) 1984, 1991-1997, 1999-2005, 2007-2011 Free Software
   Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

#include <config.h>
#include <stdio.h>
#include <sys/types.h>
#include <getopt.h>

#include "system.h"
#include "c-strtod.h"
#include "error.h"
#include "long-options.h"
#include "quote.h"
#include "xnanosleep.h"
#include "xstrtod.h"
#include <csolvelib.h>

/* The official name of this program (e.g., no `g' prefix).  */
#define PROGRAM_NAME "sleep"

#define AUTHORS \
  proper_name ("Jim Meyering"), \
  proper_name ("Paul Eggert")

void
usage (int status)
{
  if (status != EXIT_SUCCESS)
    fprintf (stderr, _("Try `%s --help' for more information.\n"),
             program_name);
  else
    {
      printf (_("\
Usage: %s NUMBER[SUFFIX]...\n\
  or:  %s OPTION\n\
Pause for NUMBER seconds.  SUFFIX may be `s' for seconds (the default),\n\
`m' for minutes, `h' for hours or `d' for days.  Unlike most implementations\n\
that require NUMBER be an integer, here NUMBER may be an arbitrary floating\n\
point number.  Given two or more arguments, pause for the amount of time\n\
specified by the sum of their values.\n\
\n\
"),
              program_name, program_name);
      fputs (HELP_OPTION_DESCRIPTION, stdout);
      fputs (VERSION_OPTION_DESCRIPTION, stdout);
      emit_ancillary_info ();
    }
  exit (status);
}

/* Given a floating point value *X, and a suffix character, SUFFIX_CHAR,
   scale *X by the multiplier implied by SUFFIX_CHAR.  SUFFIX_CHAR may
   be the NUL byte or `s' to denote seconds, `m' for minutes, `h' for
   hours, or `d' for days.  If SUFFIX_CHAR is invalid, don't modify *X
   and return false.  Otherwise return true.  */

static bool
apply_suffix (double *x, char suffix_char)
{
  int multiplier;

  switch (suffix_char)
    {
    case 0:
    case 's':
      multiplier = 1;
      break;
    case 'm':
      multiplier = 60;
      break;
    case 'h':
      multiplier = 60 * 60;
      break;
    case 'd':
      multiplier = 60 * 60 * 24;
      break;
    default:
      return false;
    }

  *x *= multiplier;

  return true;
}

//csolve_main (argc, argv){ exit (0); } 
//int
//main (int REF(V>0) argc, char * ARRAY VALIDPTR LOC(PROGRAM_NAME_LOC) * START NONNULL ARRAY SIZE(argc * 4) argv)
//    CHECK_TYPE GLOBAL(PROGRAM_NAME_LOC){ return 0; }

double csolve_body_hoist(char NULLTERMSTR * STRINGPTR csolve_tmp0, bool *ok){
  double s;
  const char * ARRAY p;
  bool csolve_tmp1 = xstrtod (csolve_tmp0, &p, &s, c_strtod);
      
  if (p){ 
    char csolve_tmp2 = *p;
    char csolve_tmp3 = *(p+1);
    bool csolve_tmp4 = apply_suffix (&s, csolve_tmp2);
    if (! csolve_tmp1 
       || ! (0 <= s)
       || (csolve_tmp2 && csolve_tmp3)
       || ! csolve_tmp4)
    {
      error (0, 0, _("invalid time interval %s"), quote (csolve_tmp0));
      *ok = false;
    }
  return s;
  }
}

//csolve_main (argc, argv)
//int
//main (int argc, char **argv)
int
main (int REF(V>0) argc, char NULLTERMSTR * ARRAY VALIDPTR LOC(PROGRAM_NAME_LOC) * START NONNULL ARRAY SIZE(argc * 4) argv)
    CHECK_TYPE GLOBAL(PROGRAM_NAME_LOC)
{
  int i;
  double seconds = 0.0;
  bool ok = true;

  initialize_main (&argc, &argv);
  set_program_name (argv[0]);
  setlocale (LC_ALL, "");
  bindtextdomain (PACKAGE, LOCALEDIR);
  textdomain (PACKAGE);

  atexit (close_stdout);

  parse_long_options (argc, argv, PROGRAM_NAME, PACKAGE_NAME, Version,
                      usage, AUTHORS, (char const *) NULL);
  if (getopt_long (argc, argv, "", NULL, NULL) != -1)
    usage (EXIT_FAILURE);

  if (argc == 1)
    {
      error (0, 0, _("missing operand"));
      usage (EXIT_FAILURE);
    }

  for (i = optind; i < argc; i++)
    {
      double s;
      s = csolve_body_hoist(argv[i], &ok);
//      const char * ARRAY p;
//      if (! xstrtod (argv[i], &p, &s, c_strtod)
//          /* Nonnegative interval.  */
//          || ! (0 <= s)
//          /* No extra chars after the number and an optional s,m,h,d char.  */
//          || (*p && *(p+1))
//          /* Check any suffix char and update S based on the suffix.  */
//          || ! apply_suffix (&s, *p))
//        {
//          error (0, 0, _("invalid time interval %s"), quote (argv[i]));
//          ok = false;
//        }
      seconds += s;
    }

  if (!ok)
    usage (EXIT_FAILURE);

  if (xnanosleep (seconds))
    error (EXIT_FAILURE, errno, _("cannot read realtime clock"));

  //exit (EXIT_SUCCESS);// JHALA: THIS THROWS SOME ERROR
  return 0;             // JHALA: THIS IS SAFE!!
}
