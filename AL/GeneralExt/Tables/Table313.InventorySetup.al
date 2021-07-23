tableextension 80313 "Inventory Setup (Ext)" extends "Inventory Setup"
{
    fields
    {
        field(50000; "Giv. Materials Loc. Code"; Code[20])
        {
            // TODO: перенести зависимости в t12453 @eapomazkov
            Caption = 'Giv. Materials Loc. Code';
            Description = 'SWC816, NC 51411 EP';
            TableRelation = Location;
        }
        field(50001; "Giv. Production Loc. Code"; Code[20])
        {
            // TODO: перенести зависимости в t12453 @eapomazkov
            Caption = 'Giv. Production Loc. Code';
            Description = 'SWC816, NC 51411 EP';
            TableRelation = Location;
        }
        field(50002; "Manuf. Gen. Bus. Posting Gr."; code[10])
        {
            Caption = 'Manuf. Gen. Bus. Posting Gr.';
            TableRelation = "Gen. Business Posting Group";

        }
        field(50003; "Manuf. Document Nos."; Code[10])
        {
            Caption = 'Manuf. Document Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50004; "Manuf. Alloc. Source Code"; code[10])
        {
            Caption = 'Manuf. Alloc. Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(50005; "Manuf. Adjmt Source Code"; code[10])
        {
            Caption = 'Manuf. Adjmt Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(50006; "Manuf. Alloc. Reverse SC"; code[10])
        {
            Caption = 'Manuf. Alloc. Reverse SC';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(50007; "Use Giv. Production Func."; Boolean)
        {
            // TODO: перенести зависимости в t12450, t12453 @eapomazkov
            Caption = 'Use Giv. Production Func.';
            Description = 'SWC816, NC 51411 EP';
        }
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
        field(50020; "Giv. Transfer Order Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Giv. Transfer Order Nos.';
            TableRelation = "No. Series";
            Description = 'NC 51410 EP';
        }
    }
}