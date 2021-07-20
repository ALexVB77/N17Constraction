tableextension 81511 "Notification Entry (Ext)" extends "Notification Entry"
{
    fields
    {
        field(50000; "EMail Template Report ID"; integer)
        {
            Caption = 'EMail Template Report ID';
            Description = 'NC 51374 AB';
            TableRelation = "Object".ID where(Type = const(Report));
        }
        field(50001; "EMail Template Report Name"; Text[250])
        {
            CalcFormula = lookup(Object.Caption where(Type = const(Report), ID = field("EMail Template Report ID")));
            Caption = 'EMail Template Report Name';
            Description = 'NC 51374 AB';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}