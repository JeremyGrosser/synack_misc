--
--  Copyright (C) 2024 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
--  SD card driver for SPI interfaces
--  This is a low speed compatibility mode supported by most cards.
--
--  Sometimes hardware pinouts use the SD naming convention, rather than SPI.
--  Connect the signals as follows:
--
--    CLK   -> CLK
--    CMD   -> MOSI
--    DAT0  -> MISO
--    DAT1  not connected
--    DAT2  not connected
--    DAT3  -> CS
--
--  I strongly recommend wiring a MOSFET to the card's power supply so that you
--  can power cycle it programmatically after any error. Sometimes cards can
--  get into a weird state that only a power cycle can fix.
--
--  If you need to detect the presence of a card, disable all pullups on CS and
--  interrupt on the rising edge. CS must be reconfigured as an output before
--  calling Initialize. Or, you can just poll Initialize until Has_Error
--  returns False.
--
--  CS, MOSI, MISO, and CLK should all have pullup resistors of approximately
--  10k ohm. Most cards will have weak 50k resistors internally.
--
--  If Has_Error returns True, the only way to reset it is to Initialize again.
--  The card might still work after an error, but I wouldn't count on it.
--
--  Call Max_Bus_Speed to get the SPI clock frequency in Hertz. Prior to
--  Initialize, this is set to 400 KHz. After initialization, it may return up
--  to 50 MHz depending on what the card reports.
--
--  Read and Write only support single block operations. Blocks are always 512
--  bytes.
--
--  This driver does not perform any CRC calculation or checking.
--
with HAL.Block_Drivers;
with HAL.GPIO;
with HAL.SPI;
with HAL; use HAL;

package SD_SPI
   with Preelaborate
is
   type Block_Driver
      (Port : not null HAL.SPI.Any_SPI_Port;
       CS   : not null HAL.GPIO.Any_GPIO_Point)
   is new HAL.Block_Drivers.Block_Driver with private;

   procedure Initialize
      (This : in out Block_Driver);

   function Max_Bus_Speed
      (This : Block_Driver)
      return Natural;

   function Has_Error
      (This : Block_Driver)
      return Boolean;

   overriding
   function Read
      (This : in out Block_Driver;
       Block_Number : UInt64;
       Data : out HAL.Block_Drivers.Block)
       return Boolean;

   overriding
   function Write
      (This : in out Block_Driver;
       Block_Number : UInt64;
       Data : HAL.Block_Drivers.Block)
       return Boolean;

private

   type Block_Driver
      (Port : not null HAL.SPI.Any_SPI_Port;
       CS   : not null HAL.GPIO.Any_GPIO_Point)
   is new HAL.Block_Drivers.Block_Driver with record
      Error : Integer := -1;
      SDHC  : Boolean := False;
      Speed : Natural := 400_000;
   end record;

end SD_SPI;
