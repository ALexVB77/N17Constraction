table 70034 "Commited Detail"
{
    // 28-02-2018 NC 24029 HR: Добавлены два ключа CP и CC


    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(2; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
        }
        field(3; CP; Code[20])
        {
            Caption = 'Cost Place';
        }
        field(4; CC; Code[20])
        {
            Caption = 'Cost Code';
        }
        field(5; CT; Code[20])
        {
            Caption = 'Cost Type';
        }
        field(6; "Amount 1"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Vendor Agreement Details"."Amount Without VAT" WHERE("Agreement No." = FIELD("Agreement No."),
                                                                                     "Vendor No." = FIELD("Vendor No."),
                                                                                     "Project Line No." = FIELD("Line No."),
                                                                                     "Global Dimension 1 Code" = FIELD(CP),
                                                                                     "Cost Type" = FIELD(CT),
                                                                                     "Global Dimension 2 Code" = FIELD(CC),
                                                                                     "Project Code" = FIELD("Project Code"),
                                                                                     "Project Line No." = FIELD("Line No.")));
            Caption = 'Amount 1';

        }
        field(7; "Amount 2"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Projects Cost Control Entry"."Without VAT" WHERE("Analysis Type" = CONST(Actuals),
                                                                                 "Contragent No." = FIELD("Vendor No."),
                                                                                 "Agreement No." = FIELD("Agreement No."),
                                                                                 "Line No." = FIELD("Line No."),
                                                                                 "Cost Type" = FIELD(CT),
                                                                                 "Project Code" = FIELD("Project Code"),
                                                                                 "Shortcut Dimension 1 Code" = FIELD(CP),
                                                                                 "Shortcut Dimension 2 Code" = FIELD(CC)));
            Caption = 'Actuals';

        }
        field(8; "Amount 3"; Decimal)
        {
        }
        field(9; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(11; ByOrder; Boolean)
        {
            Caption = 'By Order';
        }
        field(12; "Turn Code"; Code[20])
        {
            Caption = 'Turn Code';
        }
        field(13; "Vendor Name"; Text[250])
        {
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Caption = 'Vendor Name';
            FieldClass = FlowField;
        }
        field(14; "External Agreement No."; Text[30])
        {
            CalcFormula = Lookup("Vendor Agreement"."External Agreement No." WHERE("Vendor No." = FIELD("Vendor No."),
                                                                                    "No." = FIELD("Agreement No.")));
            Caption = 'External Agreement No.';
            FieldClass = FlowField;
        }
        field(15; "Agreement Description"; Text[250])
        {
            CalcFormula = Lookup("Vendor Agreement".Description WHERE("Vendor No." = FIELD("Vendor No."),
                                                                       "No." = FIELD("Agreement No.")));
            Caption = 'Description';
            FieldClass = FlowField;
        }
        field(16; "Agreement Date"; Date)
        {
            CalcFormula = Lookup("Vendor Agreement"."Agreement Date" WHERE("Vendor No." = FIELD("Vendor No."),
                                                                            "No." = FIELD("Agreement No.")));
            Caption = 'Agreement Date';
            FieldClass = FlowField;
        }
        field(17; "Ordered Amount"; Decimal)
        {
            CalcFormula = Sum("Vendor Agreement Details".AmountLCY WHERE("Agreement No." = FIELD("Agreement No."),
                                                                          "Vendor No." = FIELD("Vendor No."),
                                                                          "Global Dimension 1 Code" = FIELD(CP),
                                                                          "Global Dimension 2 Code" = FIELD(CC),
                                                                          "Cost Type" = FIELD(CT),
                                                                          "Project Code" = FIELD("Project Code"),
                                                                          "Project Line No." = FIELD("Line No.")));
            Description = 'SWC862 Sum Amount -> Sum AmountLCY';
            FieldClass = FlowField;
        }
        field(50000; Comment; Text[250])
        {
            Caption = 'Comment';
            Description = 'SWC955';
        }
        field(50002; "Amount Incl. VAT (VAG)"; Decimal)
        {
            CalcFormula = Sum("Vendor Agreement Details".Amount WHERE("Agreement No." = FIELD("Agreement No."),
                                                                       "Vendor No." = FIELD("Vendor No."),
                                                                       "Project Line No." = FIELD("Line No."),
                                                                       "Global Dimension 1 Code" = FIELD(CP),
                                                                       "Cost Type" = FIELD(CT),
                                                                       "Global Dimension 2 Code" = FIELD(CC),
                                                                       "Project Code" = FIELD("Project Code"),
                                                                       "Project Line No." = FIELD("Line No.")));
            Caption = 'Amount Incl. VAT (VAG)';
            Description = '28312';
            FieldClass = FlowField;
        }
        field(50003; "Amount Incl. VAT (PCCE)"; Decimal)
        {
            CalcFormula = Sum("Projects Cost Control Entry"."Amount Including VAT 2" WHERE("Analysis Type" = CONST(Actuals),
                                                                                            "Contragent No." = FIELD("Vendor No."),
                                                                                            "Agreement No." = FIELD("Agreement No."),
                                                                                            "Line No." = FIELD("Line No."),
                                                                                            "Cost Type" = FIELD(CT),
                                                                                            "Project Code" = FIELD("Project Code"),
                                                                                            "Shortcut Dimension 1 Code" = FIELD(CP),
                                                                                            "Shortcut Dimension 2 Code" = FIELD(CC)));
            Caption = 'Amount Incl. VAT (PCCE)';
            Description = '28312';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Vendor No.", "Agreement No.", CP, CC, CT, "Project Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Project Code", "Line No.", "Turn Code", CT)
        {
        }
        key(Key3; CP)
        {
        }
        key(Key4; CC)
        {
        }
    }

    fieldgroups
    {
    }
}

