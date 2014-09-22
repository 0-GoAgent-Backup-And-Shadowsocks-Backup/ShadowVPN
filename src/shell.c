/**
  shell.c

  Copyright (c) 2014 clowwindy

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

*/

#include <stdlib.h>
#include <stdio.h>
#include "shadowvpn.h"
#include "shell.h"

static int shell_run(shadowvpn_args_t *args, int is_up);

int shell_up(shadowvpn_args_t *args) {
  return shell_run(args, 1);
}

int shell_down(shadowvpn_args_t *args) {
  return shell_run(args, 0);
}

static int shell_run(shadowvpn_args_t *args, int is_up) {
  char buf[1024];
  const char *mode, *script;
  int r;
  if (args->mode == SHADOWVPN_MODE_SERVER) {
    mode = "server";
  } else {
    mode = "client";
  }
  if (is_up) {
    script = args->up_script;
  } else {
    script = args->down_script;
  }
  r = snprintf(buf, sizeof(buf), "\"%s\" %s \"%s\" %d", script, mode,
               args->intf, args->mtu);
  if (r > sizeof(buf) - 1) {
    errf("script path too long");
    return -1;
  }
  if (0 != (r = system(buf))) {
    errf("script %s returned non-zero return code: %d", script, r);
    return -1;
  }
  return 0;
}


