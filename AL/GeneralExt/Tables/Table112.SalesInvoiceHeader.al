tableextension 80112 "Sales Invoice Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(50010; "Government Agreement No"; Text[50])
        {
            Caption = 'Government Agreement No';
            Description = 'NC 50788 OA';
        }
    }

    var
        myInt: Integer;
}