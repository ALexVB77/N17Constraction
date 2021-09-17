table 70010 "Calculation Journal Line"
{
    Caption = 'Calculation Journal Line';
    Description = '50708';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(50000; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            ClosingDates = true;
            Editable = true;
        }
        field(50001; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(50002; "Description"; Text[50])
        {
            Caption = 'Description';
        }
        field(50003; "Debit Account No."; Code[20])
        {
            Caption = 'Debit Account No.';
            TableRelation = IF ("Debit Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = FILTER('Posting' | 'Total' | 'Begin-Total')) ELSE
            IF ("Debit Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(50004; "Credit Account No."; Code[20])
        {
            Caption = 'Credit Account No.';
            TableRelation = IF ("Credit Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = FILTER('Posting' | 'Total' | 'Begin-Total')) ELSE
            IF ("Credit Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(50005; "Month"; Integer)
        {
            Caption = 'Month';
        }
        field(50006; "Year"; Integer)
        {
            Caption = 'Year';
        }
        field(50007; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(50011; "Last Run Date"; Date)
        {
            Caption = 'Last Run Date';
            Editable = false;
        }
        field(50012; "Last Run Time"; Time)
        {
            Caption = 'Last Run Time';
            Editable = false;
        }
        field(50013; "User ID"; Code[20])
        {
            Caption = 'User ID';
            Editable = false;
        }
        field(50014; "Calculation Type"; Option)
        {
            Caption = 'Calculation Type';
            OptionMembers = "Calculation","Item Allocation";
        }
        field(50022; "Debit Account Type"; Option)
        {
            Caption = 'Debit Account Type';
            OptionMembers = "G/L Account","Bank Account";
        }

        field(50023; "Credit Account Type"; Option)
        {
            Caption = 'Credit Account Type';
            OptionMembers = "G/L Account","Bank Account";
        }
        field(50025; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(50026; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(50027; "Blocked"; Boolean)
        {
            Caption = 'Blocked';
        }
        field(50555; "Calculate Record"; Boolean)
        {
            Caption = 'Calculate Record';
        }
        field(50557; "Analysis View Code"; Code[10])
        {
            Caption = 'Analysis View Code';
            TableRelation = "Analysis View";
        }
        field(50600; "An.View Dimension 1 Filter"; Code[150])
        {
            Caption = 'An.View Dimension 1 Filter';

        }
        field(50955; "Dim. Allocation"; Text[150])
        {
            Caption = 'Dim. Allocation';
            trigger OnLookup()
            begin
                Message('Dim allocation OnLookup trigger');
                // MC IK 20120910 >>
                /*DimAlloc.FILTERGROUP(4);
                DimAlloc.SETRANGE("Calc. Gen. Jnl. Entry No.","Entry No.");
                DimAlloc.SETRANGE("Type Operation",DimAlloc."Type Operation"::DimDistribute);
                DimAlloc.FILTERGROUP(0);
                CLEAR(FormCalcOperand);
                FormCalcOperand.SETTABLEVIEW(DimAlloc);
                FormCalcOperand.SETRECORD(DimAlloc);
                FormCalcOperand.RUN;*/
                // MC IK 20120910 <<   
            end;
        }
        field(51100; "BegEndSaldo"; Option)
        {
            Caption = 'BegEndSaldo';
            Editable = false;
            OptionMembers = "Begin Saldo","End Saldo";
            FieldClass = FlowField;
            CalcFormula = Lookup("Calc. Gen Journal Operand".BegEndSaldo WHERE("Calc. Gen. Jnl. Entry No." = FIELD("Entry No."), "Type Operation" = CONST("SummaLCY")));
        }
        field(51101; "Calc Some Accounts"; Boolean)
        {
            Caption = 'Calc Some Accounts';
        }

    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Year, Month, "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = false;
        }
        key(Key3; Year, Month, "Journal Template Name", "Journal Batch Name", "Document No.")
        {
            Clustered = false;
        }
        key(Key4; Year, Month, "Calculation Type")
        {
            Clustered = false;
        }
    }

    var
        Text003: Label 'You cannot rename a %1';

    trigger OnInsert()
    begin
        SetPostDate;

        "Last Run Date" := 0D;
        "Last Run Time" := 0T;
        "User ID" := '';
    end;

    trigger OnModify()
    begin
        SetPostDate
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin
        ERROR(Text003, TABLECAPTION);
    end;

    procedure SetPostDate()
    var
        Dt: Date;
        M: Integer;
        Y: Integer;
    begin
        IF (Month < 1) OR (Month > 12) OR (Year = 0) THEN BEGIN
            "Posting Date" := 0D;
            EXIT;
        END;

        M := Month + 1;
        Y := Year;
        IF M > 12 THEN BEGIN
            M := M - 12;
            Y := Y + 1;
        END;
        Dt := DMY2DATE(1, M, Y) - 1;
        //MC GS 04.10.2013 >>
        //IF "Posting Date" <> Dt THEN "Posting Date" := Dt;
        IF ("Posting Date" <> Dt) AND ("Posting Date" = 0D)
        THEN
            "Posting Date" := Dt;
        //MC GS 04.10.2013 <<
    end;

}