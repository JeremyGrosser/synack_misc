--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
generic
   type Word is mod <>;
   type Word_Array is array (Natural range <>) of Word;
package CRC
   with Preelaborate
is
   Poly : Word;
   Sum  : Word := 0;

   procedure Update
      (Data : Word);

   procedure Update
      (Data : Word_Array);

   function Calculate
      (Data    : Word_Array;
       Initial : Word := 0)
      return Word;

end CRC;
