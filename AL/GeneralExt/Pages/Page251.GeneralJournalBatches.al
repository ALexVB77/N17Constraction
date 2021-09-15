pageextension 80251 "General Journal Batches (Ext)" extends "General Journal Batches"
{
    layout
    {
        modify("Bal. Account Type")
        {
            Width = 27;
        }
        addlast(Control1)
        {
            field("Non-transmit"; "Non-transmit")
            {
                ApplicationArea = All;
            }
        }
    }
}