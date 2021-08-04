table 70048 "Giv. Prod. Order"
{
    Caption = 'Giv. Prod. Order';
    Permissions = TableData "Purch. Inv. Header" = rm,
                  TableData "Purch. Cr. Memo Hdr." = rm,
                  TableData "Value Entry" = rm;
    DataClassification = CustomerContent;
    LookupPageId = "Giv. Prod. Order List";
    DrillDownPageId = "Giv. Prod. Order List";
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IF "No." <> xRec."No." THEN BEGIN
                    InvtSetup.GET;
                    NoSeriesMgt.TestManual(InvtSetup."Manuf. Document Nos.");
                    "No. Series" := '';
                END;

            end;
        }
        field(2; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(3; Description; text[50])
        {
            Caption = 'Description';
            DataClassification = customerContent;
        }
        field(4; Finished; Boolean)
        {
            Caption = 'Finished';
            DataClassification = customerContent;
        }
        field(5; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }


    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var

        InvtSetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GivProdOrderShpmt: Record "Giv. Prod. Order Shipment";
        GivProdOrderRcpt: Record "Giv. Prod. Order Receipt";
        GivProdOrderJob: Record "Giv. Prod. Order Job";

    trigger OnInsert()
    begin

        IF "Document Date" = 0D THEN
            "Document Date" := WORKDATE;

        IF "No." = '' THEN BEGIN
            InvtSetup.GET;
            InvtSetup.TESTFIELD("Manuf. Document Nos.");
            NoSeriesMgt.InitSeries(InvtSetup."Manuf. Document Nos.", xRec."No. Series", "Document Date", "No.", "No. Series");
        END;

    end;

    trigger OnDelete()
    begin
        GivProdOrderRcpt.RESET;
        GivProdOrderRcpt.SETRANGE("Order No.", "No.");
        GivProdOrderRcpt.SETRANGE(Posted, TRUE);
        IF NOT GivProdOrderRcpt.ISEMPTY THEN
            ERROR('Нельзя удалить %1\Учтен акт оприходования ГП', TABLECAPTION);

        GivProdOrderRcpt.SETRANGE(Posted);
        GivProdOrderRcpt.DELETEALL(TRUE);

        GivProdOrderShpmt.RESET;
        GivProdOrderShpmt.SETRANGE("Order No.", "No.");
        GivProdOrderShpmt.DELETEALL(TRUE);

        GivProdOrderJob.RESET;
        GivProdOrderJob.SETRANGE("Order No.", "No.");
        GivProdOrderJob.DELETEALL(TRUE);
    end;



    procedure AssistEdit(OldGivProdOrder: Record "Giv. Prod. Order"): Boolean
    begin
        InvtSetup.GET;
        InvtSetup.TESTFIELD("Manuf. Document Nos.");
        IF NoSeriesMgt.SelectSeries(InvtSetup."Manuf. Document Nos.", OldGivProdOrder."No. Series", "No. Series") THEN BEGIN
            NoSeriesMgt.SetSeries("No.");
            EXIT(TRUE);
        END;
    end;

    procedure AllocateJobs(Reverse: Boolean)
    var

        TotalAmount: Decimal;
        TotalQuantity: Decimal;
        AmountForAlloc: Decimal;
        AmountDiff: Decimal;
        ILE: Record "Item Ledger Entry";
        IJL: Record "Item Journal Line";
        JnlTemplName: Code[10];
        JnlBatchName: Code[10];
        JnlType: Option;
        LineNo: Integer;
        GLSetup: Record "General Ledger Setup";
        IJLPost: Codeunit "Item Jnl.-Post";
        IJT: Record "Item Journal Template";
        IJB: Record "Item Journal Batch";
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        VE: Record "Value Entry";
        VENew: Record "Value Entry";
        ism: codeunit "Isolated Storage Management GE";
        locLabel001: label 'Здесь нечего распределять';
        locLabel002: label 'Здесь нечего отменять';
        locLabel003: label 'Не учтен приход готовой продукции';
        locLabel004: label '816_TEMP';
    begin

        TESTFIELD(Finished, FALSE);

        TotalAmount := 0;
        GivProdOrderJob.RESET;
        GivProdOrderJob.SETRANGE("Order No.", "No.");
        GivProdOrderJob.SETRANGE(Reversed, FALSE);
        IF GivProdOrderJob.FINDSET THEN
            REPEAT
                GivProdOrderJob.CALCFIELDS("Allocated Amount");
                TotalAmount += GivProdOrderJob.Amount - GivProdOrderJob."Allocated Amount";
            UNTIL
              GivProdOrderJob.NEXT = 0;

        IF NOT Reverse THEN BEGIN
            IF (TotalAmount = 0) OR (GivProdOrderJob.ISEMPTY) THEN
                ERROR(locLabel001);
        END
        ELSE BEGIN
            IF (TotalAmount <> 0) OR (GivProdOrderJob.ISEMPTY) THEN
                ERROR(loclabel002);
        END;

        GivProdOrderRcpt.RESET;
        GivProdOrderRcpt.SETRANGE("Order No.", "No.");
        GivProdOrderRcpt.SETRANGE(Correction, FALSE);
        GivProdOrderRcpt.SETRANGE(Reversed, FALSE);
        GivProdOrderRcpt.FINDLAST;

        TotalQuantity := 0;
        ILE.RESET;
        ILE.SETCURRENTKEY("Document No.", "Posting Date");
        ILE.SETRANGE("Document No.", GivProdOrderRcpt."Document No.");
        ILE.SETRANGE("Posting Date", GivProdOrderRcpt."Posting Date");
        IF ILE.FINDSET THEN
            REPEAT
                TotalQuantity += ILE.Quantity;
            UNTIL
              ILE.NEXT = 0;

        IF TotalQuantity = 0 THEN
            ERROR(locLabel003);



        JnlTemplName := locLabel004;
        JnlType := 816;
        IF STRLEN("No.") > MAXSTRLEN(JnlBatchName) THEN
            JnlBatchName := COPYSTR("No.", STRLEN("No.") - MAXSTRLEN(JnlBatchName) + 1)
        ELSE
            JnlBatchName := "No.";

        GLSetup.GET;
        InvtSetup.GET;
        InvtSetup.TESTFIELD("Manuf. Alloc. Source Code");
        InvtSetup.TESTFIELD("Manuf. Alloc. Reverse SC");

        GivProdOrderJob.RESET;
        GivProdOrderJob.SETRANGE("Order No.", "No.");
        GivProdOrderJob.SETRANGE(Reversed, FALSE);
        IF GivProdOrderJob.FINDSET THEN
            REPEAT
                IF NOT IJT.GET(JnlTemplName) THEN BEGIN
                    IJT.INIT;
                    IJT.Name := JnlTemplName;
                    //IJT.Type := JnlType;
                    ijt.type := ijt.type::"816"; // NC 51414 GG
                    IJT.INSERT;
                END;

                IF NOT IJB.GET(JnlTemplName, JnlBatchName) THEN BEGIN
                    IJB.INIT;
                    IJB."Journal Template Name" := JnlTemplName;
                    IJB.Name := JnlBatchName;
                    IJB.INSERT;
                END;

                IJL.RESET;
                IJL.FILTERGROUP(2);
                IJL.SETRANGE("Journal Template Name", JnlTemplName);
                IJL.SETRANGE("Journal Batch Name", JnlBatchName);
                IJL.FILTERGROUP(0);
                IJL.DELETEALL(TRUE);

                GivProdOrderJob.CALCFIELDS("Allocated Amount");
                IF NOT Reverse THEN
                    TotalAmount := GivProdOrderJob.Amount - GivProdOrderJob."Allocated Amount"
                ELSE
                    TotalAmount := -GivProdOrderJob.Amount;

                IF TotalAmount <> 0 THEN BEGIN
                    LineNo := 0;
                    AmountDiff := TotalAmount;
                    ILE.RESET;
                    ILE.SETCURRENTKEY("Document No.", "Posting Date");
                    ILE.SETRANGE("Document No.", GivProdOrderRcpt."Document No.");
                    ILE.SETRANGE("Posting Date", GivProdOrderRcpt."Posting Date");
                    IF ILE.FINDSET THEN
                        REPEAT
                            LineNo += 10000;
                            IJL.INIT;
                            IJL."Journal Template Name" := JnlTemplName;
                            IJL."Journal Batch Name" := JnlBatchName;
                            IJL."Line No." := LineNo;
                            IJL.INSERT(TRUE);
                            IJL.VALIDATE("Document No.", GivProdOrderJob."Document No.");
                            IJL.VALIDATE("Item No.", ILE."Item No.");
                            IJL.VALIDATE("Variant Code", ILE."Variant Code");
                            IJL.VALIDATE("Value Entry Type", IJL."Value Entry Type"::Revaluation);
                            IJL.VALIDATE("Applies-to Entry", ILE."Entry No.");
                            AmountForAlloc := ROUND(TotalAmount * IJL.Quantity / TotalQuantity, GLSetup."Amount Rounding Precision");
                            AmountDiff -= AmountForAlloc;
                            IJL.VALIDATE("Inventory Value (Revalued)", IJL."Inventory Value (Calculated)" + AmountForAlloc);
                            IJL.VALIDATE("Gen. Bus. Posting Group", GivProdOrderRcpt."Gen. Bus. Posting Group");
                            IJL.VALIDATE("Shortcut Dimension 1 Code", GivProdOrderRcpt."Shortcut Dimension 1 Code");
                            IJL.VALIDATE("Shortcut Dimension 2 Code", GivProdOrderRcpt."Shortcut Dimension 2 Code");
                            IF NOT Reverse THEN
                                IJL.VALIDATE("Source Code", InvtSetup."Manuf. Alloc. Source Code")
                            ELSE
                                IJL.VALIDATE("Source Code", InvtSetup."Manuf. Alloc. Reverse SC");
                            IJL.VALIDATE("Posting Date", GivProdOrderJob."Posting Date");
                            IJL.MODIFY(TRUE);
                        UNTIL
                          ILE.NEXT = 0;

                    IF AmountDiff <> 0 THEN BEGIN
                        IJL.FINDLAST;
                        AmountForAlloc := ROUND(TotalAmount * IJL.Quantity / TotalQuantity, GLSetup."Amount Rounding Precision");
                        IJL.VALIDATE("Inventory Value (Revalued)",
                          IJL."Inventory Value (Calculated)" +
                          AmountForAlloc + ROUND(AmountDiff, GLSetup."Amount Rounding Precision"));
                        IJL.MODIFY(TRUE);
                    END;
                END;

                IF NOT IJL.ISEMPTY THEN BEGIN
                    CLEAR(IJLPost);
                    //IJLPost.SetNotAsk(TRUE);
                    ism.setBool('NotAsk', true);// NC GG
                    IJLPost.RUN(IJL);

                    VE.RESET;
                    VE.SETCURRENTKEY("Document No.", "Document Type", "Document Line No.", Adjustment,
                      "Order No.", "Order Line No.");
                    VE.SETRANGE("Document No.", GivProdOrderJob."Document No.");
                    ve.setrange("Order Type", ve."Order Type"::Production); // NC GG
                    VE.SETRANGE("Order No.", '');
                    VE.SETRANGE("Order Line No.", 0);
                    IF NOT Reverse THEN
                        VE.SETRANGE("Source Code", InvtSetup."Manuf. Alloc. Source Code")
                    ELSE
                        VE.SETRANGE("Source Code", InvtSetup."Manuf. Alloc. Reverse SC");

                    IF NOT VE.ISEMPTY THEN BEGIN
                        VE.FINDSET;
                        REPEAT
                            VENew := VE;
                            venew."Order Type" := venew."Order Type"::Production; // NC GG
                            VENew."Order No." := GivProdOrderJob."Order No.";
                            VENew."Order Line No." := GivProdOrderJob."Line No.";
                            VENew.MODIFY(TRUE);
                        UNTIL
                          VE.NEXT = 0;
                    END;

                    IF NOT GivProdOrderJob.Correction THEN BEGIN
                        PurchInvHdr.GET(GivProdOrderJob."Document No.");
                        IF NOT Reverse THEN
                            PurchInvHdr."Giv. Prod. Order No." := "No."
                        ELSE
                            PurchInvHdr."Giv. Prod. Order No." := '';
                        PurchInvHdr.MODIFY(TRUE);
                    END
                    ELSE BEGIN
                        PurchCrMemoHdr.GET(GivProdOrderJob."Document No.");
                        IF NOT Reverse THEN
                            PurchCrMemoHdr."Giv. Prod. Order No." := "No."
                        ELSE
                            PurchCrMemoHdr."Giv. Prod. Order No." := '';
                        PurchCrMemoHdr.MODIFY(TRUE);
                    END;
                END;
            UNTIL
              GivProdOrderJob.NEXT = 0;

        IF Reverse THEN BEGIN
            GivProdOrderJob.RESET;
            GivProdOrderJob.SETRANGE("Order No.", "No.");
            GivProdOrderJob.MODIFYALL(Reversed, TRUE);
        END;

        IF IJB.GET(JnlTemplName, JnlBatchName) THEN
            IJB.DELETE(TRUE);

        IF IJT.GET(JnlTemplName) THEN
            IJT.DELETE(TRUE);

    end;
}