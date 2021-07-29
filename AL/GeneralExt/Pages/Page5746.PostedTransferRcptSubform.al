pageextension 85746 "Posted Trans. Rcpt. Sub. (Ext)" extends "Posted Transfer Rcpt. Subform"
{
    layout
    {
        // NC 51411 > EP
        addbefore(ShortcutDimCode3)
        {
            field("New Shortcut Dimension 1 Code"; Rec."New Shortcut Dimension 1 Code")
            {
                ApplicationArea = Dimensions;
                Visible = IsDimVisible1;
            }
            field("New Shortcut Dimension 2 Code"; Rec."New Shortcut Dimension 2 Code")
            {
                ApplicationArea = Dimensions;
                Visible = IsDimVisible2;
            }
        }
        // NC 51411 < EP
    }

    // NC 51411 > EP
    // Как и в pageextension "Transfer Order Subform (Ext)",
    // не удается использовать стандартные protected переменные,
    // поэтому изобретаю велосипед

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

    // NC 51411 < EP

    // NC 51410 > EP
    // В стандарте есть поля для шорткатов, а код для загрузки значений в них добавить забыли...
    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;
    // NC 51410 < EP

    // NC 51411 > EP
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
    // NC 51411 < EP
}