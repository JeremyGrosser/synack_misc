with Ada.Assertions; use Ada.Assertions;
with Ada.Text_IO; use Ada.Text_IO;
with Text_Format; use Text_Format;
with HAL; use HAL;
with Checksum;

procedure Synack_Misc_Test is
   Sum : UInt8;
begin
   Sum := Checksum.CRC_8
      (Data    => UInt8_Array'(16#BE#, 16#EF#),
       Poly    => 16#31#,
       Initial => 16#FF#);
   Put_Line (Hex (Sum));

   Assert (Sum = 16#92#);
end Synack_Misc_Test;
