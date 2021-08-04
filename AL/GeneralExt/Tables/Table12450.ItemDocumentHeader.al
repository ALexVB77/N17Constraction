tableextension 92450 "Item Document Header (Ext)" extends "Item Document Header"
{
    fields
    {
        field(50000; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                myInt: Integer;
            begin

                // SWC816 AK 200416 >>
                VALIDATE("Agreement No.", '');
                UpdateItemDocLines(FIELDNO("Vendor No."));
                // SWC816 AK 200416 <<

            end;
        }
        field(50001; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            TableRelation = "Vendor Agreement"."No." WHERE("Vendor No." = FIELD("Vendor No."));
            DataClassification = CustomerContent;
        }
        field(50003; "Giv. Prod. Order No."; Code[20])
        {
            Caption = 'Giv. Prod. Order No.';
            TableRelation = "Giv. Prod. Order";
            DataClassification = CustomerContent;
        }
        field(50004; "Shipment Act No."; code[20])
        {
            TableRelation = "Item Shipment Header";
            caption = 'Shipment Act No.';
            DataClassification = CustomerContent;

        }
    }

    var

        ChangeFromGivProdOrder: Boolean;
        InvtSetup: record "Inventory setup";

    procedure SetChangeFromGivProdOrder(ChangeFromGivProdOrderNew: Boolean)
    begin

        // SWC816 AK 120516 >>
        ChangeFromGivProdOrder := ChangeFromGivProdOrderNew;
        // SWC816 AK 120516 <<
    end;

    local procedure CheckOnGivProdOrder()
    var
        locLabel001: label 'Акт оприходования %1 создан из произв. заказа %2\';
        locLabel002: label 'Вы можете изменить/учесть его только оттуда';
    begin

        // SWC816 AK 120516 >>
        IF ChangeFromGivProdOrder THEN
            EXIT;

        IF "Giv. Prod. Order No." <> '' THEN
            ERROR(locLabel001 +
                  locLabel002, "No.", "Giv. Prod. Order No.");
        // SWC816 AK 120516 <<

    end;

    local procedure UpdateItemDocLines(FieldRef: Integer)
    var
        ItemDocLine: record "Item Document Line";
    begin
        // SWC816 AK 120516 >>
        CheckOnGivProdOrder();
        ItemDocLine.SetChangeFromGivProdOrder(ChangeFromGivProdOrder);

        // SWC816 AK 120516 <<


        ItemDocLine.LOCKTABLE;
        ItemDocLine.SETRANGE("Document Type", "Document Type");
        ItemDocLine.SETRANGE("Document No.", "No.");
        IF ItemDocLine.FINDSET(TRUE, FALSE) THEN BEGIN
            REPEAT
                CASE FieldRef OF
                    // SWC816 AK 200416 >>
                    FIELDNO("Vendor No."):
                        BEGIN
                            InvtSetup.GET;

                            IF InvtSetup."Use Giv. Production Func." THEN BEGIN
                                InvtSetup.TESTFIELD("Giv. Production Loc. Code");
                                InvtSetup.TESTFIELD("Giv. Materials Loc. Code");
                                IF (("Document Type" = "Document Type"::Receipt) AND
                                    (ItemDocLine."Location Code" = InvtSetup."Giv. Production Loc. Code")) OR
                                (("Document Type" = "Document Type"::Shipment) AND
                                    (ItemDocLine."Location Code" = InvtSetup."Giv. Materials Loc. Code")) THEN
                                    ItemDocLine.VALIDATE("Bin Code", "Vendor No.");
                            END;
                        END;

                // SWC816 AK 200416 <<
                END;
                ItemDocLine.MODIFY(TRUE);
            UNTIL ItemDocLine.NEXT = 0;
        END;

    end;
}