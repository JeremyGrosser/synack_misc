package body Str is
   subtype Numbers is Character range '0' .. '9';

   function Find
      (S : String;
       C : Character)
       return Natural
   is
   begin
      for I in S'Range loop
         if S (I) = C then
            return I;
         end if;
      end loop;
      return 0;
   end Find;

   function Contains
      (Haystack, Needle : String)
      return Boolean
   is
      I : Integer := Haystack'First;
   begin
      if Haystack'Length < Needle'Length then
         return False;
      end if;

      while I <= Haystack'Last - Needle'Length - 1 loop
         if Haystack (I .. I + Needle'Length) = Needle then
            return True;
         end if;
         I := I + 1;
      end loop;
      return False;
   end Contains;

   function Find_Number
      (S : String)
      return Natural
   is
   begin
      for I in S'Range loop
         if S (I) in Numbers then
            return I;
         end if;
      end loop;
      return 0;
   end Find_Number;

   function To_Natural
      (S    : String;
       Base : Positive := 10)
      return Natural
   is
      Multiple : Natural := 1;
      N        : Natural := 0;
   begin
      for I in reverse 0 .. S'Length - 1 loop
         N := N + ((Character'Pos (S (S'First + I)) - Character'Pos ('0')) * Multiple);
         Multiple := Multiple * Base;
      end loop;
      return N;
   end To_Natural;

   function Split
      (S         : String;
       Delimiter : Character;
       Skip      : Natural)
       return String
   is
      First : Natural := S'First;
      Last  : Natural := S'Last;
   begin
      if Skip > 0 then
         for I in 1 .. Skip loop
            First := Find (S (First .. Last), Delimiter) + 1;
         end loop;
      end if;
      Last := Find (S (First .. Last), Delimiter);
      if Last = 0 then
         Last := S'Last;
      else
         Last := Last - 1;
      end if;
      return S (First .. Last);
   end Split;

   function Strip
      (S : String;
       C : Character)
       return String
   is
   begin
      if S'Length = 0 then
         return S;
      end if;

      if S'Length = 1 and then S (S'First) = C then
         return "";
      end if;

      if S (S'First) = C then
         return Strip (S (S'First + 1 .. S'Last), C);
      elsif S (S'Last) = C then
         return Strip (S (S'First .. S'Last - 1), C);
      else
         return S;
      end if;
   end Strip;

   function Trim
      (S     : String;
       Chars : String)
      return String
   is
      Last : Integer := S'Last;
   begin
      while Find (Chars, S (Last)) /= 0 loop
         Last := Last - 1;
         if Last = S'First then
            return "";
         end if;
      end loop;
      return S (S'First .. Last);
   end Trim;

   function Starts_With
      (S      : String;
       Prefix : String)
       return Boolean
   is
   begin
      return (S'Length >= Prefix'Length and then S (S'First .. S'First + Prefix'Length - 1) = Prefix);
   end Starts_With;
end Str;
