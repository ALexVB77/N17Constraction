tableextension 92454 "Item Shipment Header GE" extends "Item Shipment Header"
{
    fields
    {
        field(50000; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = vendor;
        }
        field(50001; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Agreement"."No." WHERE("Vendor No." = FIELD("Vendor No."));
        }
        field(50002; "Giv. Prod. Order No."; Code[20])
        {
            Caption = 'Giv. Prod. Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Giv. Prod. Order";
        }
    }
    var

        PostedDocDim: Record "Dimension Set Entry";
        DimMgt: Codeunit "DimensionManagement";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        InvtSetup: Record "Inventory Setup";

    procedure CreateGivProdOrder()
    var

        GivProdOrder: Record "Giv. Prod. Order";
        GivProdOrderShpmt: Record "Giv. Prod. Order Shipment";
        GivProdOrderRcpt: Record "Giv. Prod. Order Receipt";
        RcptActNo: Code[20];
        locLabel001: label 'Выпуск ГП по отгрузке %1';
    begin
        // SWC816 AK 200416 >>
        InvtSetup.GET;
        IF NOT InvtSetup."Use Giv. Production Func." THEN
            EXIT;

        InvtSetup.TESTFIELD("Giv. Materials Loc. Code");

        TESTFIELD("Location Code", InvtSetup."Giv. Materials Loc. Code");
        TESTFIELD("Vendor No.");
        TESTFIELD("Agreement No.");

        GivProdOrderShpmt.RESET;
        GivProdOrderShpmt.SETCURRENTKEY("Document No.");
        GivProdOrderShpmt.SETRANGE("Document No.", "No.");
        IF GivProdOrderShpmt.FINDLAST THEN BEGIN
            GivProdOrder.GET(GivProdOrderShpmt."Order No.");
            GivProdOrder.FILTERGROUP(2);
            GivProdOrder.SETRECFILTER;
            GivProdOrder.FILTERGROUP(0);
            page.RUNMODAL(page::"Giv. Prod. Order", GivProdOrder);
            EXIT;
        END;

        GivProdOrder.INIT;
        GivProdOrder."Document Date" := WORKDATE;
        GivProdOrder.INSERT(TRUE);
        GivProdOrder.VALIDATE(Description, STRSUBSTNO(locLabel001, "No."));
        GivProdOrder.MODIFY(TRUE);

        GivProdOrderShpmt.RESET;
        GivProdOrderShpmt.INIT;
        GivProdOrderShpmt."Order No." := GivProdOrder."No.";
        GivProdOrderShpmt."Line No." := 10000;
        GivProdOrderShpmt.INSERT(TRUE);
        GivProdOrderShpmt.VALIDATE("Document No.", "No.");
        GivProdOrderShpmt.MODIFY(TRUE);

        RcptActNo := Rec.CreateRcptAct(GivProdOrder."No.");

        GivProdOrderRcpt.INIT;
        GivProdOrderRcpt."Order No." := GivProdOrder."No.";
        GivProdOrderRcpt."Line No." := 10000;
        GivProdOrderRcpt.INSERT(TRUE);
        GivProdOrderRcpt.VALIDATE("Document No.", RcptActNo);
        GivProdOrderRcpt.MODIFY(TRUE);

        GivProdOrder.FILTERGROUP(2);
        GivProdOrder.SETRECFILTER;
        GivProdOrder.FILTERGROUP(0);

        COMMIT;
        page.RUNMODAL(page::"Giv. Prod. Order", GivProdOrder);
        // SWC816 AK 200416 <<

    end;

    procedure CreateRcptAct(ProdOrderNo: Code[20]): code[20]
    var

        ItemDocHdr: Record "Item Document Header";
        PostedDocDim: Record "Dimension Set Entry";
        DocDim: Record "dimension set entry";
        GLSetup: Record "General Ledger Setup";
        locLabel001: label 'Выпуск ГП по отгрузке %1';
        ish: Record "Item Shipment Header";
        dimMgt : codeunit "Dimension Management (Ext)";

    begin

        // SWC816 AK 120516 >>
        InvtSetup.GET;
        IF NOT InvtSetup."Use Giv. Production Func." THEN
            EXIT;

        InvtSetup.TESTFIELD("Giv. Production Loc. Code");
        InvtSetup.TESTFIELD("Manuf. Gen. Bus. Posting Gr.");

        ItemDocHdr.INIT;
        ItemDocHdr.SetChangeFromGivProdOrder(TRUE);
        ItemDocHdr."Document Type" := ItemDocHdr."Document Type"::Receipt;
        ItemDocHdr."No." := '';
        ItemDocHdr.INSERT(TRUE);
        ItemDocHdr.VALIDATE("Posting Description", STRSUBSTNO(locLabel001, "No."));
        ItemDocHdr.VALIDATE("Posting Date", "Posting Date");
        ItemDocHdr.VALIDATE("Location Code", InvtSetup."Giv. Production Loc. Code");
        ItemDocHdr.VALIDATE("Gen. Bus. Posting Group", InvtSetup."Manuf. Gen. Bus. Posting Gr.");
        ItemDocHdr.VALIDATE("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
        ItemDocHdr.VALIDATE("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
        ItemDocHdr.VALIDATE("Vendor No.", "Vendor No.");
        ItemDocHdr.VALIDATE("Agreement No.", "Agreement No.");
        ItemDocHdr.VALIDATE("Giv. Prod. Order No.", ProdOrderNo);
        ItemDocHdr.VALIDATE("Shipment Act No.", "No.");
        ItemDocHdr.MODIFY(TRUE);

        GLSetup.GET;

        //IF PostedDocDim.GET(DATABASE::"Item Shipment Header",
        //     "No.", 0, GLSetup."Cost Type Dimension Code") THEN
        if ish.get("No.") and PostedDocDim.get(ish."Dimension Set ID", GLSetup."Cost Type Dimension Code") then
            //IF NOT DocDim.GET(DATABASE::"Item Document Header",
            //         DocDim."Document Type"::"Item Receipt",
            //         ItemDocHdr."No.", 0, PostedDocDim."Dimension Code") THEN BEGIN
            if not docdim.get(ItemDocHdr."Dimension Set ID", PostedDocDim."Dimension Code") then begin
                dimMgt.valDimValue(PostedDocDim."Dimension Code",PostedDocDim."Dimension Value Code",ItemDocHdr."Dimension Set ID");
                ItemDocHdr.modify();

                /*
                DocDim.INIT;
                DocDim."Table ID" := DATABASE::"Item Document Header";
                DocDim."Document Type" := DocDim."Document Type"::"Item Receipt";
                DocDim."Document No." := ItemDocHdr."No.";
                DocDim."Line No." := 0;
                DocDim."Dimension Code" := PostedDocDim."Dimension Code";
                DocDim."Dimension Value Code" := PostedDocDim."Dimension Value Code";
                DocDim.INSERT(TRUE);
                */
            END;

        EXIT(ItemDocHdr."No.");
        // SWC816 AK 120516 <<

    end;
}
