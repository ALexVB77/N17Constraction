table 70173 "Privete Dimension Value"
{

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = Dimension.Code;
        }
        field(2; "Public Value"; Code[20])
        {
            Caption = 'Public Value';
            TableRelation = "Dimension Value".Code where("Dimension Code" = field(Code));
        }
        field(3; "Privete Value"; Code[20])
        {
            Caption = 'Privete Value';
        }
        field(4; "Privete Value Name"; Text[30])
        {
            Caption = 'Privete Value Name';
            TableRelation = "Dimension Value".Code where("Dimension Code" = field(Code));
        }
    }

    keys
    {
        key(Key1; Code, "Public Value")
        {
            Clustered = true;
        }
    }

}