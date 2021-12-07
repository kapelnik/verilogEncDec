//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: Code.cpp
//
// MATLAB Coder version            : 4.2
// C/C++ source code generated on  : 07-Dec-2021 12:24:50
//

// Include Files
#include <string.h>
#include "rt_nonfinite.h"
#include "Code.h"
#include "mod1.h"

// Function Definitions

//
// Arguments    : double V1[8]
//                double V2[32]
//                double V3[16]
//                double S1[4]
//                double S2[5]
//                double S3[6]
// Return Type  : void
//
void Code(double V1[8], double V2[32], double V3[16], double S1[4], double S2[5],
          double S3[6])
{
  static const double dv0[8] = { 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0 };

  static const double dv1[16] = { 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
    1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };

  static const double dv2[32] = { 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0,
    0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0,
    1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };

  double A_idx_0_tmp;
  double B_tmp;
  double B[5];
  double b_B_tmp;
  double C[6];
  double dv3[8];
  int i0;
  int k;
  double dv4[8];
  static const signed char N1[8] = { 1, 0, 1, 0, 0, 0, 0, 0 };

  double Datain2[16];
  static const signed char b_Datain2[11] = { 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0 };

  static const signed char a[32] = { 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1,
    1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1 };

  double c_Datain2[16];
  static const signed char N2[16] = { 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0 };

  double Datain3[32];
  static const signed char b_Datain3[26] = { 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1,
    1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0 };

  static const signed char b_a[80] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0,
    1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1,
    1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1,
    0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1 };

  static const signed char c_a[192] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1,
    1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1,
    1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0,
    1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0,
    1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0,
    1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1 };

  memcpy(&V1[0], &dv0[0], sizeof(double) << 3);
  memcpy(&V3[0], &dv1[0], sizeof(double) << 4);
  memcpy(&V2[0], &dv2[0], sizeof(double) << 5);

  //   Parity building
  A_idx_0_tmp = floatmod(3.0);
  B_tmp = floatmod(6.0);
  B[0] = B_tmp;
  B[1] = B_tmp;
  B[2] = B_tmp;
  B[3] = B_tmp;
  b_B_tmp = floatmod(5.0);
  B[4] = b_B_tmp;
  C[0] = b_B_tmp;
  C[1] = floatmod(8.0);
  C[2] = A_idx_0_tmp;
  C[3] = floatmod(7.0);
  C[4] = B_tmp;
  C[5] = b_B_tmp;

  //  Vector creating
  dv3[0] = 1.0;
  dv3[4] = A_idx_0_tmp;
  dv3[1] = 1.0;
  dv3[5] = A_idx_0_tmp;
  dv3[2] = 1.0;
  dv3[6] = A_idx_0_tmp;
  dv3[3] = 1.0;
  dv3[7] = A_idx_0_tmp;
  for (i0 = 0; i0 < 8; i0++) {
    dv4[i0] = dv3[i0] + static_cast<double>(N1[i0]);
  }

  for (k = 0; k < 4; k++) {
    A_idx_0_tmp = 0.0;
    for (i0 = 0; i0 < 8; i0++) {
      A_idx_0_tmp += static_cast<double>(a[k + (i0 << 2)]) * dv4[i0];
    }

    S1[k] = floatmod(A_idx_0_tmp);
  }

  for (i0 = 0; i0 < 11; i0++) {
    Datain2[i0] = b_Datain2[i0];
  }

  for (i0 = 0; i0 < 5; i0++) {
    Datain2[i0 + 11] = B[i0];
  }

  for (i0 = 0; i0 < 16; i0++) {
    c_Datain2[i0] = Datain2[i0] + static_cast<double>(N2[i0]);
  }

  for (k = 0; k < 5; k++) {
    A_idx_0_tmp = 0.0;
    for (i0 = 0; i0 < 16; i0++) {
      A_idx_0_tmp += static_cast<double>(b_a[k + 5 * i0]) * c_Datain2[i0];
    }

    S2[k] = floatmod(A_idx_0_tmp);
  }

  for (i0 = 0; i0 < 26; i0++) {
    Datain3[i0] = b_Datain3[i0];
  }

  for (i0 = 0; i0 < 6; i0++) {
    Datain3[i0 + 26] = C[i0];
  }

  for (k = 0; k < 6; k++) {
    A_idx_0_tmp = 0.0;
    for (i0 = 0; i0 < 32; i0++) {
      A_idx_0_tmp += static_cast<double>(c_a[k + 6 * i0]) * Datain3[i0];
    }

    S3[k] = floatmod(A_idx_0_tmp);
  }

  //  S(1) = mod(sum(D(2:4)) + A(1),2);
  //  S(2) = mod(D(2)+A(2),2);
  //  S(3) = mod(D(3)+A(3),2)
  //  S(4) = mod(D(4)+A(4),2)
  //  % S(5) = mod(D(5)+C(5),2)
  //  % S(6) = mod(D(6)+C(6),2)
}

//
// File trailer for Code.cpp
//
// [EOF]
//
