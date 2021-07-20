pageextension 80480 "Edit Dimension Set Entries Ext" extends "Edit Dimension Set Entries"
{
    layout
    {
        modify(DimensionValueCode)
        {
            trigger OnAssistEdit()
            var
                UserSetup: Record "User Setup";
                GenLedgerSetup: Record "General Ledger Setup";
                DimValues: Page "Dimension Values";
                DimValueList: Page "Dimension Value List";
                DimValue: Record "Dimension Value";
            begin
                GenLedgerSetup.Get();
                DimValue.SetRange("Dimension Code", Rec."Dimension Code");
                if UserSetup.Get(UserId) and UserSetup."Allow Edit DenDoc Dimension" then
                    if Rec."Dimension Code" = GenLedgerSetup."Shortcut Dimension 8 Code" then
                        Page.RunModal(Page::"Dimension Values", DimValue)
                    else
                        Page.RunModal(Page::"Dimension Value List", DimValue)
                else
                    Page.RunModal(Page::"Dimension Value List", DimValue);
            end;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}