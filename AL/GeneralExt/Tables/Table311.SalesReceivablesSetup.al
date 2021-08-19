tableextension 80311 "Sales & Receiv. Setup (Ext)" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50010; "Inform Cust. Payment"; Boolean)
        {
            Caption = 'Inform Cust. Payment';
            Description = 'NC 50804 OA';
        }
        field(50020; "Prepay. Inv. G/L Acc. No. (ac)"; code[20])
        {
            Caption = 'Prepay. Inv. G/L Acc. No. (ac)';
            TableRelation = "G/L Account";
        }
        field(50030; "Cost Place Dimension"; Code[20])
        {
            Caption = 'Cost Place Dimension';
            Description = 'NC 50601 PA';
            TableRelation = Dimension;
        }
        field(50031; "Taxable Period Dimension"; Code[20])
        {
            Caption = 'Taxable Period Dimension';
            Description = 'NC 50601 PA';
            TableRelation = Dimension;
        }
        field(50032; "Tax Acc. View Dimension"; Code[20])
        {
            Caption = 'Tax Acc. View  Dimension';
            Description = 'NC 50601 PA';
            TableRelation = Dimension;
        }
        field(50033; "Tax Acc. Object Dimension"; Code[20])
        {
            Caption = 'Tax Acc. Object Dimension';
            Description = 'NC 50601 PA';
            TableRelation = Dimension;
        }
        field(50100; "Posted Prof-Inv. Template Code"; Code[20])
        {
            Caption = 'Posted Proforma-Invoice Template Code';
            TableRelation = "Excel Template";
        }
        field(50101; "Posted Act PerfWork Templ Code"; Code[20])
        {
            Caption = 'Posted Act Performed Work Template Code';
            TableRelation = "Excel Template";
        }
        field(50102; "Aged Acc. Receiv. Tmplt Code"; Code[10])
        {
            Caption = 'Aged Accounts Receivable Template';
            TableRelation = "Excel Template";
        }
        field(70000; "Building Act Nos."; Code[10])
        {
            TableRelation = "No. Series";
            Caption = 'Building Act Nos.';
        }

        field(70001; "CRM Worker Code"; Code[20])
        {
            TableRelation = "Web Request Worker Setup";
            Caption = 'CRM Worker Code';
        }
    }

}
