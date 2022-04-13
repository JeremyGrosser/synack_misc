--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL; use HAL;

package LFSR is

   procedure Seed
      (N : UInt32);

   function Next
      return UInt32;

   function In_Range
      (First, Last : UInt32)
      return UInt32;

end LFSR;
