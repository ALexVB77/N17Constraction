tableextension 70905 "Payment Export Data BS" extends "Payment Export Data"
{
    fields
    {
        field(52480; KBK; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'KBK';
            TableRelation = KBK;
        }
        field(52481; OKATO; Code[11])
        {
            DataClassification = CustomerContent;
            Caption = 'OKATO';
            TableRelation = OKATO;
        }
        field(52483; "Payment Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Reason Code';
            TableRelation = "Payment Order Code".Code where(Type = const("Payment Reason"));
        }
        field(52484; "Reason Document No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Document No.';
        }
        field(52485; "Reason Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Document Date';
        }
        field(52486; "Tax Payment Type"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Tax Payment Type';
            TableRelation = "Payment Order Code".Code where(Type = const("Tax Payment Type"));
        }
        field(52487; "Tax Period"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Tax Period';
        }
        field(52489; "Taxpayer Status"; Enum "Taxpayer Status Enum BS")
        {
            DataClassification = CustomerContent;
            Caption = 'Taxpayer Status';
        }
        field(52490; UIN; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'UIN';

        }
    }
}