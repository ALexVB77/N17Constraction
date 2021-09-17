table 50007 "VAT Dim. Allocation Setup"
{
    Caption = 'VAT Dimension Allocation Setup';
    DrillDownPageId = "VAT Dim. Allocation Setup";
    LookupPageId = "VAT Dim. Allocation Setup";
    fields
    {
        field(1; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

        }
        field(2; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'VAT,Write-Off,Charge';
            OptionMembers = VAT,WriteOff,Charge;
        }
        field(5; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "G/L Account";
        }

        field(7; "Allocation %"; Decimal)
        {
            Caption = 'Allocation %';
            MaxValue = 100;
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Global Dimension 1 Code", "Global Dimension 2 Code", Type, "Account No.")
        {
            Clustered = true;
        }
    }

    // trigger OnInsert()
    // begin

    // end;

    // trigger OnModify()
    // begin

    // end;

    // trigger OnDelete()
    // begin

    // end;

    // trigger OnRename()
    // begin

    // end;

}