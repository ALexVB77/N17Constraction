pageextension 85741 "Transfer Order Subform (Ext)" extends "Transfer Order Subform"
{
    layout
    {
        // NC 51410 > EP
        modify("Shortcut Dimension 1 Code")
        {
            Visible = IsDimVisible1;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Visible = IsDimVisible2;
        }
        modify("ShortcutDimCode[3]")
        {
            Visible = IsDimVisible3;
        }
        modify("ShortcutDimCode[4]")
        {
            Visible = IsDimVisible4;
        }
        modify("ShortcutDimCode[5]")
        {
            Visible = IsDimVisible5;
        }
        modify("ShortcutDimCode[6]")
        {
            Visible = IsDimVisible6;
        }
        modify("ShortcutDimCode[7]")
        {
            Visible = IsDimVisible7;
        }
        modify("ShortcutDimCode[8]")
        {
            Visible = IsDimVisible8;
        }
        // NC 51410 < EP
    }

    // NC 51410 > EP
    // Если использовать в расширении стандартные переменные "DimVisible1..8",
    // то встречаемся с ошибкой о их недоступности, несмотря на то, что они protected.
    // Поэтому продублировал здесь стандартную функциональность выставления видимости полям с измерениями

    var
        IsDimVisible1: Boolean;
        IsDimVisible2: Boolean;
        IsDimVisible3: Boolean;
        IsDimVisible4: Boolean;
        IsDimVisible5: Boolean;
        IsDimVisible6: Boolean;
        IsDimVisible7: Boolean;
        IsDimVisible8: Boolean;

    trigger OnOpenPage()
    begin
        SetDimensionFieldsVisibility();
    end;

    local procedure SetDimensionFieldsVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        IsDimVisible1 := false;
        IsDimVisible2 := false;
        IsDimVisible3 := false;
        IsDimVisible4 := false;
        IsDimVisible5 := false;
        IsDimVisible6 := false;
        IsDimVisible7 := false;
        IsDimVisible8 := false;

        DimMgt.UseShortcutDims(
          IsDimVisible1, IsDimVisible2, IsDimVisible3, IsDimVisible4, IsDimVisible5, IsDimVisible6, IsDimVisible7, IsDimVisible8);

        Clear(DimMgt);
    end;

    // NC 51410 < EP
}