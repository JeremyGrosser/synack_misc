package body Soft_SPI is

   overriding
   function Data_Size
      (This : SPI_Port)
      return HAL.SPI.SPI_Data_Size
   is (HAL.SPI.Data_Size_8b);

   procedure Transfer
      (This : in out SPI_Port;
       Data : in out HAL.UInt8)
   is
      use HAL;
      Mask : UInt8;
   begin

      for Bit in reverse 0 .. Data'Size - 1 loop
         Mask := Shift_Left (1, Bit);
         if (Data and Mask) = 0 then
            This.MOSI.Clear;
         else
            This.MOSI.Set;
         end if;

         This.CLK.Set;
         This.Delays.Delay_Microseconds (This.T_High);

         if This.MISO.Set then
            Data := Data or Mask;
         else
            Data := Data and not Mask;
         end if;

         This.CLK.Clear;
         This.Delays.Delay_Microseconds (This.T_Low);
      end loop;
   end Transfer;

   overriding
   procedure Transmit
      (This    : in out SPI_Port;
       Data    : HAL.SPI.SPI_Data_8b;
       Status  : out HAL.SPI.SPI_Status;
       Timeout : Natural := 1_000)
   is
      use Byte_Buffers;
      D : HAL.UInt8;
   begin
      for I in Data'Range loop
         D := Data (I);
         This.Transfer (D);
         if Is_Full (This.FIFO) then
            Delete_First (This.FIFO);
         end if;
         Append (This.FIFO, D);
      end loop;
      Status := HAL.SPI.Ok;
   end Transmit;

   overriding
   procedure Receive
      (This    : in out SPI_Port;
       Data    : out HAL.SPI.SPI_Data_8b;
       Status  : out HAL.SPI.SPI_Status;
       Timeout : Natural := 1_000)
   is
      use Byte_Buffers;
   begin
      for I in Data'Range loop
         if Is_Empty (This.FIFO) then
            Status := HAL.SPI.Err_Error;
            return;
         end if;
         Data (I) := First_Element (This.FIFO);
         Delete_First (This.FIFO);
      end loop;
      Status := HAL.SPI.Ok;
   end Receive;

   overriding
   procedure Transmit
      (This    : in out SPI_Port;
       Data    : HAL.SPI.SPI_Data_16b;
       Status  : out HAL.SPI.SPI_Status;
       Timeout : Natural := 1_000)
   is
      pragma Unreferenced (This);
      pragma Unreferenced (Data);
   begin
      Status := HAL.SPI.Err_Error;
   end Transmit;

   overriding
   procedure Receive
      (This    : in out SPI_Port;
       Data    : out HAL.SPI.SPI_Data_16b;
       Status  : out HAL.SPI.SPI_Status;
       Timeout : Natural := 1_000)
   is
      pragma Unreferenced (This);
      pragma Unreferenced (Data);
   begin
      Status := HAL.SPI.Err_Error;
   end Receive;

end Soft_SPI;
