table 70201 "Vendor Excel Header"
{
    Caption = 'Vendor Invoice Header';
    //LookupPageID = Page50082;
    //DrillDownPageID = Page50082;

    fields
    {
        field(1; "No."; Code[50])
        {
            Caption = 'No.';
        }
        field(2; Date; Text[50])
        {
            Caption = 'Date';
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(4; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
            Caption = 'Vendor No.';
        }
        field(5; "Vend VAT Reg No."; Code[20])
        {
            Caption = 'Vend VAT Reg No.';
        }
        field(6; "Agreement No."; Code[20])
        {
            TableRelation = "Vendor Agreement"."No." WHERE("Vendor No." = FIELD("Vendor No."), Active = CONST(true));
            Caption = 'Agreement No.';
        }
        field(7; "Act Type"; enum "Purchase Act Type")
        {
            Caption = 'Act Type';
        }
        field(8; "Act No."; Code[20])
        {
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order), "Act Type" = filter(Act | "KC-2" | Advance));
            Editable = false;
            Caption = 'Act No.';
        }
    }

    keys
    {
        key(Key1; "No.", "Vendor No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        VELine: record "Vendor Excel Line";
    begin
        VELine.RESET;
        VELine.SETRANGE("Document No.", "No.");
        VELine.SETRANGE("Vendor No.", "Vendor No.");
        VELine.DELETEALL;
    end;

    var
        Text001: Label 'Purchase Invoice %1 created';
        Text002: Label 'The act has already been created!';


    procedure CreatePurchInvoice()
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchHead: record "Purchase Header";
        PurchLine: record "Purchase Line";
        SourceLine: record "Vendor Excel Line";
        StorekeeperLocation: record "Warehouse Employee";
        VendorAgreement: record "Vendor Agreement";
        DimSetEntry: Record "Dimension Set Entry";
        DimMgtExt: Codeunit "Dimension Management (Ext)";
        LineNo: integer;
        grUS: record "User Setup";
    begin
        IF "Act No." <> '' THEN BEGIN
            MESSAGE(Text002);
            EXIT;
        END;

        TESTFIELD("Vendor No.");
        TESTFIELD("Posting Date");
        TESTFIELD("Agreement No.");
        TESTFIELD("Act Type");

        grUS.Get(UserId);
        PurchSetup.Get();

        PurchHead.INIT;
        PurchHead."Document Type" := PurchHead."Document Type"::Order;
        PurchHead."No." := '';
        PurchHead."Pre-booking Document" := TRUE;
        PurchHead."Act Type" := "Act Type";
        PurchHead.INSERT(TRUE);

        PurchHead.VALIDATE("Buy-from Vendor No.", "Vendor No.");
        PurchHead.VALIDATE("Document Date", "Posting Date");

        // PurchHeaderAdd.AddStorekeeper(PurchHead."Document Type", PurchHead."No.");
        if PurchHead."Location Document" then
            PurchHead.VALIDATE("Location Code", StorekeeperLocation.GetDefaultLocation('', false));

        PurchHead."Status App Act" := PurchHead."Status App Act"::Controller;
        PurchHead."Process User" := USERID;
        PurchHead."Payment Doc Type" := PurchHead."Payment Doc Type"::"Payment Request";
        PurchHead."Date Status App" := TODAY;
        PurchHead.Controller := grUS."User ID";
        IF PurchHead."Act Type" = PurchHead."Act Type"::"KC-2" THEN
            if PurchSetup."Default Estimator" <> '' then
                PurchHead.Estimator := PurchSetup."Default Estimator";
        IF "Agreement No." <> '' THEN
            PurchHead.VALIDATE("Agreement No.", "Agreement No.");
        IF VendorAgreement.GET(PurchHead."Buy-from Vendor No.", PurchHead."Agreement No.") THEN
            PurchHead."Purchaser Code" := VendorAgreement."Purchaser Code";
        PurchHead."Vendor Invoice No." := "No.";
        PurchHead.MODIFY(TRUE);

        LineNo := 10000;
        SourceLine.SETRANGE("Document No.", "No.");
        SourceLine.SETFILTER("Item No.", '<>%1', '');
        SourceLine.SETRANGE("Vendor No.", "Vendor No.");
        IF SourceLine.FINDSET THEN
            REPEAT
                PurchLine.INIT;
                PurchLine."Document Type" := PurchHead."Document Type";
                PurchLine."Document No." := PurchHead."No.";
                PurchLine."Line No." := LineNo;
                LineNo := LineNo + 10000;
                PurchLine.INSERT(TRUE);
                PurchLine.Type := PurchLine.Type::Item;
                PurchLine.VALIDATE("No.", SourceLine."Item No.");
                PurchLine.VALIDATE(Quantity, SourceLine.Quantity);
                PurchLine.VALIDATE("Unit of Measure Code", SourceLine."Unit of Measure");
                PurchLine.VALIDATE("Direct Unit Cost", SourceLine."Unit Price");
                // NC AB >>              
                // PurchLine.VALIDATE("Shortcut Dimension 1 Code", SourceLine."Shortcut Dimension 1 Code");
                // PurchLine.VALIDATE("Shortcut Dimension 2 Code", SourceLine."Shortcut Dimension 2 Code");
                DimSetEntry.SetRange("Dimension Set ID", SourceLine."Dimension Set ID");
                if DimSetEntry.FindSet() then
                    repeat
                        DimMgtExt.valDimValueWithUpdGlobalDim(
                            DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code", PurchLine."Dimension Set ID",
                            PurchLine."Shortcut Dimension 1 Code", PurchLine."Shortcut Dimension 2 Code");
                    until DimSetEntry.Next() = 0;
                // NC AB <<
                PurchLine.MODIFY(TRUE);
            UNTIL SourceLine.NEXT = 0;

        "Act No." := PurchHead."No.";
        MODIFY;
        COMMIT;
        PAGE.RUNMODAL(PAGE::"Purchase Order Act", PurchHead);
    end;
}


