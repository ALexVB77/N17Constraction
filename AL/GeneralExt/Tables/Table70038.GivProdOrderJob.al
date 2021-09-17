table 70038 "Giv. Prod. Order Job"
{
    Caption = 'Giv. Prod. Order Job';
    DataClassification = ToBeClassified;


    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Giv. Prod. Order";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Correction; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                VALIDATE("Document No.", '');
            end;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Correction = CONST(false)) "Purch. Inv. Header"."No." ELSE
            IF (Correction = CONST(true)) "Purch. Cr. Memo Hdr."."No.";
            trigger OnValidate()
            var
                AmountForAlloc: Decimal;
                GivProdOrderRcpt: Record "Giv. Prod. Order Receipt";
                locLabel001 : label 'Сначала учтите выпуск';
                locLabel002 : label 'Счет %1 уже был распределен в произв. заказе %2';
                locLabel003 : label 'Счет %1 не может быть выбран в качестве работы, т.к. содержит строку с типом %2';
                locLabel004 : label 'Кредит-нота %1 уже была распределена в произв. заказе %2';
                locLabel005 : label 'Кредит-нота %1 не может быть выбрана в качестве работы, т.к. содержит строку с типом %2';
                
            begin

                CheckLine();

                GivProdOrderRcpt.RESET;
                GivProdOrderRcpt.SETRANGE("Order No.", "Order No.");
                GivProdOrderRcpt.SETRANGE(Correction, FALSE);
                GivProdOrderRcpt.SETRANGE(Posted, TRUE);
                GivProdOrderRcpt.SETRANGE(Reversed, FALSE);
                IF NOT GivProdOrderRcpt.FINDLAST THEN
                    ERROR(locLabel001);

                IF "Document No." <> '' THEN BEGIN
                    AmountForAlloc := 0;
                    IF NOT Correction THEN BEGIN
                        PurchInvHdr.GET("Document No.");
                        IF PurchInvHdr."Giv. Prod. Order No." <> '' THEN
                            ERROR(locLabel002,
                              PurchInvHdr."No.", PurchInvHdr."Giv. Prod. Order No.");

                        PurchInvLine.RESET;
                        PurchInvLine.SETRANGE("Document No.", PurchInvHdr."No.");
                        IF PurchInvLine.FINDSET THEN
                            REPEAT
                                IF NOT (PurchInvLine.Type IN [PurchInvLine.Type::" ",
                                                              PurchInvLine.Type::"G/L Account"]) THEN
                                    ERROR(locLabel003,
                                      PurchInvHdr."No.", PurchInvLine.Type);
                                AmountForAlloc += PurchInvLine."Amount (LCY)";
                            UNTIL
                              PurchInvLine.NEXT = 0;

                        PurchInvHdr.GivProdOrderCheckDocDim(
                          GivProdOrderRcpt."Document No.", GivProdOrderRcpt.Posted);

                        VALIDATE(Description,
                          COPYSTR(PurchInvHdr."Posting Description", 1, MAXSTRLEN(Description)));
                        VALIDATE("Posting Date", PurchInvHdr."Posting Date");
                    END
                    ELSE BEGIN
                        PurchCrMemoHdr.GET("Document No.");
                        IF PurchCrMemoHdr."Giv. Prod. Order No." <> '' THEN
                            ERROR(locLabel004,
                              PurchCrMemoHdr."No.", PurchCrMemoHdr."Giv. Prod. Order No.");

                        PurchCrMemoLine.RESET;
                        PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHdr."No.");
                        IF PurchCrMemoLine.FINDSET THEN
                            REPEAT
                                IF NOT (PurchCrMemoLine.Type IN [PurchCrMemoLine.Type::" ",
                                                                 PurchCrMemoLine.Type::"G/L Account"]) THEN
                                    ERROR(locLabel005,
                                      PurchCrMemoHdr."No.", PurchCrMemoLine.Type);
                                AmountForAlloc += -PurchCrMemoLine."Amount (LCY)";
                            UNTIL
                              PurchCrMemoLine.NEXT = 0;

                        PurchCrMemoHdr.GivProdOrderCheckDocDim(
                          GivProdOrderRcpt."Document No.", GivProdOrderRcpt.Posted);

                        VALIDATE(Description,
                          COPYSTR(PurchCrMemoHdr."Posting Description", 1, MAXSTRLEN(Description)));
                        VALIDATE("Posting Date", PurchCrMemoHdr."Posting Date");
                    END;

                    VALIDATE(Amount, AmountForAlloc);
                END;

            end;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(8; "Allocated Amount"; Decimal)
        {
            Caption = 'Allocated Amount';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Document No." = FIELD("Document No."), "Order No." = FIELD("Order No."), "Order Line No." = FIELD("Line No.")));
        }
        field(9; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
            Editable = False;
        }
    }
    keys
    {
        key(PK; "Order No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        GivProdOrder: Record "Giv. Prod. Order";
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";

    trigger OnModify()
    begin
        CheckLine();
    end;

    trigger OnDelete()
    begin
        CheckLine();
    end;

    trigger OnRename()
    begin
        CheckLine();
    end;

    procedure CheckLine()
    var

        VE: Record "Value Entry";
        locLabel001 : label 'Заказ %1 уже завершен';
        locLabel002 : label 'Изменение строки работы %1 по заказу %2 запрещено\По строке сделано распределение';
    begin

        IF GivProdOrder.GET("Order No.") THEN
            IF GivProdOrder.Finished THEN
                ERROR(locLabel001, GivProdOrder."No.");

        VE.RESET;
        VE.SETCURRENTKEY("Document No.", "Document Type", "Document Line No.", Adjustment,
          "Order No.", "Order Line No.");
        VE.SETRANGE("Document No.", xRec."Document No.");
        ve.SetRange("Order Type", ve."order type"::Production);
        VE.SETRANGE("Order No.", xRec."Order No.");
        VE.SETRANGE("Order Line No.", xRec."Line No.");
        IF NOT VE.ISEMPTY THEN
            ERROR(locLabel002,
              xRec."Document No.", xRec."Order No.");
    end;
}
