tableextension 70601 "User Setup (Req)" extends "User Setup"
{
    fields
    {

        field(70001; "Status App"; enum "User Setup Approval Status")
        {
            Description = 'NC 51378 AB';
            Caption = 'Approval Status';
        }
        field(70003; Absents; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Absents';
            Editable = false;
        }
        field(70005; "Administrator IW"; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Administrator IW';
        }
        field(70008; "Administrator PRJ"; Boolean)
        {
            Description = 'NC 50086 PA';
            Caption = 'Administrator PRJ';
        }
        field(70015; "Status App Act"; enum "User Setup Act Approval Status")
        {
            Description = 'NC 51373 AB';
            Caption = 'Act Approval Status';
        }
        field(70030; "Show All Pay Inv"; Boolean)
        {
            Description = 'NC 51378 AB';
            Caption = 'Show all Payment Invoices';
        }
        field(70040; "Show All Acts KC-2"; Boolean)
        {
            Description = 'NC 51373 AB';
            Caption = 'Show All Acts KC-2';
        }
    }
}