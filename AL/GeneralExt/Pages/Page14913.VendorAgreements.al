pageextension 94913 "Vendor Agreements (Ext)" extends "Vendor Agreements"
{
    layout
    {
        modify("No.")
        {
            StyleExpr = LineColor;
        }
        modify(Description)
        {
            StyleExpr = LineColor;
        }

        addlast(Control1210002)
        {
            field("Check Limit Starting Date"; Rec."Check Limit Starting Date")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Check Limit Ending Date"; Rec."Check Limit Ending Date")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Check Limit Amount (LCY)"; Rec."Check Limit Amount (LCY)")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Purch. Original Amt. (LCY)"; Rec."Purch. Original Amt. (LCY)")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Deviation (LCY)"; Rec."Check Limit Amount (LCY)" - Rec."Purch. Original Amt. (LCY)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Deviation (LCY)';
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        LineColor := Rec.GetLineColor();
    end;

    var
        LineColor: Text;
}