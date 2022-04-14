--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Galois Linear Feedback Shift Register
--  https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Galois_LFSRs

package body LFSR is

   function Next
      return Random_Type
   is
      N    : Random_Type := State;
      LSB  : Random_Type;
   begin
      loop
         LSB := N and 1;
         N := N / 2;
         N := N xor ((-LSB) and Taps);
         exit when N /= State;
      end loop;
      State := N;
      return N;
   end Next;

   function In_Range
      (First, Last : Random_Type)
      return Random_Type
   is (First + (Next mod (Last - First + 1)));

end LFSR;
