--
--  Copyright 2021 (C) Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with System.Machine_Code;
with Serial_Console;

package body Last_Chance_Handler is

   Port : HAL.UART.Any_UART_Port := null;

   procedure Initialize
      (UART : not null HAL.UART.Any_UART_Port)
   is
   begin
      Port := UART;
   end Initialize;

   procedure Last_Chance_Handler
      (Source_Location : System.Address;
       Line            : Integer)
   is
      use HAL.UART;
   begin
      if Port /= null then
         declare
            Console : Serial_Console.Port (UART => Port);
         begin
            Console.Put ("Last Chance Handler caught exception at line ");
            Console.Put (Line'Image);
            Console.New_Line;
         end;
      end if;
      System.Machine_Code.Asm ("bkpt #0", Volatile => True);
      loop
         null;
      end loop;
   end Last_Chance_Handler;

end Last_Chance_Handler;
