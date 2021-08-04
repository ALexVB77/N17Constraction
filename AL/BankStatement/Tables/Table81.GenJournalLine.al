tableextension 99991 "Gen. Journal Line BS" extends "Gen. Journal Line"
{
    fields
    {
        field(50060; "Payer KPP"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Payer KPP';
        }
    }
    procedure setupNewLine2(PageNo: integer)

    begin
        CASE PageNo OF
            PAGE::"Payment Journal":
                BEGIN
                    if ("Bal. Account Type" = "Bal. Account Type"::"Bank Account") then begin
                        VALIDATE("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                        VALIDATE("Payment Method", "Payment Method"::Electronic);
                        VALIDATE("Payment Subsequence", '5');
                        VALIDATE("Payment Type", '01');
                    end;
                END;
            PAGE::"Cash Order Journal":
                BEGIN
                    "Bank Payment Type" := "Bank Payment Type"::"Computer Check";
                    "Document Type" := "Document Type"::" ";
                END;
        END;

    end;
}