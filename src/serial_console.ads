--
--  Copyright 2021 (C) Jeremy Grosser
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Chests.Ring_Buffers;
with HAL.UART;

package Serial_Console is

   type Port
      (UART : not null HAL.UART.Any_UART_Port)
   is tagged private;

   procedure Put
      (This : in out Port;
       Item : Character);

   procedure Put
      (This : in out Port;
       Item : String);

   procedure New_Line
      (This : in out Port);

   procedure Put_Line
      (This : in out Port;
       Item : String);

   procedure Get
      (This : in out Port;
       Ch   : out Character);
   --  If the RX buffer is empty, Get will block

   procedure Get_Nonblocking
      (This : in out Port;
       Ch   : out Character);
   --  If the receive buffer is empty, Get_Nonblocking will set Ch := ASCII.NUL
   --  and return immediately

   function Buffer_Size
      (This : Port)
      return Natural;

   procedure Get
      (This : in out Port;
       Item : out String);
   --  Get will block until Item'Length characters are received from the buffer

   procedure Poll
      (This : in out Port);
   --  Poll should be called upon receiving a UART interrupt, it will read a
   --  single byte into the buffer for Get.
   --
   --  Poll will block if no data is available from the UART
   --  If the buffer is full, Poll will delete the oldest character in the buffer.

private

   package Character_Buffers is new Chests.Ring_Buffers
      (Capacity     => 32,
       Element_Type => Character);

   type Port
      (UART : not null HAL.UART.Any_UART_Port)
   is tagged record
      RX_Buffer : Character_Buffers.Ring_Buffer;
   end record;

end Serial_Console;
