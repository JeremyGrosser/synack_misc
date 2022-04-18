--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package body CRC is
   procedure Update
      (Data : Word)
   is
      Bits : constant Positive := Word'Size;
      MSB  : constant Word := 2 ** (Bits - 1);
   begin
      Sum := Sum xor Data;
      for I in 1 .. Bits loop
         if (Sum and MSB) /= 0 then
            Sum := (Sum * 2) xor Poly;
         else
            Sum := (Sum * 2);
         end if;
      end loop;
   end Update;

   procedure Update
      (Data : Word_Array)
   is
   begin
      for D of Data loop
         Update (D);
      end loop;
   end Update;

   function Calculate
      (Data    : Word_Array;
       Initial : Word := 0)
       return Word
   is
   begin
      Sum := Initial;
      Update (Data);
      return Sum;
   end Calculate;
end CRC;
