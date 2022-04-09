with Ada.Text_IO; use Ada.Text_IO;

package body Generic_Ring_Buffers is

   function Length
      (This : Ring_Buffer)
      return Natural
   is (This.Used);

   function Is_Full
      (This : Ring_Buffer)
      return Boolean
   is (This.Used = Capacity);

   function Is_Empty
      (This : Ring_Buffer)
      return Boolean
   is (This.Used = 0);

   function First_Element
      (This : Ring_Buffer)
      return Element_Type
   is (This.Elements (This.First));

   function Last_Element
      (This : Ring_Buffer)
      return Element_Type
   is (This.Elements (This.Last));

   procedure Prepend
      (This : in out Ring_Buffer;
       Item : Element_Type)
   is
   begin
      if This.First = Index_Type'First then
         This.First := Index_Type'Last;
      else
         This.First := This.First - 1;
      end if;
      This.Elements (This.First) := Item;
      This.Used := This.Used + 1;
   end Prepend;

   procedure Append
      (This : in out Ring_Buffer;
       Item : Element_Type)
   is
   begin
      if This.Last = Index_Type'Last then
         This.Last := Index_Type'First;
      else
         This.Last := This.Last + 1;
      end if;
      This.Elements (This.Last) := Item;
      This.Used := This.Used + 1;
   end Append;

   procedure Delete_First
      (This : in out Ring_Buffer)
   is
   begin
      if This.First = Index_Type'Last then
         This.First := Index_Type'First;
      else
         This.First := This.First + 1;
      end if;
      This.Used := This.Used - 1;
   end Delete_First;

   procedure Delete_Last
      (This : in out Ring_Buffer)
   is
   begin
      if This.Last = Index_Type'First then
         This.Last := Index_Type'Last;
      else
         This.Last := This.Last - 1;
      end if;
      This.Used := This.Used - 1;
   end Delete_Last;

   procedure Clear
      (This : in out Ring_Buffer)
   is
   begin
      This.First := Index_Type'First;
      This.Last := Index_Type'Last;
      This.Used := 0;
   end Clear;
end Generic_Ring_Buffers;
