/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_Code_api.c
 *
 * MATLAB Coder version            : 4.2
 * C/C++ source code generated on  : 07-Dec-2021 12:24:50
 */

/* Include Files */
#include "tmwtypes.h"
#include "_coder_Code_api.h"
#include "_coder_Code_mex.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;
emlrtContext emlrtContextGlobal = { true,/* bFirstTime */
  false,                               /* bInitialized */
  131482U,                             /* fVersionInfo */
  NULL,                                /* fErrorFunction */
  "Code",                              /* fFunctionName */
  NULL,                                /* fRTCallStack */
  false,                               /* bDebugMode */
  { 2045744189U, 2170104910U, 2743257031U, 4284093946U },/* fSigWrd */
  NULL                                 /* fSigMem */
};

/* Function Declarations */
static const mxArray *b_emlrt_marshallOut(const real_T u[32]);
static const mxArray *c_emlrt_marshallOut(const real_T u[16]);
static const mxArray *d_emlrt_marshallOut(const real_T u[4]);
static const mxArray *e_emlrt_marshallOut(const real_T u[5]);
static const mxArray *emlrt_marshallOut(const real_T u[8]);
static const mxArray *f_emlrt_marshallOut(const real_T u[6]);

/* Function Definitions */

/*
 * Arguments    : const real_T u[32]
 * Return Type  : const mxArray *
 */
static const mxArray *b_emlrt_marshallOut(const real_T u[32])
{
  const mxArray *y;
  const mxArray *m1;
  static const int32_T iv2[2] = { 0, 0 };

  static const int32_T iv3[2] = { 1, 32 };

  y = NULL;
  m1 = emlrtCreateNumericArray(2, iv2, mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m1, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m1, *(int32_T (*)[2])&iv3[0], 2);
  emlrtAssign(&y, m1);
  return y;
}

/*
 * Arguments    : const real_T u[16]
 * Return Type  : const mxArray *
 */
static const mxArray *c_emlrt_marshallOut(const real_T u[16])
{
  const mxArray *y;
  const mxArray *m2;
  static const int32_T iv4[2] = { 0, 0 };

  static const int32_T iv5[2] = { 1, 16 };

  y = NULL;
  m2 = emlrtCreateNumericArray(2, iv4, mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m2, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m2, *(int32_T (*)[2])&iv5[0], 2);
  emlrtAssign(&y, m2);
  return y;
}

/*
 * Arguments    : const real_T u[4]
 * Return Type  : const mxArray *
 */
static const mxArray *d_emlrt_marshallOut(const real_T u[4])
{
  const mxArray *y;
  const mxArray *m3;
  static const int32_T iv6[2] = { 0, 0 };

  static const int32_T iv7[2] = { 1, 4 };

  y = NULL;
  m3 = emlrtCreateNumericArray(2, iv6, mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m3, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m3, *(int32_T (*)[2])&iv7[0], 2);
  emlrtAssign(&y, m3);
  return y;
}

/*
 * Arguments    : const real_T u[5]
 * Return Type  : const mxArray *
 */
static const mxArray *e_emlrt_marshallOut(const real_T u[5])
{
  const mxArray *y;
  const mxArray *m4;
  static const int32_T iv8[2] = { 0, 0 };

  static const int32_T iv9[2] = { 1, 5 };

  y = NULL;
  m4 = emlrtCreateNumericArray(2, iv8, mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m4, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m4, *(int32_T (*)[2])&iv9[0], 2);
  emlrtAssign(&y, m4);
  return y;
}

/*
 * Arguments    : const real_T u[8]
 * Return Type  : const mxArray *
 */
static const mxArray *emlrt_marshallOut(const real_T u[8])
{
  const mxArray *y;
  const mxArray *m0;
  static const int32_T iv0[2] = { 0, 0 };

  static const int32_T iv1[2] = { 1, 8 };

  y = NULL;
  m0 = emlrtCreateNumericArray(2, iv0, mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m0, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m0, *(int32_T (*)[2])&iv1[0], 2);
  emlrtAssign(&y, m0);
  return y;
}

/*
 * Arguments    : const real_T u[6]
 * Return Type  : const mxArray *
 */
static const mxArray *f_emlrt_marshallOut(const real_T u[6])
{
  const mxArray *y;
  const mxArray *m5;
  static const int32_T iv10[2] = { 0, 0 };

  static const int32_T iv11[2] = { 1, 6 };

  y = NULL;
  m5 = emlrtCreateNumericArray(2, iv10, mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m5, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m5, *(int32_T (*)[2])&iv11[0], 2);
  emlrtAssign(&y, m5);
  return y;
}

/*
 * Arguments    : int32_T nlhs
 *                const mxArray *plhs[6]
 * Return Type  : void
 */
void Code_api(int32_T nlhs, const mxArray *plhs[6])
{
  real_T (*V1)[8];
  real_T (*V2)[32];
  real_T (*V3)[16];
  real_T (*S1)[4];
  real_T (*S2)[5];
  real_T (*S3)[6];
  V1 = (real_T (*)[8])mxMalloc(sizeof(real_T [8]));
  V2 = (real_T (*)[32])mxMalloc(sizeof(real_T [32]));
  V3 = (real_T (*)[16])mxMalloc(sizeof(real_T [16]));
  S1 = (real_T (*)[4])mxMalloc(sizeof(real_T [4]));
  S2 = (real_T (*)[5])mxMalloc(sizeof(real_T [5]));
  S3 = (real_T (*)[6])mxMalloc(sizeof(real_T [6]));

  /* Invoke the target function */
  Code(*V1, *V2, *V3, *S1, *S2, *S3);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(*V1);
  if (nlhs > 1) {
    plhs[1] = b_emlrt_marshallOut(*V2);
  }

  if (nlhs > 2) {
    plhs[2] = c_emlrt_marshallOut(*V3);
  }

  if (nlhs > 3) {
    plhs[3] = d_emlrt_marshallOut(*S1);
  }

  if (nlhs > 4) {
    plhs[4] = e_emlrt_marshallOut(*S2);
  }

  if (nlhs > 5) {
    plhs[5] = f_emlrt_marshallOut(*S3);
  }
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void Code_atexit(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  Code_xil_terminate();
  Code_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void Code_initialize(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void Code_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/*
 * File trailer for _coder_Code_api.c
 *
 * [EOF]
 */
