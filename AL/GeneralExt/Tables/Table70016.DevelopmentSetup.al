table 70016 "Development Setup"
{
    Caption = 'Development Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(28; "Project Dimension Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            TableRelation = Dimension.Code;
        }
        // field(29; "Project Version Nos."; Code[10])
        // {
        //     Caption = 'Bank Account Nos.';
        //     TableRelation = "No. Series";
        // }
        field(30; "Pref Vesion Code"; Code[10])
        {
            Caption = 'Pref Vesion Code';
        }
        // field(31; "Project Turn Dimension Code"; Code[20])
        // {
        //     Caption = 'Global Dimension 1 Code';
        //     TableRelation = Dimension.Code;
        // }
        // field(32; "Sales Agreement Role"; Code[20])
        // {
        //     Caption = 'Sales Agreement Manager Role';
        //     TableRelation = "User Role";
        // }
        field(33; "Pref Forecast Code"; Code[10])
        {
            Caption = 'Pref Forecast Code';
        }
        // field(34; "Change Agreement CF Role"; Code[20])
        // {
        //     Caption = 'Change Agreement CF Role';
        //     TableRelation = "User Role";
        // }
        // field(35; "Forecast Approver Role"; Code[20])
        // {
        //     Caption = 'Forecast Approver Role';
        //     TableRelation = "User Role";
        // }
        // field(36; "Forecast Import Role"; Code[20])
        // {
        //     TableRelation = "User Role";
        // // }
        // field(37; "DW Enterprise Code"; Text[50])
        // {
        //     Caption = 'DW Enterprise Code';
        // }
        // field(38; "DW Region"; Text[50])
        // {
        //     Caption = 'DW Region';
        // }
        // field(39; "DW Subregion"; Text[50])
        // {
        //     Caption = 'DW Subregion';
        // }
        // field(40; "DW Enterprise Code EL"; Text[50])
        // {
        //     Caption = 'DW Enterprise Code EL';
        // }
        // field(41; "DW Region EL"; Text[50])
        // {
        //     Caption = 'DW Region EL';
        // }
        // field(42; "DW Subregion EL"; Text[50])
        // {
        //     Caption = 'DW Subregion EL';
        // }
        // field(43; "DW CSV Template"; BLOB)
        // {
        //     Caption = 'DW CSV Template';
        // }
        // field(44; "DW Export Path"; Text[250])
        // {
        //     Caption = 'DW Export Path';
        // }
        // field(45; "CSV Export Prefix"; Text[30])
        // {
        //     Caption = 'CSV Export Prefix';
        // }
        // field(46; "Main IFRS Company"; Text[50])
        // {
        //     Caption = 'Main IFRS Company';
        // }
        // field(47; "Create Vend Agr Details"; Boolean)
        // {
        //     Caption = 'Create Vend Agr Details';
        // }
    }
    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}

