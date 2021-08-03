pageextension 80022 "Customer List (Ext)" extends "Customer List"
{
    layout
    {
        addlast(Control1)
        {
            field(MyField; Rec."CRM GUID")
            {
                ApplicationArea = All;
            }
        }
    }
}
