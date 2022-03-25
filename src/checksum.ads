package Checksum
   with Pure
is
   type UInt8 is mod 2 ** 8
      with Size => 8;
   type UInt8_Array is array (Integer range <>) of UInt8
      with Component_Size => 8;

   function CRC_8
      (Data    : UInt8_Array;
       Poly    : UInt8 := 16#31#;
       Initial : UInt8 := 16#FF#)
      return UInt8;

end Checksum;
