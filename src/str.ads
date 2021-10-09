--
--  Copyright (C) 2021 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package Str is
   pragma Pure;

   function Find
      (S : String;
       C : Character)
       return Natural;

   function Contains
      (Haystack, Needle : String)
       return Boolean;

   function Find_Number
      (S : String)
      return Natural;

   function To_Natural
      (S    : String;
       Base : Positive := 10)
      return Natural;

   function Split
      (S         : String;
       Delimiter : Character;
       Skip      : Natural)
       return String;

   function Strip
      (S : String;
       C : Character)
       return String;

   function Trim
      (S     : String;
       Chars : String)
       return String;

   function Starts_With
      (S      : String;
       Prefix : String)
       return Boolean;
end Str;
