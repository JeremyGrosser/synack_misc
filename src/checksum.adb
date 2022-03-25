package body Checksum is

   function CRC_8
      (Data    : UInt8_Array;
       Poly    : UInt8 := 16#31#;
       Initial : UInt8 := 16#FF#)
      return UInt8
   is
      CRC : UInt8 := Initial;
   begin
      for D of Data loop
         CRC := CRC xor D;
         for I in 1 .. 8 loop
            if (CRC and 16#80#) /= 0 then
               CRC := (CRC * 2) xor Poly;
            else
               CRC := (CRC * 2);
            end if;
         end loop;
      end loop;
      return CRC;
   end CRC_8;

end Checksum;
