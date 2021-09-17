tableextension 70904 "Transformation Rule BS" extends "Transformation Rule"
{
    fields
    {
        field(50000; "Custom Transformation Type"; Enum "Custom Transformation Type BS")
        {
            DataClassification = CustomerContent;
            Caption = 'Custom Transformation Type';

            trigger OnValidate()
            begin
                Rec.TestField("Transformation Type", Rec."Transformation Type"::Custom);
            end;
        }
        field(50001; "Min. Length"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Min. Length';
        }
        field(50002; "Max. Length"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Max. Length';
        }
    }

    procedure setBankAccount(p: code[20])
    var
        ism: Codeunit "Isolated Storage Management BS";
    begin
        ism.setString('T1237.BankAccountCode', p);
    end;

}