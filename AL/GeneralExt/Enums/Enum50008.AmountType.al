enum 50008 "Amount Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; " ") { Caption = ''; }
    value(1; "Include VAT") { Caption = 'Include VAT'; }
    value(2; "Exclude VAT") { Caption = 'Exclude VAT'; }
    value(3; "VAT") { Caption = 'VAT'; }
}