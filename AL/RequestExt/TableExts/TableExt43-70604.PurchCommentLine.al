tableextension 70604 "Purch. Comment Line (Req)" extends "Purch. Comment Line"
{
    fields
    {
        field(50000; "Add. Line Type"; Enum "Purchase Comment Add. Type")
        {
            Caption = 'Add. Line Type';
            Description = 'NC 51379 AB';
        }
        field(50001; "Comment 2"; Text[250])
        {
            Caption = 'Comment 2';
            Description = 'NC 51379 AB';
        }
    }
}