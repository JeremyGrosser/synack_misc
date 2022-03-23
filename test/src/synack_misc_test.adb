with Ada.Assertions; use Ada.Assertions;
with HAL; use HAL;
with Checksum;

procedure Synack_Misc_Test is
   Sum : UInt8;
begin
   Sum := Checksum.CRC_8
      (Data    => UInt8_Array'(16#BE#, 16#EF#),
       Poly    => 16#31#,
       Initial => 16#FF#);
   Assert (Sum = 16#92#);
end Synack_Misc_Test;
