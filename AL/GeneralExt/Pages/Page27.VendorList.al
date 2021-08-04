pageextension 80027 "Vendor List (Ext)" extends "Vendor List"
{
    layout
    {
        modify("No.")
        {
            StyleExpr = LineColor;
        }
        modify("Name")
        {
            StyleExpr = LineColor;
        }
    }

    var
        LineColor: Text;

    trigger OnAfterGetRecord()
    begin
        LineColor := Rec.GetLineColor();
    end;
}