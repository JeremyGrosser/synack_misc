--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Galois Linear Feedback Shift Register
--  https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Galois_LFSRs

generic
   type Random_Type is mod <>;
   Taps : Random_Type;
package LFSR is

   State : Random_Type := Random_Type'Last;

   function Next
      return Random_Type;

   function In_Range
      (First, Last : Random_Type)
      return Random_Type;

end LFSR;
