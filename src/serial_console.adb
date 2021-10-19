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
      if not This.Output_Enable then
         return;
      end if;
      This.UART.Transmit (Data, Status, 0);
      if Status /= Ok then
         raise Console_Error;
      end if;
   end Put;

   procedure Put
      (This : in out Port;
       Item : String)
   is
      Data   : UART_Data_8b (Item'Range)
         with Address => Item'Address;
      Status : UART_Status;
   begin
      if not This.Output_Enable then
         return;
      end if;
      This.UART.Transmit (Data, Status, 0);
      if Status /= Ok then
         raise Console_Error;
      end if;
   end Put;

   procedure Put_Line
      (This : in out Port;
       Item : String)
   is
   begin
      This.Put (Item);
      This.New_Line;
   end Put_Line;

   procedure Get
      (This    : in out Port;
       Ch      : out Character;
       Timeout : Natural := 0)
   is
      Data   : UART_Data_8b (1 .. 1);
      Status : UART_Status := Busy;
   begin
      --  Ignore framing and parity errors
      while Status /= Ok loop
         This.UART.Receive (Data, Status, Timeout);
         if Status = Err_Timeout then
            Ch := ASCII.NUL;
            return;
         end if;
      end loop;
      Ch := Character'Val (Integer (Data (1)));
   end Get;

   procedure Get
      (This : in out Port;
       Item : out String)
   is
      Data   : UART_Data_8b (Item'Range)
         with Address => Item'Address;
      Status : UART_Status := Busy;
   begin
      while Status /= Ok loop
         This.UART.Receive (Data, Status, 0);
      end loop;
   end Get;

   procedure New_Line
      (This : in out Port)
   is
   begin
      This.Put (ASCII.CR & ASCII.LF);
   end New_Line;

   function Get_Line
      (This    : in out Port;
       Timeout : Natural := 0)
      return String
   is
      Ch : Character;
      I  : Positive := This.Buffer'First;
   begin
      while I <= This.Buffer'Last loop
         Get (This, Ch, Timeout);
         case Ch is
            when ASCII.CR | ASCII.LF =>
               return This.Buffer (This.Buffer'First .. I - 1);
            when ASCII.DEL =>
               if I > This.Buffer'First then
                  I := I - 1;
               end if;
            when ASCII.NUL =>
               return This.Buffer (This.Buffer'First .. I);
            when others =>
               This.Buffer (I) := Ch;
               I := I + 1;
         end case;
      end loop;
      --  Buffer is full but no LF was seen, return the whole thing.
      return This.Buffer;
   end Get_Line;

end Serial_Console;
