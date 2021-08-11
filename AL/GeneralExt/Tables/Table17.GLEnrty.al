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

    }

    keys
    {
        key(Key50000; ID)
        {

        }
    }



}