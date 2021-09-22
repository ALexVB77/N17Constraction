tableextension 70610 "Inventory Setup (Req)" extends "Inventory Setup"
{
    fields
    {
        field(70002; "Temp Item Code"; Code[20])
        {
            Caption = 'Temp Item Code';
            Description = 'NC 51373 AB';
            TableRelation = Item;
        }
        field(70010; "Default Location Code"; Code[20])
        {
            Caption = 'Default Location Code';
            Description = 'NC 51373 AB';
            TableRelation = Location;
        }
    }
}