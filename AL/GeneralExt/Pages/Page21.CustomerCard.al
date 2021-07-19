pageextension 80021 "Customer Card (Ext)" extends "Customer Card"
{
    layout
    {
        addlast(Control1905596001)
        {
            field("CRM GUID"; Rec."CRM GUID")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }

    }

}