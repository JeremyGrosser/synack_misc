with Ada.Assertions; use Ada.Assertions;
with Ada.Text_IO; use Ada.Text_IO;
with Checksum; use Checksum;

procedure Synack_Misc_Test is
   Sum : UInt8;
begin
   Sum := CRC_8
      (Data    => UInt8_Array'(16#00#, 16#22#),
       Poly    => 16#31#,
       Initial => 16#FF#);
   Assert (Sum = 16#65#);

   Put_Line ("PASS");
end Synack_Misc_Test;
