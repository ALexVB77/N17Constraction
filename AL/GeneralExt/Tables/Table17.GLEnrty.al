tableextension 80017 "G/L Entry (Ext)" extends "G/L Entry"
{
    fields
    {
        field(50013; ID; Integer)
        {
            Caption = 'ID';
        }
        field(50030; "Cust. Ext. Agr. No."; Text[30])
        {
            Caption = 'Cust. Ext. Agr. No.';
            Description = 'NC 51461 OA';
            FieldClass = FlowField;
            CalcFormula = Lookup("Customer Agreement"."External Agreement No." where("No." = FIELD("Agreement No.")));
            Editable = false;
        }
        field(70000; "IFRS Transfer Status"; Enum "IFRS Transfer Status")
        {
            Caption = 'IFRS Transfer Status';
            Description = 'NC 51559 AB';
        }
        field(70001; "IFRS Account No."; Code[50])
        {
            Caption = 'IFRS Account No.';
            TableRelation = "IFRS Account";
            Description = 'NC 51559 AB';
        }
        field(70002; "IFRS Perid"; Date)
        {
            Caption = 'IFRS Period';
            Description = 'NC 51559 AB';
        }
        field(70003; "IFRS Transfer Date"; Date)
        {
            Caption = 'IFRS Transfer Date';
            Description = 'NC 51559 AB';
        }
        field(70030; "IFRS Mapping Code"; Code[20])
        {
            Editable = false;
            Description = 'NC 51559 AB';
        }
        field(70031; "IFRS Version Code"; Code[20])
        {
            Editable = false;
            Description = 'NC 51559 AB';
        }
    }

    keys
    {
        key(Key50000; ID)
        {

        }
    }



}