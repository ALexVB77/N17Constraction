tableextension 85744 "Transfer Shipment Header (Ext)" extends "Transfer Shipment Header"
{
    fields
    {
        field(50002; "New Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 1 Code';
            Description = 'NC 51417 PA';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            CaptionClass = '1,2,1';
        }
        field(50010; "Vendor No."; Code[20])
        {
            Caption = 'Vendor';
            Description = 'NC 51417 PA';
            TableRelation = Vendor;
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