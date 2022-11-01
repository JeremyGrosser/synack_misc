--
--  Copyright 2021 (C) Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Str;

package body Text_Format is

   Numbers    : constant String := "0123456789ABCDEF";
   Max_Digits : constant := 10; -- enough for 2 ** 32

   function From_Natural
      (N    : Natural;
       Base : Number_Base := 10)
      return String
   is
      S : String (1 .. Max_Digits);
      I : Integer := S'Last;
      X : Integer := N;
   begin
      loop
         S (I) := Numbers (Numbers'First + (X mod Base));
         X := X / Base;
         exit when X = 0;
         I := I - 1;
      end loop;
      return S (I .. S'Last);
   end From_Natural;

   function From_Integer
      (N    : Integer;
       Base : Number_Base := 10)
       return String
   is
   begin
      if N < 0 then
         return '-' & From_Natural (Natural (abs N), Base);
      else
         return From_Natural (Natural (N), Base);
      end if;
   end From_Integer;

   procedure From_Natural
      (N    : Natural;
       Str  : out String)
   is
      Base      : constant Number_Base := 10;
      Magnitude : Natural := 1;
      J         : Integer;
   begin
      for I in 0 .. Str'Length - 1 loop
         J := (N / Magnitude) mod Base;
         Str (Str'Last - I) := Numbers (Numbers'First + J);
         Magnitude := Magnitude * Base;
      end loop;
   end From_Natural;

   function From_UInt8_Array
      (Data : HAL.UInt8_Array)
      return String
   is
      S : String (Data'Range);
   begin
      for I in Data'Range loop
         S (I) := Character'Val (Data (I));
      end loop;
      return S;
   end From_UInt8_Array;

   procedure Hex
      (Data : HAL.UInt8_Array;
       Str  : out String)
   is
      I : Integer := Str'Last;
      J : Integer := Data'First;
   begin
      loop
         I := I - 2;
         exit when I < Str'First or J > Data'Last;
         Str (I .. I + 1) := Hex (Data (J));
         J := J + 1;
      end loop;
   end Hex;

   function Hex
      (Data : HAL.UInt8)
      return Hex_String
   is
      use HAL;
      S : Hex_String;
   begin
      S (1) := Numbers (Numbers'First + Integer (Shift_Right (Data, 4)));
      S (2) := Numbers (Numbers'First + Integer (Data and 16#F#));
      return S;
   end Hex;

   function Hex
      (Data      : HAL.UInt8_Array;
       Delimiter : Character := ' ')
      return String
   is
      S      : String (1 .. (Data'Length * 3) - 1) := (others => Delimiter);
      Offset : Integer := S'First;
   begin
      for I in Data'Range loop
         S (Offset .. Offset + 1) := Hex (Data (I));
         Offset := Offset + 3;
      end loop;
      return S;
   end Hex;

   function Hex
      (Data : HAL.UInt16)
      return String
   is
      use HAL;
   begin
      return Hex (UInt8 (Shift_Right (Data, 8))) & Hex (UInt8 (Data and 16#FF#));
   end Hex;

   function ISO_Date
      (Date        : RTC_Date;
       Year_Offset : Integer := 2000)
       return String
   is
      D : String (1 .. 10) := "0000-00-00";
   begin
      From_Natural (Integer (Date.Year) + Year_Offset, D (1 .. 4));
      From_Natural (RTC_Month'Pos (Date.Month) + 1, D (6 .. 7));
      From_Natural (Integer (Date.Day), D (9 .. 10));
      return D;
   end ISO_Date;

   function ISO_Time
      (Time : RTC_Time)
      return ISO_Time_String
   is
      T : String (1 .. 8) := "00:00:00";
   begin
      From_Natural (Integer (Time.Hour), T (1 .. 2));
      From_Natural (Integer (Time.Min), T (4 .. 5));
      From_Natural (Integer (Time.Sec), T (7 .. 8));
      return T;
   end ISO_Time;

   function From_ISO_Time
      (Time : ISO_Time_String)
      return RTC_Time
   is
   begin
      return
         (Hour => RTC_Hour (Str.To_Natural (Time (1 .. 2))),
          Min  => RTC_Minute (Str.To_Natural (Time (4 .. 5))),
          Sec  => RTC_Second (Str.To_Natural (Time (7 .. 8))));
   end From_ISO_Time;

   function ISO_Date_Time
      (Date        : RTC_Date;
       Time        : RTC_Time;
       Year_Offset : Integer := 2000)
       return String
   is (ISO_Date (Date, Year_Offset) & ' ' & ISO_Time (Time));

   function From_Float
      (F    : Float;
       Fore : Positive := 1;
       Aft  : Positive := 3)
      return String
   is
      Sign      : constant String := (if F < 0.0 then "-" else "");
      Fore_Str  : String (1 .. Fore) := (others => '0');
      Aft_Str   : String (1 .. Aft);
      Magnitude : Positive := 1;
      A, B      : Integer;
      N         : Float;
   begin
      if F < 0.0 then
         N := F * (-1.0);
      else
         N := F;
      end if;

      A := Integer (Float'Floor (N));
      B := A mod 10;
      for I in reverse 1 .. Fore loop
         B := A mod 10;
         Fore_Str (I) := Character'Val (Character'Pos ('0') + B);
         A := A / 10;
         exit when A = 0;
      end loop;

      for I in 1 .. Aft loop
         Magnitude := Magnitude * 10;
      end loop;

      A := Integer (N * Float (Magnitude));
      for I in reverse 1 .. Aft loop
         B := A mod 10;
         Aft_Str (I) := Character'Val (Character'Pos ('0') + B);
         if A > 0 then
            A := A / 10;
         end if;
      end loop;

      if Fore_Str'Length > 1 then
         return Sign & Str.Strip_Leading (Fore_Str, '0') & '.' & Aft_Str;
      else
         return Sign & Fore_Str & '.' & Aft_Str;
      end if;
   end From_Float;

   function To_UInt8_Array
      (S : String)
      return HAL.UInt8_Array
   is
      use HAL;
      D : UInt8_Array (S'Range);
   begin
      for I in S'Range loop
         D (I) := UInt8 (Character'Pos (S (I)));
      end loop;
      return D;
   end To_UInt8_Array;

end Text_Format;
