--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Galois Linear Feedback Shift Register
--  https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Galois_LFSRs
package body LFSR is

   State : UInt32 := 16#DEAD#;

   procedure Seed
      (N : UInt32)
   is
   begin
      State := N;
   end Seed;

   function Next
      return UInt32
   is
      Taps : constant UInt32 := 16#B400#;
      N    : UInt32 := State;
      LSB  : UInt32;
   begin
      loop
         LSB := N and 1;
         N := Shift_Right (N, 1);
         N := N xor ((-LSB) and Taps);
         exit when N /= State;
      end loop;
      State := N;
      return N;
   end Next;

   function In_Range
      (First, Last : UInt32)
      return UInt32
   is (First + (Next mod (Last - First + 1)));
end LFSR;
