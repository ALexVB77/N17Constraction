tableextension 70903 "Bank Acc. Reconcil. Line BS" extends "Bank Acc. Reconciliation Line"
{
    fields
    {
        field(50000; "Posted Amount"; Decimal)
        {

            Caption = 'Posted Amount';
            Editable = false;
            BlankZero = true;
            FieldClass = FlowField;
            CalcFormula = Sum("Bank Account Ledger Entry".Amount WHERE("Document Type" = FIELD("Document Type"),
                                                                       "Bal. Account Type" = FIELD("Entity Type"),
                                                                       "Bal. Account No." = FIELD("Entity No."),
                                                                       "Bank Account No." = FIELD("Bank Account No."),
                                                                       "Posting Date" = FIELD("Transaction Date")));
        }
        field(50001; "Unposted Amount"; Decimal)
        {

            Caption = 'Unposted Amount';
            Editable = false;
            BlankZero = true;
            FieldClass = FlowField;
            CalcFormula = Sum("Gen. Journal Line".Amount WHERE("Account Type" = FIELD("Entity Type"),
                                                               "Account No." = FIELD("Entity No."),
                                                               "Document No." = FIELD("Document No."),
                                                               "Posting Date" = FIELD("Transaction Date")));
            /*
            trigger OnLookup()
            var
                gjl: Record "Gen. Journal Line";
                payJnl: Page "Payment Journal";
            begin
                message('click');
                gjl.RESET();
                gjl.SETRANGE("Account Type", "Entity Type");
                gjl.SETRANGE("Account No.", "Entity No.");
                gjl.SETRANGE("Document No.", "Document No.");
                gjl.SETRANGE("Posting Date", "Transaction Date");
                IF (gjl.FINDSET()) THEN BEGIN
                    gjl.SETRANGE("Journal Template Name", gjl."Journal Template Name");
                    gjl.SETRANGE("Journal Batch Name", gjl."Journal Batch Name");
                    gjl.FINDSET();
                    payJnl.SETTABLEVIEW(gjl);
                    payJnl.SETRECORD(gjl);
                    payJnl.RUNMODAL();
                END;
            end;
            */
        }
        field(61120; "Statement Begin Saldo"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Statement begin saldo';
            Editable = false;
        }
        field(61130; "Total Income Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total income amount';
            Editable = false;
        }
        field(61140; "Total Outcome Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total outcome amount';
            Editable = false;
        }
        field(61150; "Statement End Saldo"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Statement end saldo';
            Editable = false;
        }
    }
}