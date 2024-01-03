--
--  Copyright (C) 2024 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Ada.Unchecked_Conversion;

package body SD_SPI is

   function Has_Error
      (This : Block_Driver)
      return Boolean
   is (This.Error >= 0);

   function Max_Bus_Speed_KHz
      (This : Block_Driver)
      return Natural
   is (This.Speed_KHz);

   procedure Set_CS
      (This : Block_Driver;
       High : Boolean)
   is
   begin
      if High then
         This.CS.Set;
      else
         This.CS.Clear;
      end if;
   end Set_CS;

   procedure SPI_Write
      (This : Block_Driver;
       Data : UInt8_Array)
   is
      use HAL.SPI;
      X : SPI_Data_8b (1 .. 1);
      Status : SPI_Status;
   begin
      for D of Data loop
         X (1) := D;
         This.Port.Transmit (X, Status, Timeout => 0);
         This.Port.Receive (X, Status, Timeout => 0);
      end loop;
   end SPI_Write;

   procedure SPI_Read
      (This : Block_Driver;
       Data : out UInt8_Array;
       Reverse_Order : Boolean := False)
   is
      use HAL.SPI;
      Status : SPI_Status;
   begin
      if not Reverse_Order then
         for I in Data'Range loop
            This.Port.Transmit (SPI_Data_8b'(1 => 16#FF#), Status, Timeout => 0);
            This.Port.Receive (SPI_Data_8b (Data (I .. I)), Status, Timeout => 0);
         end loop;
      else
         for I in reverse Data'Range loop
            This.Port.Transmit (SPI_Data_8b'(1 => 16#FF#), Status, Timeout => 0);
            This.Port.Receive (SPI_Data_8b (Data (I .. I)), Status, Timeout => 0);
         end loop;
      end if;
   end SPI_Read;

   procedure SPI_Write
      (This : Block_Driver;
       Data : UInt8)
   is
   begin
      SPI_Write (This, UInt8_Array'(1 => Data));
   end SPI_Write;

   function SPI_Read
      (This : Block_Driver)
      return UInt8
   is
      Data : UInt8_Array (1 .. 1);
   begin
      SPI_Read (This, Data);
      return Data (1);
   end SPI_Read;

   procedure Sync
      (This  : Block_Driver;
       Token : UInt8 := 16#FF#)
   is
      use HAL.SPI;
      Data : SPI_Data_8b (1 .. 1);
      Status : SPI_Status;
   begin
      loop
         Data (1) := 16#FF#;
         This.Port.Transmit (Data, Status, Timeout => 0);
         This.Port.Receive (Data, Status, Timeout => 0);
         exit when Data (1) = Token;
      end loop;
   end Sync;

   function Read_R1
      (This : Block_Driver)
      return UInt8
   is
      R1 : UInt8;
   begin
      for I in 1 .. 4 loop
         R1 := SPI_Read (This);
         exit when R1 /= 16#FF#;
      end loop;
      return R1;
   end Read_R1;

   procedure Send_Command
      (This : Block_Driver;
       Cmd  : UInt8;
       Arg  : UInt32;
       CRC  : UInt8;
       R1   : out UInt8)
   is
   begin
      Sync (This);
      SPI_Write (This,
         (1 => 16#40# or Cmd,
          2 => UInt8 (Shift_Right (Arg, 24) and 16#FF#),
          3 => UInt8 (Shift_Right (Arg, 16) and 16#FF#),
          4 => UInt8 (Shift_Right (Arg, 8) and 16#FF#),
          5 => UInt8 (Shift_Right (Arg, 0) and 16#FF#),
          6 => CRC));
      R1 := Read_R1 (This);
   end Send_Command;

   procedure GO_IDLE
      (This : in out Block_Driver)
   is
      Preamble : constant UInt8_Array (1 .. 16) := (others => 16#FF#);
      R1 : UInt8;
   begin
      Set_CS (This, True);
      SPI_Write (This, Preamble);
      Set_CS (This, False);
      Send_Command (This, 0, 0, 16#95#, R1);
      Set_CS (This, True);
      if R1 /= 1 then
         This.Error := 0;
      end if;
   end GO_IDLE;

   procedure SEND_OP_COND
      (This : in out Block_Driver)
   is
      R1 : UInt8;
   begin
      Set_CS (This, False);
      Send_Command (This, 1, 0, 16#F9#, R1);
      if R1 /= 1 then
         This.Error := 1;
      end if;
      Set_CS (This, True);
   end SEND_OP_COND;

   procedure SEND_IF_COND
      (This : in out Block_Driver)
   is
      R1 : UInt8;
      R7 : UInt8_Array (1 .. 4);
   begin
      Set_CS (This, False);
      Send_Command (This, 8, 16#0000_01AA#, 16#87#, R1);

      if R1 /= 1 then
         This.Error := 8;
      end if;

      SPI_Read (This, R7);
      if R7 /= (16#00#, 16#00#, 16#01#, 16#AA#) then
         This.Error := 8;
      end if;
      Set_CS (This, True);
   end SEND_IF_COND;

   procedure SD_SEND_OP_COND
      (This : in out Block_Driver)
   is
      R1 : UInt8;
      R3 : UInt32 := 0;
   begin
      for I in 1 .. 500 loop
         Set_CS (This, False);
         Send_Command (This, 55, 0, 16#65#, R1);
         Set_CS (This, True);

         if R1 = 1 then
            Set_CS (This, False);
            --  HCS=1, XPC=1, S18R=0,
            Send_Command (This, 41, 16#4010_0000#, 16#77#, R1);
            for I in 1 .. 4 loop
               R3 := Shift_Left (R3, 8) or UInt32 (SPI_Read (This));
            end loop;
            Set_CS (This, True);

            case R1 is
               when 0 =>
                  --  Card init done
                  return;
               when 1 =>
                  --  Card is not ready, retry
                  null;
               when others =>
                  --  R1=5 might mean this is a very old card.
                  This.Error := 41;
                  return;
            end case;
         elsif R1 = 5 then
            --  V1 MMC card, ACMD41 not supported
            SEND_OP_COND (This);
            return;
         else
            This.Error := 55;
         end if;
      end loop;

      This.Error := 41;
   end SD_SEND_OP_COND;

   procedure SET_BLOCKLEN
      (This : in out Block_Driver)
   is
      R1 : UInt8;
   begin
      Set_CS (This, False);
      Send_Command (This, 16, 512, 16#55#, R1);
      if R1 /= 0 then
         This.Error := 16;
      end if;
      Set_CS (This, True);
   end SET_BLOCKLEN;

   procedure READ_OCR
      (This : in out Block_Driver)
   is
      R1 : UInt8;
      OCR : UInt32 := 0;
   begin
      Set_CS (This, False);
      Send_Command (This, 58, 0, 16#55#, R1);
      if R1 /= 0 then
         This.Error := 58;
      else
         for I in 1 .. 4 loop
            OCR := Shift_Left (OCR, 8) or UInt32 (SPI_Read (This));
         end loop;
         This.SDHC := (OCR and 16#C000_0000#) = 16#C000_0000#;
         --  If the CCS bit and Card Power Up Status bits are set then this is
         --  an SDHC card
      end if;
      Set_CS (This, True);
   end READ_OCR;

   procedure SEND_CSD
      (This : in out Block_Driver)
   is
      type CSD_Register is record
         TRAN_SPEED_UNIT   : UInt3;
         TRAN_SPEED_TIME   : UInt4;
      end record
         with Size => 128;
      for CSD_Register use record
         TRAN_SPEED_UNIT   at 0 range 96 .. 98;
         TRAN_SPEED_TIME   at 0 range 99 .. 103;
      end record;

      subtype CSD_Bytes is UInt8_Array (1 .. CSD_Register'Size / 8);
      function To_CSD_Register is new Ada.Unchecked_Conversion
         (UInt8_Array, CSD_Register);

      --  Table 5-6: Maximum Data Transfer Rate Definition
      TS_MUL : constant array (UInt4) of Natural :=
         (0 => 0_4,
          1 => 1_0,
          2 => 1_2,
          3 => 1_3,
          4 => 1_5,
          5 => 2_0,
          6 => 2_5,
          7 => 3_0,
          8 => 3_5,
          9 => 4_0,
          10 => 4_5,
          11 => 5_0,
          12 => 5_5,
          13 => 6_0,
          14 => 7_0,
          15 => 8_0);

      CSD_Data : CSD_Bytes;
      CSD : CSD_Register;

      R1 : UInt8;
   begin
      Set_CS (This, False);
      Send_Command (This, 9, 0, 16#55#, R1);
      if R1 /= 0 then
         This.Error := 9;
      else
         Sync (This, 16#FE#);
         SPI_Read (This, CSD_Data, Reverse_Order => True);
         CSD := To_CSD_Register (CSD_Data);

         This.Speed_KHz := (10 ** (Natural (CSD.TRAN_SPEED_UNIT) + 1)) * TS_MUL (CSD.TRAN_SPEED_TIME);
      end if;
      Set_CS (This, True);
   end SEND_CSD;

   procedure Initialize
      (This : in out Block_Driver)
   is
   begin
      This.Error := -1;
      This.Speed_KHz := 400;

      GO_IDLE (This);
      if Has_Error (This) then
         return;
      end if;

      SEND_IF_COND (This);
      if Has_Error (This) then
         return;
      end if;

      SD_SEND_OP_COND (This);
      if Has_Error (This) then
         return;
      end if;

      READ_OCR (This);
      if Has_Error (This) then
         return;
      end if;

      SET_BLOCKLEN (This);
      if Has_Error (This) then
         return;
      end if;

      SEND_CSD (This);
      if Has_Error (This) then
         return;
      end if;
   end Initialize;

   procedure Wait_For_Idle
      (This : Block_Driver)
   is
      R1, R2 : UInt8;
   begin
      Set_CS (This, False);
      loop
         Send_Command (This, 13, 0, 16#0D#, R1);
         R2 := SPI_Read (This);
         exit when R1 = 0 and then R2 = 0;
      end loop;
      Set_CS (This, True);
   end Wait_For_Idle;

   function Block_Offset
      (This : Block_Driver;
       Addr : UInt64)
      return UInt32
   is (if This.SDHC then UInt32 (Addr) else UInt32 (Addr * 512));

   overriding
   function Read
      (This : in out Block_Driver;
       Block_Number : UInt64;
       Data : out HAL.Block_Drivers.Block)
       return Boolean
   is
      R1 : UInt8;
   begin
      Set_CS (This, False);
      Send_Command (This, 17, Block_Offset (This, Block_Number), 16#55#, R1);
      if R1 = 0 then
         Sync (This, 16#FE#);
         SPI_Read (This, Data);
         R1 := SPI_Read (This); --  CRC16
         R1 := SPI_Read (This); --  CRC16
         Sync (This);
      else
         This.Error := 17;
      end if;
      Set_CS (This, True);
      return not Has_Error (This);
   end Read;

   overriding
   function Write
      (This : in out Block_Driver;
       Block_Number : UInt64;
       Data : HAL.Block_Drivers.Block)
       return Boolean
   is
      R1 : UInt8;
   begin
      Set_CS (This, False);
      Send_Command (This, 24, Block_Offset (This, Block_Number), 16#55#, R1);
      if R1 = 0 then
         Sync (This);
         SPI_Write (This, 16#FE#); --  Start block
         SPI_Write (This, Data);
         SPI_Write (This, 16#DE#); --  CRC16
         SPI_Write (This, 16#AD#);
         R1 := SPI_Read (This);
         Wait_For_Idle (This);
      else
         This.Error := 24;
      end if;
      Set_CS (This, True);
      return not Has_Error (This);
   end Write;

   procedure Read_Multiple
      (This : in out Block_Driver;
       Block_Number : UInt64;
       Data : out Block_Array;
       Last : out Natural)
   is
      Offset : constant UInt32 := Block_Offset (This, Block_Number);
      Token : UInt8;
      R1 : UInt8;
      CRC : UInt8;
   begin
      Last := Data'First - 1;
      Set_CS (This, False);
      Send_Command (This, 18, Offset, 16#55#, R1);
      if R1 = 0 then
         for I in Data'Range loop
            --  Like Sync, but with error token handling
            loop
               Token := SPI_Read (This);
               exit when Token = 16#FE#;
               if (Token and 16#F0#) = 0 and then (Token and 16#0F#) /= 0 then
                  --  Data error, abort
                  This.Error := 18;
                  Set_CS (This, True);
                  return;
               end if;
            end loop;

            SPI_Read (This, Data (I));
            CRC := SPI_Read (This);
            CRC := SPI_Read (This);
            Last := I;
         end loop;
         Send_Command (This, 12, 0, 16#55#, R1);
      end if;
      Set_CS (This, True);
   end Read_Multiple;

   procedure Write_Multiple
      (This : in out Block_Driver;
       Block_Number : UInt64;
       Data : Block_Array;
       Last : out Natural)
   is
      Offset : constant UInt32 := Block_Offset (This, Block_Number);
      Token : UInt8;
      R1 : UInt8;
      CRC : UInt8;
   begin
      Last := Data'First - 1;
      Set_CS (This, False);
      Send_Command (This, 25, Offset, 16#55#, R1);
      if R1 = 0 then
         SPI_Write (This, 16#FC#);
         for I in Data'Range loop
            SPI_Write (This, Data (I));
            SPI_Write (This, 16#55#); --  CRC
            SPI_Write (This, 16#55#);
            R1 := SPI_Read (This);
            Sync (This);
            if (R1 and 16#F0#) = 0 and then (R1 and 16#0F#) /= 0 then
               This.Error := 25;
               Set_CS (This, True);
               return;
            end if;
            Last := I;
         end loop;
         SPI_Write (This, 16#FD#); --  Stop Tran
         Sync (This);
      else
         This.Error := 25;
      end if;
      Set_CS (This, True);
   end Write_Multiple;

end SD_SPI;
