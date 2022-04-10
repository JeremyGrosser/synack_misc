--
--  Copyright 2021 (C) Jeremy Grosser
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL; use HAL;

package body Serial_Console is
   use HAL.UART;

   procedure Put
      (This : in out Port;
       Item : Character)
   is
      Data   : constant UART_Data_8b (1 .. 1) := (1 => UInt8 (Character'Pos (Item)));
      Status : UART_Status;
   begin
      This.UART.Transmit (Data, Status, Timeout => 0);
   end Put;

   procedure Put
      (This : in out Port;
       Item : String)
   is
      Data   : UART_Data_8b (Item'Range)
         with Address => Item'Address;
      Status : UART_Status;
   begin
      This.UART.Transmit (Data, Status, Timeout => 0);
   end Put;

   procedure New_Line
      (This : in out Port)
   is
   begin
      This.Put (ASCII.CR & ASCII.LF);
   end New_Line;

   procedure Put_Line
      (This : in out Port;
       Item : String)
   is
   begin
      This.Put (Item);
      This.New_Line;
   end Put_Line;

   procedure Get
      (This : in out Port;
       Ch   : out Character)
   is
      use Character_Buffers;
   begin
      while Is_Empty (This.RX_Buffer) loop
         null;
      end loop;

      Ch := First_Element (This.RX_Buffer);
      Delete_First (This.RX_Buffer);
   end Get;

   procedure Get
      (This : in out Port;
       Item : out String)
   is
   begin
      for I in Item'Range loop
         This.Get (Item (I));
      end loop;
   end Get;

   procedure Get_Nonblocking
      (This : in out Port;
       Ch   : out Character)
   is
      use Character_Buffers;
   begin
      if Is_Empty (This.RX_Buffer) then
         Ch := ASCII.NUL;
      else
         Ch := First_Element (This.RX_Buffer);
         Delete_First (This.RX_Buffer);
      end if;
   end Get_Nonblocking;

   function Buffer_Size
      (This : Port)
      return Natural
   is (Character_Buffers.Length (This.RX_Buffer));

   procedure Poll
      (This : in out Port)
   is
      use Character_Buffers;
      Status : UART_Status;
      Data   : UART_Data_8b (1 .. 1);
      Ch     : Character with Address => Data (1)'Address;
   begin
      if Is_Full (This.RX_Buffer) then
         Delete_First (This.RX_Buffer);
      end if;

      This.UART.Receive (Data, Status, Timeout => 0);
      if Status = Ok then
         Append (This.RX_Buffer, Ch);
      end if;
   end Poll;

end Serial_Console;
