--
--  Copyright 2021 (C) Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.UART;
with System;

package Last_Chance_Handler is

   procedure Initialize
      (UART : not null HAL.UART.Any_UART_Port);

   procedure Last_Chance_Handler
      (Source_Location : System.Address;
       Line            : Integer)
   with No_Return,
        Export,
        Convention    => C,
        External_Name => "__gnat_last_chance_handler";

end Last_Chance_Handler;
