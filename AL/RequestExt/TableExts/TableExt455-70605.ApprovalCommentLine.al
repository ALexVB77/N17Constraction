tableextension 70605 "Approval Comment Line (Req)" extends "Approval Comment Line"
{
    fields
    {
        field(50000; "Linked Approval Entry No."; Integer)
        {
            Caption = 'Linked Approval Entry No.';
            Description = 'NC 51374 AB';
        }
        field(50001; "Status App Act"; Enum "Purchase Act Approval Status")
        {
            CalcFormula = lookup("Approval Entry"."Status App Act" WHERE("Entry No." = FIELD("Linked Approval Entry No.")));
            Caption = 'Act Approval Status';
            Description = 'NC 51374 AB';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50002; "Approval Status"; Enum "Approval Status")
        {
            CalcFormula = lookup("Approval Entry"."Status" WHERE("Entry No." = FIELD("Linked Approval Entry No.")));
            Caption = 'Approval Status';
            Description = 'NC 51374 AB';
            Editable = false;
            FieldClass = FlowField;
        }

        field(50003; "Status App"; Enum "Purchase Approval Status")
        {
            CalcFormula = lookup("Approval Entry"."Status App" WHERE("Entry No." = FIELD("Linked Approval Entry No.")));
            Caption = 'Payment Inv. Approval Status';
            Description = 'NC 51374 AB';
            Editable = false;
            FieldClass = FlowField;
        }

    }
    keys
    {
        key(Key50000; "Linked Approval Entry No.")
        {
        }
    }
}