table 70008 "Calc. Gen Journal Operand"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';

        }
        field(50000; "Calc. Gen. Jnl. Entry No."; Integer)
        {
            Caption = 'Calc. Gen. Jnl. Entry No.';

        }
        field(50001; "Type Operation"; Option)
        {
            Caption = 'Type Operation';
            OptionMembers = "Condition","SummaLCY","Base","BaseItem","Distribute","DistributeItem","DimDistribute";

        }
        field(50002; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }

        field(50003; "Text"; Text[60])
        {
            DataClassification = ToBeClassified;
            Caption = 'Text';
        }
        field(50004; Sign; Option)
        {
            Caption = 'Sign';
            OptionMembers = " ","+","-","*","/",">",">=","<","<=","<>","=","AND","OR";
            OptionCaption = ' , +, -, *, /, >,>=, <,<=,<>, =,AND,OR';
        }
        field(50005; "Operand Type"; Option)
        {
            Caption = 'Operand Type';
            OptionMembers = "Oborot","Saldo","Decimal","Curs","Variable";
            OptionCaption = 'Oborot,Saldo,Decimal,Curs,Variable';
        }
        field(50006; "Debit/Credit Type"; Option)
        {
            Caption = 'Operand Type';
            OptionMembers = "Debit","Credit";
            OptionCaption = 'Debit,Credit';
        }
        field(50007; "Account"; Code[250])
        {
            Caption = 'Account';
            TableRelation = "G/L Account" WHERE("Account Type" = FILTER("Posting" | "Total" | "Begin-Total"));
            ValidateTableRelation = false;
        }
        field(50008; "Account Corr."; Code[250])
        {
            Caption = 'Account Corr';
        }
        field(50009; "Decimal Amount"; Decimal)
        {
            Caption = 'Decimal Amount';
        }
        field(50011; "Amount"; Decimal)
        {
            Caption = 'Amount';
        }
        field(50012; "ResBoolean"; Boolean)
        {
            Caption = 'ResBoolean';
        }

        field(50013; "FlagBoolean"; Boolean)
        {
            Caption = 'FlagBoolean';
        }

        field(50014; "BegEndSaldo"; Option)
        {
            Caption = 'BegEndSaldo';
            OptionMembers = "BegSaldo","EndSaldo";
        }
        field(50015; "Amount Type"; Option)
        {
            Caption = 'Amount Type';
            OptionMembers = "LCY","Currency";
        }
        field(50016; "Currency Code"; code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(50019; "Item No."; code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(50143; "Opening Bracket"; Boolean)
        {
            Caption = 'Opening Bracket';

        }
        field(50144; "Closing Bracket"; Boolean)
        {
            Caption = 'Closing Bracket';

        }
        field(50145; "Level"; Integer)
        {
            Caption = 'Level';
        }
        field(50146; "All Account"; Boolean)
        {
            Caption = 'All Account';
        }
        field(50153; "LevelBase"; Integer)
        {
            Caption = 'LevelBase';
        }
        field(50155; "Distribution Item No. Filter"; Code[250])
        {
            Caption = 'Distribution Item No. Filter';
            TableRelation = Item;
        }
        field(50156; "Distr. Item Category Filter"; Code[100])
        {
            Caption = 'Distr. Item Category Filter';
            TableRelation = "Item Category";
        }
        field(50157; "Distr. Product Group Filter"; Code[100])
        {
            Caption = 'Distr. Product Group Filter';
            TableRelation = "Item Category"."Code";
            Description = 'NC 50708, tableRelation changed to Item Category';
        }
        field(50158; "Distr. Location Code Filter"; Code[100])
        {
            Caption = 'Distr. Location Code Filter';
            TableRelation = Location;

        }
        field(50159; "Variable Name"; Code[10])
        {
            Caption = 'Variable Name';
        }
        field(50200; "Credit Account No."; Code[20])
        {
            Caption = 'Credit Account No.';
            TableRelation = "G/L Account" WHERE("Account Type" = FILTER("Posting" | "Total" | "Begin-Total"));
        }


    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Calc. Gen. Jnl. Entry No.", "Type Operation", "Line No.")
        {

        }
    }
}