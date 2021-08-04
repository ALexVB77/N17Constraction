tableextension 80254 "Vat Entry GE" extends "VAT Entry"
{
    fields
    {
        // >>

        // Ахтунг: заполнение полей 50001,50002 происходит в cu50006 в подписке на инсерт записи т.253
        //         и, на всякий случай, в подписке на модифай т.17

        // <<
        field(50001; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(50002; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(50003; "Cost Code Type"; Option)
        {
            Caption = 'Cost Code Type';
            OptionCaption = ' ,Production,Development,Admin';
            OptionMembers = " ",Production,Development,Admin;
            editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup("Dimension Value"."Cost Code Type" WHERE("Global Dimension No." = CONST(2), Code = FIELD("Global Dimension 2 Code")));
        }
        field(50005; "VAT Allocation"; Boolean)
        {
            Caption = 'VAT Allocation';
            DataClassification = CustomerContent;
        }

    }
}
