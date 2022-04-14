--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
generic
   type Random_Type is mod <>;
   Taps : Random_Type := 16#B400#;
package LFSR is

   State : Random_Type := Random_Type'Last;

   function Next
      return Random_Type;

   function In_Range
      (First, Last : Random_Type)
      return Random_Type;

end LFSR;
