pageextension 94983 "Direct Transfer (Ext)" extends "Direct Transfer"
{
    actions
    {
        // NC 51410 > EP
        modify(Dimensions)
        {
            ShortcutKey = 'Alt+D';
            ApplicationArea = Dimensions;
            Promoted = true;
            PromotedIsBig = true;

            trigger OnAfterAction()
            begin
                Rec.ShowDocDim();
                CurrPage.SaveRecord();
            end;
        }
        // NC 51410 < EP
    }
}