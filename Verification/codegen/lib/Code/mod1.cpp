//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: mod1.cpp
//
// MATLAB Coder version            : 4.2
// C/C++ source code generated on  : 07-Dec-2021 12:24:50
//

// Include Files
#include <cmath>
#include "rt_nonfinite.h"
#include "Code.h"
#include "mod1.h"

// Function Definitions

//
// Arguments    : double x
// Return Type  : double
//
double floatmod(double x)
{
  double r;
  if (rtIsNaN(x) || rtIsInf(x)) {
    r = rtNaN;
  } else if (x == 0.0) {
    r = 0.0;
  } else {
    r = std::fmod(x, 2.0);
    if (r == 0.0) {
      r = 0.0;
    } else {
      if (x < 0.0) {
        r += 2.0;
      }
    }
  }

  return r;
}

//
// File trailer for mod1.cpp
//
// [EOF]
//
