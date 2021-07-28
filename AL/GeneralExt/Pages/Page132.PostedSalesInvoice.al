pageextension 80132 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Invoice)
        {
            action(ManualEditing)
            {
                ApplicationArea = All;
                Caption = 'Manual Field Editing';
                trigger OnAction()
                var
                    UserSetup: Record "User Setup";
                begin

                    UserSetup.GET(USERID);
                    IF NOT (UserSetup."Allow Manual Editing") THEN
                        ERROR(Text0001, USERID)
                    ELSE BEGIN
                        ManualEditAllowed := true;
                        //CurrForm."Sell-to Address".VISIBLE := FALSE;
                        //CurrForm."Sell-to Address2".VISIBLE := TRUE;
                        //CurrForm."Sell-to Address 2".VISIBLE := FALSE;
                        //CurrForm."Sell-to Address 22".VISIBLE := TRUE;
                        //CurrForm."KPP Code".VISIBLE := FALSE;
                        //CurrForm."KPP Code2".VISIBLE := TRUE;
                        //CurrForm."VAT Registration No.".VISIBLE := FALSE;
                        //CurrForm."VAT Registration No.2".VISIBLE := TRUE;
                    END;

                end;
            }
        }
    }

    var
        ManualEditAllowed: Boolean;
        Text0001: Label 'User %1 do not have permission for manual editing';
}