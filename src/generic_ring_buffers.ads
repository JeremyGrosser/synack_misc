generic
   Capacity : Positive := 1;
   type Element_Type is private;
package Generic_Ring_Buffers
--   with Preelaborate
is
   type Ring_Buffer is private;

   function Length
      (This : Ring_Buffer)
      return Natural;

   function Is_Full
      (This : Ring_Buffer)
      return Boolean;

   function Is_Empty
      (This : Ring_Buffer)
      return Boolean;

   function First_Element
      (This : Ring_Buffer)
      return Element_Type
   with Pre => not Is_Empty (This);

   function Last_Element
      (This : Ring_Buffer)
      return Element_Type
   with Pre => not Is_Empty (This);

   procedure Prepend
      (This : in out Ring_Buffer;
       Item : Element_Type)
   with Pre  => not Is_Full (This),
        Post => Length (This) = Length (This'Old) + 1;

   procedure Append
      (This : in out Ring_Buffer;
       Item : Element_Type)
   with Pre  => not Is_Full (This),
        Post => Length (This) = Length (This'Old) + 1;

   procedure Delete_First
      (This : in out Ring_Buffer)
   with Pre  => not Is_Empty (This),
        Post => Length (This) = Length (This'Old) - 1;

   procedure Delete_Last
      (This : in out Ring_Buffer)
   with Pre  => not Is_Empty (This),
        Post => Length (This) = Length (This'Old) - 1;

   procedure Clear
      (This : in out Ring_Buffer)
   with Post => Is_Empty (This);

private
   type Index_Type is new Positive range 1 .. Capacity;
   type Element_Array is array (Index_Type) of Element_Type;

   type Ring_Buffer is record
      Elements : Element_Array;
      First    : Index_Type := Index_Type'First;
      Last     : Index_Type := Index_Type'Last;
      Used     : Natural := 0;
   end record;
end Generic_Ring_Buffers;
