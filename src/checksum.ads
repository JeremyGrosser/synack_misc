with HAL; use HAL;

package Checksum is

   function CRC_8
      (Data    : UInt8_Array;
       Poly    : UInt8 := 16#31#;
       Initial : UInt8 := 16#FF#)
      return UInt8;

end Checksum;
