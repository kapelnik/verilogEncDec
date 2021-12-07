/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_Code_api.h
 *
 * MATLAB Coder version            : 4.2
 * C/C++ source code generated on  : 07-Dec-2021 12:24:50
 */

#ifndef _CODER_CODE_API_H
#define _CODER_CODE_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_Code_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void Code(real_T V1[8], real_T V2[32], real_T V3[16], real_T S1[4],
                 real_T S2[5], real_T S3[6]);
extern void Code_api(int32_T nlhs, const mxArray *plhs[6]);
extern void Code_atexit(void);
extern void Code_initialize(void);
extern void Code_terminate(void);
extern void Code_xil_shutdown(void);
extern void Code_xil_terminate(void);

#endif

/*
 * File trailer for _coder_Code_api.h
 *
 * [EOF]
 */
