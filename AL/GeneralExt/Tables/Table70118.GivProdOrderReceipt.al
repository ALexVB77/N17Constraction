table 70118 "Giv. Prod. Order Receipt"
{
    Caption = 'Giv. Prod. Order Receipt';
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
            TableRelation = IF (Correction = CONST(true)) "Item Receipt Header"."No." WHERE(Correction = CONST(true)) ELSE
            IF (Posted = CONST(true)) "Item Receipt Header"."No." ELSE
            IF (Posted = CONST(false)) "Item Document Header"."No." WHERE("Document Type" = CONST(Receipt));
            trigger OnValidate()
            var
                GivProdOrderRcpt: Record "Giv. Prod. Order Receipt";
                GivProdOrderShpmt: Record "Giv. Prod. Order Shipment";
                GivProdOrderJob: Record "Giv. Prod. Order Job";
                ItemRcptHdr2: Record "Item Receipt Header";
                ItemRcptLine2: Record "Item Receipt Line";
                ILE: Record "Item Ledger Entry";
                ItemShpmtHdr: Record "Item Shipment Header";
                LineNo: Integer;
                RcptActNo: Code[20];
                locLabel001: label 'Строка коррекции выпуска уже заведена';
                locLabel002: label 'Строка выпуска уже заведена';
                locLabel003: label 'Коррекция выпуска %1 должна быть применена к выпуску %2';
                locLabel004: label 'Сначала отмените распределение';

            begin

                CheckLine();

                GivProdOrderRcpt.RESET;
                GivProdOrderRcpt.SETRANGE("Order No.", "Order No.");
                GivProdOrderRcpt.SETFILTER("Line No.", '<>%1', "Line No.");
                GivProdOrderRcpt.SETRANGE(Correction, Correction);
                GivProdOrderRcpt.SETRANGE(Reversed, FALSE);
                IF NOT GivProdOrderRcpt.ISEMPTY THEN
                    IF Correction THEN
                        ERROR(locLabel001)
                    ELSE
                        ERROR(locLabel002);

                IF "Document No." <> '' THEN BEGIN
                    IF Correction THEN BEGIN
                        ItemRcptHdr.GET("Document No.");
                        GivProdOrderRcpt.RESET;
                        GivProdOrderRcpt.SETRANGE("Order No.", "Order No.");
                        GivProdOrderRcpt.SETFILTER("Line No.", '<>%1', "Line No.");
                        GivProdOrderRcpt.SETRANGE(Correction, FALSE);
                        GivProdOrderRcpt.SETRANGE(Reversed, FALSE);
                        GivProdOrderRcpt.FINDFIRST;

                        ItemRcptHdr2.GET(GivProdOrderRcpt."Document No.");
                        ItemRcptHdr.TESTFIELD("Location Code", ItemRcptHdr2."Location Code");
                        ItemRcptHdr.TESTFIELD("Shortcut Dimension 1 Code", ItemRcptHdr2."Shortcut Dimension 1 Code");
                        ItemRcptHdr.TESTFIELD("Shortcut Dimension 2 Code", ItemRcptHdr2."Shortcut Dimension 2 Code");
                        ItemRcptHdr.TESTFIELD("Gen. Bus. Posting Group", ItemRcptHdr2."Gen. Bus. Posting Group");
                        ItemRcptHdr.TESTFIELD("Vendor No.", ItemRcptHdr2."Vendor No.");
                        ItemRcptHdr.TESTFIELD("Agreement No.", ItemRcptHdr2."Agreement No.");

                        ItemRcptLine.RESET;
                        ItemRcptLine.SETRANGE("Document No.", ItemRcptHdr."No.");

                        ItemRcptLine2.RESET;
                        ItemRcptLine2.SETRANGE("Document No.", ItemRcptHdr2."No.");
                        IF ItemRcptLine2.FINDSET THEN
                            REPEAT
                                ItemRcptLine.SETRANGE("Item No.", ItemRcptLine2."Item No.");
                                ItemRcptLine.SETRANGE("Variant Code", ItemRcptLine2."Variant Code");
                                ItemRcptLine.SETRANGE(Quantity, ItemRcptLine2.Quantity);
                                ItemRcptLine.SETRANGE("Location Code", ItemRcptLine2."Location Code");
                                ItemRcptLine.SETRANGE("Bin Code", ItemRcptLine2."Bin Code");
                                ItemRcptLine.FINDFIRST;
                                ItemRcptLine.TESTFIELD("Applies-to Entry");

                                ILE.GET(ItemRcptLine."Applies-to Entry");
                                IF ILE."Document No." <> ItemRcptHdr2."No." THEN
                                    ERROR(locLabel003,
                                      ItemRcptHdr."No.", ItemRcptHdr2."No.");
                            UNTIL
                              ItemRcptLine2.NEXT = 0;

                        GivProdOrderJob.RESET;
                        GivProdOrderJob.SETRANGE("Order No.", "Order No.");
                        GivProdOrderJob.SETRANGE(Reversed, FALSE);
                        IF NOT GivProdOrderJob.ISEMPTY THEN
                            ERROR(locLabel004);

                        VALIDATE("Posting Date", ItemRcptHdr."Posting Date");
                        VALIDATE(Description, COPYSTR(ItemRcptHdr."Posting Description", 1, MAXSTRLEN(Description)));
                        VALIDATE("Location Code", ItemRcptHdr."Location Code");
                        VALIDATE("Gen. Bus. Posting Group", ItemRcptHdr."Gen. Bus. Posting Group");
                        VALIDATE("Shortcut Dimension 1 Code", ItemRcptHdr."Shortcut Dimension 1 Code");
                        VALIDATE("Shortcut Dimension 2 Code", ItemRcptHdr."Shortcut Dimension 2 Code");

                        LineNo := GivProdOrderRcpt."Line No.";
                        GivProdOrderRcpt.VALIDATE(Reversed, TRUE);
                        GivProdOrderRcpt.MODIFY(FALSE);
                        VALIDATE(Reversed, TRUE);
                        VALIDATE(Posted, TRUE);

                        GivProdOrderShpmt.RESET;
                        GivProdOrderShpmt.SETRANGE("Order No.", "Order No.");
                        GivProdOrderShpmt.SETRANGE(Correction, FALSE);
                        GivProdOrderShpmt.FINDLAST;

                        ItemShpmtHdr.GET(GivProdOrderShpmt."Document No.");
                        RcptActNo := ItemShpmtHdr.CreateRcptAct("Order No.");

                        GivProdOrderRcpt.RESET;
                        GivProdOrderRcpt.INIT;
                        GivProdOrderRcpt."Order No." := "Order No.";
                        GivProdOrderRcpt."Line No." := LineNo + 20000;
                        GivProdOrderRcpt.INSERT(TRUE);
                        GivProdOrderRcpt.VALIDATE("Document No.", RcptActNo);
                        GivProdOrderRcpt.MODIFY(TRUE);
                    END
                    ELSE
                        IF NOT Posted THEN BEGIN
                            ItemDocHdr.GET(ItemDocHdr."Document Type"::Receipt, "Document No.");
                            VALIDATE("Posting Date", ItemDocHdr."Posting Date");
                            VALIDATE(Description, COPYSTR(ItemDocHdr."Posting Description", 1, MAXSTRLEN(Description)));
                            VALIDATE("Location Code", ItemDocHdr."Location Code");
                            VALIDATE("Gen. Bus. Posting Group", ItemDocHdr."Gen. Bus. Posting Group");
                            VALIDATE("Shortcut Dimension 1 Code", ItemDocHdr."Shortcut Dimension 1 Code");
                            VALIDATE("Shortcut Dimension 2 Code", ItemDocHdr."Shortcut Dimension 2 Code");
                        END;
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
        field(7; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            tablerelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            captionclass = '1,2,1';
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(8; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            tablerelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            captionclass = '1,2,2';
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 2 Code");
            end;
        }
        field(9; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(10; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
            trigger OnValidate()
            begin

                IF "Location Code" <> '' THEN BEGIN
                    InvtSetup.GET;
                    TESTFIELD("Location Code", InvtSetup."Giv. Production Loc. Code");
                END;
            end;
        }
        field(11; "Purchaser Code"; Code[10])
        {
            Caption = 'Purchaser Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(12; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(13; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim;
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
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
        DimMgt: Codeunit "DimensionManagement";
        InvtSetup: Record "Inventory Setup";
        GivProdOrder: Record "Giv. Prod. Order";
        ItemDocHdr: Record "Item Document Header";
        ItemRcptHdr: Record "Item Receipt Header";
        ItemRcptLine: Record "Item Receipt Line";

    trigger OnModify()

    begin

        CheckLine();
        IF (NOT Posted) AND (NOT Correction) THEN
            IF ItemDocHdr.GET(ItemDocHdr."Document Type"::Receipt, "Document No.") THEN BEGIN

                ItemDocHdr.SetChangeFromGivProdOrder(TRUE);
                IF ItemDocHdr."Posting Description" <> Description THEN
                    ItemDocHdr.VALIDATE("Posting Description", Description);

                IF ItemDocHdr."Posting Date" <> "Posting Date" THEN
                    ItemDocHdr.VALIDATE("Posting Date", "Posting Date");

                IF ItemDocHdr."Location Code" <> "Location Code" THEN
                    ItemDocHdr.VALIDATE("Location Code", "Location Code");

                IF ItemDocHdr."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" THEN
                    ItemDocHdr.VALIDATE("Gen. Bus. Posting Group", "Gen. Bus. Posting Group");

                IF ItemDocHdr."External Document No." <> "External Document No." THEN
                    ItemDocHdr.VALIDATE("External Document No.", "External Document No.");

                IF ItemDocHdr."Shortcut Dimension 1 Code" <> "Shortcut Dimension 1 Code" THEN
                    ItemDocHdr.VALIDATE("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");

                IF ItemDocHdr."Shortcut Dimension 2 Code" <> "Shortcut Dimension 2 Code" THEN
                    ItemDocHdr.VALIDATE("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");

                IF ItemDocHdr."Salesperson/Purchaser Code" <> "Purchaser Code" THEN
                    ItemDocHdr.VALIDATE("Salesperson/Purchaser Code", "Purchaser Code");

                ItemDocHdr.MODIFY(TRUE);
            END;

    end;

    trigger OnDelete()
    begin

        CheckLine();
        IF NOT Posted THEN BEGIN
            IF ItemDocHdr.GET(ItemDocHdr."Document Type"::Receipt, "Document No.") THEN
                ItemDocHdr.DELETE(TRUE);
        END;
    end;

    trigger OnRename()
    begin
        CheckLine();
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])

    begin

        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");

    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;

    begin

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2', "Order No.", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify;
        end;
    end;

    procedure CheckLine()
    var 
    locLabel001 : label 'Заказ %1 уже завершен';
    locLabel002 : label 'Изменение строки выпуска %1 по заказу %2 запрещено\Строка учтена';
    begin

        IF GivProdOrder.GET("Order No.") THEN
            IF GivProdOrder.Finished THEN
                ERROR(locLabel001, GivProdOrder."No.");

        IF xRec.Posted THEN
            ERROR(locLabel002,
              "Document No.", "Order No.");

    end;
}
