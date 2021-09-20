table 70220 "Item Scanning Entry"
{
    Caption = 'Item Scanning Entry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = ToBeClassified;
            OptionMembers = ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        }
        field(3; "Document No."; Code[250])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(4; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = ToBeClassified;
        }
        field(5; Barcode; Code[15])
        {
            Caption = 'Barcode';
            DataClassification = ToBeClassified;
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
        }
        field(7; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = ToBeClassified;
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
        field(9; RealScan; Boolean)
        {
            Caption = 'RealScan';
            DataClassification = ToBeClassified;
        }
        field(10; UserID; Code[50])
        {
            Caption = 'UserID';
            DataClassification = ToBeClassified;
        }
        field(11; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = ToBeClassified;
        }
        field(12; "Quantity(Base)"; Decimal)
        {
            Caption = 'Quantity(Base)';
            DataClassification = ToBeClassified;
        }
        field(13; ManualInsQty; Boolean)
        {
            Caption = 'ManualInsQty';
            DataClassification = ToBeClassified;
        }
        field(14; SplitWithEntry; Integer)
        {
            Caption = 'SplitWithEntry';
            DataClassification = ToBeClassified;
        }
        field(15; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}
