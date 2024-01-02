--
--  Copyright (C) 2024 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
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
   end record;

end SD_SPI;
