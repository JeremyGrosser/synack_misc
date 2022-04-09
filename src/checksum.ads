--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL; use HAL;

package Checksum
   with Pure
is

   function CRC_8
      (Data    : UInt8_Array;
       Poly    : UInt8 := 16#31#;
       Initial : UInt8 := 16#FF#)
      return UInt8;

end Checksum;
