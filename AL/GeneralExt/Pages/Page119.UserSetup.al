pageextension 80119 "User Setup (Ext)" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Show All Acts KC-2"; Rec."Show All Acts KC-2")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Show All Pay Inv"; rec."Show All Pay Inv")
            {
                ApplicationArea = Basic, Suite;
            }
            field("CF Allow Long Entries Edit"; Rec."CF Allow Long Entries Edit")
            {
                ApplicationArea = Basic, Suite;
            }
            field("CF Allow Short Entries Edit"; Rec."CF Allow Short Entries Edit")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Master CF"; Rec."Master CF")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Change Agreem. Posting Group"; Rec."Change Agreem. Posting Group")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Allow Manual Editing"; Rec."Allow Manual Editing")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Allow Edit DenDoc Dimension"; Rec."Allow Edit DenDoc Dimension")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Vend. Agr. Creator Notif."; Rec."Vend. Agr. Creator Notif.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Vend. Agr. Controller Notif."; Rec."Vend. Agr. Controller Notif.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
