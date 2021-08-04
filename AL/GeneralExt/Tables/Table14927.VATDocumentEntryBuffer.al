tableextension 94927 "VAT Document Entry Buffer GE" extends "VAT Document Entry Buffer"
{
    fields
    {
        field(50005; "VAT Allocation"; Boolean)
        {
            Caption = 'VAT Allocation';
            DataClassification = CustomerContent;
        }
        field(50020; "Cost Code Type"; Option)
        {
            Caption = 'Cost Code Type';
            OptionCaption = ' ,Production,Development,Admin';
            OptionMembers = " ",Production,Development,Admin;
            editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup("Dimension Value"."Cost Code Type" WHERE("Global Dimension No." = CONST(2), Code = FIELD("Global Dimension 2 Code")));
        }
        field(50021; "Global Dimension 1 Filter"; Code[250])
        {
            CaptionClass = '1,3,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = False;
        }
        field(50022; "Global Dimension 2 Filter"; Code[250])
        {
            CaptionClass = '1,3,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = False;
        }
        field(50023; "Cost Code Type Filter"; option)
        {
            Caption = 'Cost Code Type Filter';
            OptionCaption = ' ,Production,Development,Admin';
            OptionMembers = " ",Production,Development,Admin;
        }
    }
}
