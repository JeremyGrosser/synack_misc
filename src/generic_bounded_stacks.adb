package body Generic_Bounded_Stacks is

   function Is_Full
      (S : Stack)
      return Boolean
   is (S.Last = Max_Items);

   function Is_Empty
      (S : Stack)
      return Boolean
   is (S.Last = 0);

   function Length
      (S : Stack)
      return Natural
   is (S.Last);

   function Elements
      (S : Stack)
      return Element_Array
   is (S.Items (1 .. S.Last));

   procedure Push
      (S    : in out Stack;
       Item : Element_Type)
   is
   begin
      S.Last := S.Last + 1;
      S.Items (S.Last) := Item;
   end Push;

   procedure Pop
      (S    : in out Stack;
       Item : out Element_Type)
   is
   begin
      Item := S.Items (S.Last);
      S.Last := S.Last - 1;
   end Pop;

   procedure Clear
      (S : in out Stack)
   is
   begin
      S.Last := 0;
   end Clear;

end Generic_Bounded_Stacks;