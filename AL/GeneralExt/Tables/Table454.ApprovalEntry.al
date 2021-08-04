tableextension 80454 "Approval Entry (Ext)" extends "Approval Entry"
{
    fields
    {
        field(50000; "Status App Act"; Enum "Purchase Act Approval Status")
        {
            Description = 'NC 51373 AB';
            Caption = 'Act Approval Status';
        }
        field(50001; "Act Type"; enum "Purchase Act Type")
        {
            Caption = 'Act Type';
            Description = 'NC 51373 AB';
        }
        field(50002; "Reject"; Boolean)
        {
            Caption = 'Reject';
            Description = 'NC 51374 AB';
        }
        field(50003; "Status App"; Enum "Purchase Approval Status")
        {
            Caption = 'Approval Status';
            Description = 'NC 51374 AB';
        }
        field(50004; "IW Documents"; Boolean)
        {
            Caption = 'IW Documents';
            Description = 'NC 51380 AB';
        }
        field(50005; "Preliminary Approval"; Boolean)
        {
            Caption = 'Preliminary Approval';
            Description = 'NC 51380 AB';
        }
    }
}