pageextension 80461 "Inventory Setup (Ext)" extends "Inventory Setup"
{
    layout
    {
        addlast(content)
        {
            group(Another)
            {
                Caption = 'Another';
                field("Temp Item Code"; rec."Temp Item Code")
                {
                    ApplicationArea = All;
                }
            }
        }
        addlast(General)
        {
            field("Use Giv. Production Func."; Rec."Use Giv. Production Func.")
            {
                ApplicationArea = All;
                Description = 'NC 51411 EP';
            }
        }
        addlast(Location)
        {
            field("Giv. Materials Loc. Code"; Rec."Giv. Materials Loc. Code")
            {
                ApplicationArea = All;
                Description = 'NC 51411 EP';
            }
            field("Giv. Production Loc. Code"; Rec."Giv. Production Loc. Code")
            {
                ApplicationArea = All;
                Description = 'NC 51411 EP';
            }
            field("Default Location Code"; Rec."Default Location Code")
            {
                ApplicationArea = All;
            }
        }
        addafter("Posted Invt. Pick Nos.")
        {
            field("Manuf. Document Nos."; Rec."Manuf. Document Nos.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Inbound Whse. Handling Time")
        {
            field("Manuf. Gen. Bus. Posting Gr."; "Manuf. Gen. Bus. Posting Gr.")
            {
                ApplicationArea = all;
            }
            field("Manuf. Alloc. Source Code"; rec."Manuf. Alloc. Source Code")
            {
                ApplicationArea = all;
            }
            field("Manuf. Alloc. Reverse SC"; rec."Manuf. Alloc. Reverse SC")
            {
                ApplicationArea = all;
            }
            field("Manuf. Adjmt Source Code"; rec."Manuf. Adjmt Source Code")
            {
                ApplicationArea = all;
            }
        }
        addafter("Transfer Order Nos.")
        {
            field("Giv. Transfer Order Nos."; Rec."Giv. Transfer Order Nos.")
            {
                ApplicationArea = All;
                Description = 'NC 51410 EP';
            }
        }
        addlast(Templates)
        {
            field("Item Shpt. M-19 Template Code"; Rec."Item Shpt. M-19 Template Code")
            {
                ApplicationArea = All;
                Description = 'NC 52624 EP';
            }
        }
    }
}