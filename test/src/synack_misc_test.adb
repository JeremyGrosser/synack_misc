with Ada.Assertions; use Ada.Assertions;
with Ada.Text_IO; use Ada.Text_IO;
with HAL;

with Generic_Ring_Buffers;
with Checksum;

procedure Synack_Misc_Test is
begin
   declare
      use Checksum;
      use HAL;
      Sum : UInt8;
   begin
      Sum := CRC_8
         (Data    => UInt8_Array'(16#00#, 16#22#),
          Poly    => 16#31#,
          Initial => 16#FF#);
      Assert (Sum = 16#65#);
   end;

   declare
      package Character_Buffers is new Generic_Ring_Buffers
         (Capacity     => 16,
          Element_Type => Character);
      use Character_Buffers;
      RB : Ring_Buffer;
   begin
      Clear (RB);
      Assert (Length (RB) = 0);
      Append (RB, 'A');
      Append (RB, 'B');
      Assert (First_Element (RB) = 'A');
      Assert (Last_Element (RB) = 'B');
      Delete_First (RB);
      Assert (First_Element (RB) = 'B');
      Assert (Last_Element (RB) = 'B');
      Delete_Last (RB);
      Assert (Is_Empty (RB));
   end;

   Put_Line ("PASS");
end Synack_Misc_Test;
