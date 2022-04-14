--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL; use HAL;

package LFSR
   with Preelaborate
is

   function Next
      (State : in out UInt32)
      return UInt32;

   function In_Range
      (State : in out UInt32;
       First, Last : UInt32)
      return UInt32;

end LFSR;
