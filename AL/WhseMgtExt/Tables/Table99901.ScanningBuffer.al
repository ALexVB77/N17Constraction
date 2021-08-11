table 99901 "Scanning Buffer"
{
    Caption = 'Scanning Buffer';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; DocumentNo; Code[20])
        {
            Caption = 'DocumentNo';
            DataClassification = ToBeClassified;
        }
        field(2; DocumentLineNo; Integer)
        {
            Caption = 'DocumentLineNo';
            DataClassification = ToBeClassified;
        }
        field(3; Qty; Decimal)
        {
            Caption = 'Qty';
            DataClassification = ToBeClassified;
        }
        field(4; "Qty(Base)"; Decimal)
        {
            Caption = 'Qty(Base)';
            DataClassification = ToBeClassified;
        }
        field(5; Uom; Code[10])
        {
            Caption = 'Uom';
            DataClassification = ToBeClassified;
        }
        field(6; "Uom(Base)"; Code[10])
        {
            Caption = 'Uom(Base)';
            DataClassification = ToBeClassified;
        }
        field(7; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
        }
        field(8; DocumentFilter; Code[250])
        {
            Caption = 'DocumentFilter';
            DataClassification = ToBeClassified;
        }
        field(9; DocumentType; Option)
        {
            Caption = 'DocumentFilter';
            DataClassification = ToBeClassified;
            OptionMembers = ,Posting,TransOrder,MatOrder,"Write-off",TransOrderNew,MatOrderNew,WrOffNew,Inventory;
        }
    }
    keys
    {
        key(PK; DocumentNo, DocumentLineNo)
        {
            Clustered = true;
        }
    }

}
