pageextension 80132 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        modify("Sell-to Address")
        {
            Editable = ManualEditAllowed;
        }
        modify("Sell-to Address 2")
        {
            Editable = ManualEditAllowed;
        }
        modify("KPP Code")
        {
            Editable = ManualEditAllowed;
        }

        addlast(General)
        {
            field("Government Agreement No"; Rec."Government Agreement No")
            {
                ApplicationArea = Basic, Suite;
            }
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = ManualEditAllowed;
            }
        }
    }

    actions
    {
        addlast("F&unctions")
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
                    END;

                end;
            }
        }
    }

    var
        ManualEditAllowed: Boolean;
        Text0001: Label 'User %1 do not have permission for manual editing';
}