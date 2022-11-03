--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Bit-banging a SPI master using arbitrary GPIO pins
--  SPI Mode 0 (CPOL=0, CPHA=0). Other modes are not implemented.
with Chests.Ring_Buffers;
with HAL.GPIO;
with HAL.Time;
with HAL.SPI;
with HAL;

package Soft_SPI
   with Preelaborate
is
   package Byte_Buffers is new Chests.Ring_Buffers
      (Element_Type => HAL.UInt8,
       Capacity     => 16);

   type SPI_Port
      (CLK        : not null HAL.GPIO.Any_GPIO_Point;
       MOSI       : not null HAL.GPIO.Any_GPIO_Point;
       MISO       : not null HAL.GPIO.Any_GPIO_Point;
       Delays     : not null HAL.Time.Any_Delays)
   is new HAL.SPI.SPI_Port with record
      T_High, T_Low : Natural := 100; --  microseconds between edges
      FIFO : Byte_Buffers.Ring_Buffer;
   end record;
   --  CLK speed is determined by (T_High + T_Low), which are passed to
   --  Delay_Microseconds between edges. This is unlikely to be accurate at
   --  high speeds.

   procedure Transfer
      (This : in out SPI_Port;
       Data : in out HAL.UInt8);
   --  Clock a single byte to MOSI. MISO is written back to Data. Does not
   --  interact with the FIFO.

   overriding
   function Data_Size
      (This : SPI_Port)
      return HAL.SPI.SPI_Data_Size;
   --  Only Data_Size_8b is supported.

   overriding
   procedure Transmit
      (This    : in out SPI_Port;
       Data    : HAL.SPI.SPI_Data_8b;
       Status  : out HAL.SPI.SPI_Status;
       Timeout : Natural := 1_000);
   --  Transmit drives CLK. As data is clocked out, received bytes are stored
   --  in This.FIFO. If the FIFO is full, the oldest byte is dropped.
   --  Timeout is not implemented.

   overriding
   procedure Transmit
      (This    : in out SPI_Port;
       Data    : HAL.SPI.SPI_Data_16b;
       Status  : out HAL.SPI.SPI_Status;
       Timeout : Natural := 1_000);
   --  Not implemented

   overriding
   procedure Receive
      (This    : in out SPI_Port;
       Data    : out HAL.SPI.SPI_Data_8b;
       Status  : out HAL.SPI.SPI_Status;
       Timeout : Natural := 1_000);
   --  Reads from the FIFO into Data. If Data'Length > Length (This.FIFO),
   --  Status will be set to Err_Error.
   --  Timeout is not implemented.

   overriding
   procedure Receive
      (This    : in out SPI_Port;
       Data    : out HAL.SPI.SPI_Data_16b;
       Status  : out HAL.SPI.SPI_Status;
       Timeout : Natural := 1_000);
   --  Not implemented

end Soft_SPI;
