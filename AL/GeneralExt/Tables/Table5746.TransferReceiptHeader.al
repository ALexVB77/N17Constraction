tableextension 85764 "Transfer Receipt Header (Ext)" extends "Transfer Receipt Header"
{
    fields
    {
        field(50002; "New Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 1 Code';
            Description = 'NC002 ROMB, NC 51410 EP';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            CaptionClass = '1,2,1,New ';
        }
        field(50003; "New Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 2 Code';
            Description = 'NC002 ROMB, NC 51410 EP';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            CaptionClass = '1,2,1,New ';
        }
        field(50010; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            Description = 'NC 51417 PA';
            TableRelation = "Vendor";
        }
        field(50011; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            Description = 'NC 51417 PA';
            TableRelation = "Vendor Agreement"."No." where("Vendor No." = field("Vendor No."));
        }
        field(50020; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            Description = 'NC22512 DP';
            TableRelation = "Gen. Business Posting Group";
        }
    }
}