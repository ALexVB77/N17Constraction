tableextension 80312 "Purchases & Payab. Setup (Ext)" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50030; "Vendor Agreement Template Code"; Code[250])
        {
            Caption = 'Vendor Agreement Template Code';
            TableRelation = "Excel Template";
        }
        field(50031; "Check Vend. Agr. Template Code"; Code[250])
        {
            Caption = 'Check Vend. Agr. Template Code';
            TableRelation = "Excel Template";
        }
        field(50032; "Aged Acc. Payable Tmplt Code"; Code[250])
        {
            Caption = 'Aged Accounts Payable Template';
            TableRelation = "Excel Template";
        }
    }
}