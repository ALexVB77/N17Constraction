tableextension 80349 "Dimension Value (Ext)" extends "Dimension Value"
{
    fields
    {
        field(51000; "Project Code"; Code[20])
        {
            Description = 'NC 51381';
            Caption = 'Project Code';
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('PROJECT'));
        }
        field(75000; "Check CF Forecast"; Boolean)
        {
            Description = 'NC 51373 AB';
        }
        field(99000; Unmapped; Boolean)
        {
            Description = 'NC AB';
            Editable = false;
        }
    }
}