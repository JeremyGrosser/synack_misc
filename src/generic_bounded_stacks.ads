generic
   type Element_Type is private;
   Max_Items : Positive := 1;
package Generic_Bounded_Stacks is

   type Element_Array is array (Positive range <>) of Element_Type;

   type Stack is private;

   function Is_Full
      (S : Stack)
      return Boolean;

   function Is_Empty
      (S : Stack)
      return Boolean;

   function Length
      (S : Stack)
      return Natural;

   function Elements
      (S : Stack)
      return Element_Array;

   procedure Push
      (S    : in out Stack;
       Item : Element_Type)
   with Pre  => not Is_Full (S),
        Post => Length (S) = Length (S'Old) + 1;

   procedure Pop
      (S    : in out Stack;
       Item : out Element_Type)
   with Pre  => not Is_Empty (S),
        Post => Length (S) = Length (S'Old) - 1;

   procedure Clear
      (S : in out Stack);

private

   type Stack is record
      Items : Element_Array (1 .. Max_Items);
      Last  : Natural := 0;
   end record;

end Generic_Bounded_Stacks;