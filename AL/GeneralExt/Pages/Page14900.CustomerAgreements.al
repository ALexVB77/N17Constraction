pageextension 84900 "Customer Agreements (Ext)" extends "Customer Agreements"
{
    layout
    {
        addfirst(Control1210002)
        {
            field("Agreement Type"; Rec."Agreement Type")
            {
                ApplicationArea = All;
            }
        }

        addlast(Control1210002)
        {

            field("Object of Investing"; Rec."Object of Investing")
            {
                ApplicationArea = All;
            }

            field("CRM GUID"; Rec."CRM GUID")
            {
                ApplicationArea = All;
            }
        }

    }

    actions
    {
        addfirst("A&greement")
        {
            action(AgreementCard)
            {
                Caption = 'Agreement Card';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open customer card';

                trigger OnAction();
                begin
                    if Rec."Agreement Type" in ["Agreement Type"::"Prev Inv. Sales Agreement",
                        "Agreement Type"::"Transfer of rights",
                        "Agreement Type"::"Investment Agreement",
                        "Agreement Type"::"Inv. Sales Agreement"]
                    then begin
                        Page.RunModal(Page::"Investment Agreement Card", Rec);
                    end else begin
                        Page.RunModal(Page::"Customer Agreement Card", Rec);
                    end;
                end;
            }

        }

    }
}
