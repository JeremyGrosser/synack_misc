--
--  Copyright 2021 (C) Jeremy Grosser
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.UART;

package Serial_Console is

   type Port
      (UART : not null HAL.UART.Any_UART_Port)
   is tagged record
      Output_Enable : Boolean := True;
      Buffer        : String (1 .. 64);
   end record;

   Console_Error : exception;

   procedure Put
      (This : in out Port;
       Item : Character);

   procedure Put
      (This : in out Port;
       Item : String);

   procedure Put_Line
      (This : in out Port;
       Item : String);

   procedure Get
      (This    : in out Port;
       Ch      : out Character;
       Timeout : Natural := 0);

   procedure Get
      (This : in out Port;
       Item : out String);

   procedure New_Line
      (This : in out Port);

   function Get_Line
      (This    : in out Port;
       Timeout : Natural := 0)
      return String;

end Serial_Console;
