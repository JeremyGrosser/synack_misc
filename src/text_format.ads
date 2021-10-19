with HAL.Real_Time_Clock; use HAL.Real_Time_Clock;
with HAL;

package Text_Format is

   subtype Number_Base is Positive range 2 .. 16;

   function From_Natural
      (N    : Natural;
       Base : Number_Base := 10)
       return String;

   function From_Integer
      (N    : Integer;
       Base : Number_Base := 10)
       return String;

   procedure From_Natural
      (N    : Natural;
       Str  : out String);

   function ISO_Date
      (Date        : RTC_Date;
       Year_Offset : Integer := 2000)
       return String;

   subtype ISO_Time_String is String (1 .. 8);

   function ISO_Time
      (Time : RTC_Time)
      return ISO_Time_String;

   function From_ISO_Time
      (Time : ISO_Time_String)
      return RTC_Time;

   function ISO_Date_Time
      (Date        : RTC_Date;
       Time        : RTC_Time;
       Year_Offset : Integer := 2000)
       return String;

   --  Truncates to tenths
   function From_Float
      (F : Float)
      return String;

   subtype Hex_String is String (1 .. 2);

   function Hex
      (Data : HAL.UInt8)
      return Hex_String;

   procedure Hex
      (Data : HAL.UInt8_Array;
       Str  : out String);

   function Hex
      (Data : HAL.UInt8_Array)
      return String;

   function From_UInt8_Array
      (Data : HAL.UInt8_Array)
      return String;

   function To_UInt8_Array
      (S : String)
      return HAL.UInt8_Array;

end Text_Format;
