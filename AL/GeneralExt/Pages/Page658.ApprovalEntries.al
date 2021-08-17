pageextension 80658 "Approval Entries (Ext)" extends "Approval Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Status App Act"; "Status App Act")
            {
                ApplicationArea = All;
            }
            field("Status App"; "Status App")
            {
                ApplicationArea = All;
            }
            field("Preliminary Approval"; "Preliminary Approval")
            {
                ApplicationArea = All;
            }
            field("Delegated From Approver ID"; "Delegated From Approver ID")
            {
                ApplicationArea = All;
            }
        }
    }
}