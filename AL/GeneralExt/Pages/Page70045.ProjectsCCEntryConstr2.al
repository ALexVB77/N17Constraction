page 70045 "Projects CC Entry Constr 2"
{

    ApplicationArea = Basic, Suite;
    Caption = 'Projects CC Entry Constr 2';
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Projects Cost Control Entry";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = gEditField;
                }
                field("Contragent No."; Rec."Contragent No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = gEditField;
                    trigger OnValidate()
                    begin
                        //SWC149 AKA 010714 >>
                        IF "Contragent Type" = "Contragent Type"::Vendor THEN
                            IF Vendor.GET("Contragent No.") THEN
                                "Contragent Name" := Vendor.Name;
                        IF "Contragent Type" = "Contragent Type"::Customer THEN
                            IF Customer.GET("Contragent No.") THEN
                                "Contragent Name" := Customer.Name;
                        //SWC149 AKA 010714 <<
                    end;
                }
                field("Contragent Name"; Rec."Contragent Name")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = gEditField;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = Basic, Suite;
                    trigger OnValidate()
                    begin
                        VATOnAfterValidate; //navnav;

                    end;
                }
                field("Doc No."; Rec."Doc No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = gEditField;
                    StyleExpr = DocNoStyle;
                    trigger OnLookup(var Text: text): boolean
                    var
                        PurchInvHeader: record "Purch. Inv. Header";
                    begin
                        IF "Doc Type" = 0 THEN BEGIN
                            PurchaseHeader.SETRANGE("No.", "Doc No.");
                            PurchaseHeader.SETRANGE("Act Type", 0); //SWC397 AKA 111214
                            IF PurchaseHeader.FINDFIRST THEN
                                PAGE.RUN(70184, PurchaseHeader)
                            ELSE BEGIN
                                PurchInvHeader.SETRANGE("No.", "Doc No.");
                                IF PurchInvHeader.FINDFIRST THEN
                                    PAGE.RUN(138, PurchInvHeader);
                            END;
                            //SWC397 AKA 111214 >>
                            PurchaseHeader.SETRANGE("No.", "Doc No.");
                            PurchaseHeader.SETFILTER("Act Type", '<>%1', 0);
                            IF PurchaseHeader.FINDFIRST THEN
                                PAGE.RUNMODAL(70260, PurchaseHeader);
                            //SWC397 AKA 111214 <<
                        END;

                        IF "Doc Type" = 1 THEN BEGIN
                            PurchInvHeader.SETRANGE("No.", "Doc No.");
                            IF PurchInvHeader.FINDFIRST THEN
                                PAGE.RUN(138, PurchInvHeader);
                        END;
                    end;
                }
                field("Without VAT"; Rec."Without VAT")
                {
                    ApplicationArea = Basic, Suite;
                    DecimalPlaces = 0 : 0;
                    Editable = gEditField;
                    trigger OnValidate()
                    begin
                        WithoutVATOnAfterValidate; //navnav;

                    end;

                }
                field("Amount Including VAT 2"; Rec."Amount Including VAT 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("VAT Amount 2"; Rec."VAT Amount 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                // field("Cost Type"; Rec."Cost Type")
                // {
                //     ApplicationArea = Basic, Suite;
                // }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = gEditField;
                    trigger OnValidate()
                    begin
                        //SWC149 AKA 010714 >>
                        IF Rec."Contragent Type" = Rec."Contragent Type"::Vendor THEN
                            IF VendorAgreement.GET(Rec."Contragent No.", Rec."Agreement No.") THEN
                                Rec."External Agreement No." := VendorAgreement."External Agreement No.";
                        IF Rec."Contragent Type" = Rec."Contragent Type"::Customer THEN
                            IF CustomerAgreement.GET(Rec."Contragent No.", Rec."Agreement No.") THEN
                                Rec."External Agreement No." := CustomerAgreement."External Agreement No.";
                        //SWC149 AKA 010714 <<
                    end;
                }
                field("External Agreement No."; Rec."External Agreement No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field(ID; Rec.ID)
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                // field("Building Turn"; Rec."Building Turn")
                // {
                //     ApplicationArea = Basic, Suite;
                // }
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                // field("Project Turn Code"; Rec."Project Turn Code")
                // {
                //     ApplicationArea = Basic, Suite;
                // }
                field("Create User"; Rec."Create User")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Create Date"; Rec."Create Date")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Project Storno"; Rec."Project Storno")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Analysis Type"; Rec."Analysis Type")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field(Reserve; Rec.Reserve)
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Company Name"; Rec."Company Name")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Original Date"; Rec."Original Date")
                {
                    Visible = false;
                    Editable = gEditField;
                    ApplicationArea = Basic, Suite;
                }
                field("Original Company"; Rec."Original Company")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Original Ammount"; Rec."Original Ammount")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field(Code; Rec.Code)
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field(Changed; Rec.Changed)
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Line No."; Rec."Estimate Line No.")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Quantity"; Rec."Estimate Quantity")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Unit Price"; Rec."Estimate Unit Price")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Unit of Measure"; Rec."Estimate Unit of Measure")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Line ID"; Rec."Estimate Line ID")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Subproject Code"; Rec."Estimate Subproject Code")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Reverse)
            {
                Caption = 'Reverse';
                trigger OnAction()
                var
                    PCCE: record "Projects Cost Control Entry";
                    PCCE2: record "Projects Cost Control Entry";
                    Wnd: dialog;
                    EnterDate: date;
                begin
                    // SWC983 DD 19.01.17 >>
                    //IF NOT CONFIRM('Сторнировать выделенные строки?') THEN
                    //  EXIT;
                    CurrPage.SETSELECTIONFILTER(PCCE);
                    PCCE.FINDSET;
                    EnterDate := PCCE.Date;
                    // Wnd.OPEN('Введите Дату Учета (Enter): #1#######');
                    // Wnd.INPUT(1,EnterDate);
                    IF EnterDate = 0D THEN
                        EXIT;
                    PCCE.SETRANGE("Project Storno", FALSE);
                    IF PCCE.FINDSET THEN
                        REPEAT
                            PCCE."Project Storno" := TRUE;
                            PCCE.Changed := TRUE;
                            PCCE.MODIFY;
                            PCCE2 := PCCE;
                            PCCE2."Entry No." := PCCE2.GetNextEntryNo;
                            PCCE2."Create User" := USERID;
                            PCCE2."Create Date" := TODAY;
                            PCCE2."Create Time" := TIME;
                            PCCE2."Without VAT" := -PCCE2."Without VAT";
                            //   PCCE2.VAT := -PCCE2.VAT;
                            PCCE2.Amount := -PCCE2.Amount;
                            PCCE2."Amount (LCY)" := -PCCE2."Amount (LCY)";
                            //   PCCE2."Temp Amount" := -PCCE2."Temp Amount";
                            PCCE2."Original Ammount" := -PCCE2."Original Ammount";
                            PCCE2.Date := EnterDate;
                            PCCE2.Changed := FALSE;
                            //NC-47122 DP >>
                            PCCE2."Amount 2" := -PCCE2."Amount 2";
                            PCCE2."Amount Including VAT 2" := -PCCE2."Amount Including VAT 2";
                            PCCE2."VAT Amount 2" := -PCCE2."VAT Amount 2";
                            //NC-47122 DP <<
                            PCCE2.INSERT;
                        UNTIL PCCE.NEXT = 0;
                    CurrPage.UPDATE(FALSE);
                    // SWC983 DD 19.01.17 <<
                end;
            }
            action(ManualInput)
            {
                Caption = 'Manual Input';
                trigger OnAction()
                var
                    lrProjectsCostControlEntry: record "Projects Cost Control Entry";
                begin
                    //FILTERGROUP:=2;
                    lrProjectsCostControlEntry.RESET;
                    lrProjectsCostControlEntry.INIT;
                    lrProjectsCostControlEntry.COPY(Rec);
                    lrProjectsCostControlEntry."Entry No." := 0;
                    lrProjectsCostControlEntry."Description 2" := '';
                    lrProjectsCostControlEntry.Amount := 0;
                    lrProjectsCostControlEntry.Date := 0D;
                    lrProjectsCostControlEntry."Original Date" := 0D;
                    lrProjectsCostControlEntry."Without VAT" := 0;
                    lrProjectsCostControlEntry."Cost Type" := '';
                    lrProjectsCostControlEntry."Contragent No." := '';
                    lrProjectsCostControlEntry."Agreement No." := '';
                    lrProjectsCostControlEntry.ID := 0;
                    // lrProjectsCostControlEntry."IFRS Account No." := '';
                    lrProjectsCostControlEntry."Original Ammount" := 0;
                    lrProjectsCostControlEntry."Project Code" := GETFILTER("Project Code");
                    EVALUATE(lrProjectsCostControlEntry."Line No.", GETFILTER("Line No."));
                    // grPrjStrLine.SETFILTER("Project Code", GETFILTER("Project Code"));
                    // grPrjStrLine.SETFILTER("Line No.", GETFILTER("Line No."));
                    // IF grPrjStrLine.FINDFIRST THEN BEGIN

                    //     lrProjectsCostControlEntry.Description := grPrjStrLine.Description;
                    //     lrProjectsCostControlEntry.Code := grPrjStrLine.Code;
                    lrProjectsCostControlEntry."Analysis Type" := "Analysis Type"::Actuals;
                    // END;
                    //FILTERGROUP:=0;
                    lrProjectsCostControlEntry."Doc No." := 'MANUAL';
                    lrProjectsCostControlEntry."User Created" := TRUE;
                    lrProjectsCostControlEntry."Create User" := USERID;
                    lrProjectsCostControlEntry."Create Date" := TODAY;
                    lrProjectsCostControlEntry."Create Time" := TIME;
                    lrProjectsCostControlEntry.INSERT(TRUE);
                    CurrPage.UPDATE;
                end;


            }
            action(ChangeRec)
            {
                Caption = 'Change';
                trigger OnAction()
                begin
                    grPCCE.DELETEALL;
                    grPCCE.TRANSFERFIELDS(Rec);
                    grPCCE."Building Turn" := "Project Turn Code";
                    grPCCE."Cost Code" := Code;
                    grPCCE."New Lines" := "Line No.";
                    grPCCE.INSERT;
                    PAGE.RUN(70217, grPCCE);
                end;


            }
            action(ChangeLog)
            {
                Caption = 'Change Log';
                trigger OnAction()
                var
                    CLE: record "Change Log Entry";
                begin
                    // CLE.SETCURRENTKEY("Table No.","Primary Key Field 5 Value");
                    CLE.SETRANGE("Table No.", Database::"Projects Cost Control Entry");
                    CLE.SETRANGE("Primary Key Field 1 Value", "Project Code");
                    // CLE.SETRANGE("Primary Key Field 5 Value",FORMAT("Entry No."));
                    IF CLE.FINDFIRST THEN
                        PAGE.RUNMODAL(0, CLE);
                end;


            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        CLE: record "Change Log Entry";
    begin
        SetEditable("User Created");

        // CLE.SETCURRENTKEY("Table No.", "Primary Key Field 5 Value");
        CLE.SETRANGE("Table No.", 70095);
        CLE.SETRANGE("Primary Key Field 1 Value", Rec."Project Code");
        // CLE.SETRANGE("Primary Key Field 5 Value", FORMAT("Entry No."));
        IF CLE.FINDFIRST THEN Rec.Changed := TRUE ELSE Rec.Changed := FALSE;
    end;

    trigger OnNewRecord(BelowxRec: boolean)
    begin
        //FILTERGROUP:=2;
        // grPrjStrLine.SETFILTER("Project Code", GETFILTER("Project Code"));
        // grPrjStrLine.SETFILTER("Line No.", GETFILTER("Line No."));
        // IF grPrjStrLine.FINDFIRST THEN BEGIN

        //     Description := grPrjStrLine.Description;
        if Rec.GetFilter(Code) <> '' then
            Rec.Code := Rec.GetFilter(Code);
        if Rec.GetFilter("Project Code") <> '' then
            Rec."Project Code" := Rec.GetFilter("Project Code");
        Rec."Analysis Type" := Rec."Analysis Type"::Actuals;
        // END;
        //FILTERGROUP:=0;
        Rec."User Created" := TRUE;
        Rec."Create User" := USERID;
        Rec."Create Date" := TODAY;
        Rec."Create Time" := TIME;
    end;

    trigger OnDeleteRecord(): boolean
    begin
        IF Rec."Without VAT" <> 0 THEN BEGIN
            MESSAGE(TEXT002);
            EXIT(FALSE);
        END;
    end;

    trigger OnOpenPage()
    begin
        // ICCOnFormat; //navnav;

        DocNoOnFormat; //navnav;

        // DescriptionOnFormat; //navnav;

        // CurrPage.bt.VISIBLE := FALSE;
        // // SWC983 DD 19.01.17 >>
        // CurrPage.btS.VISIBLE := US.GET(USERID) AND US."Administrator PRJ";
        // SWC983 DD 19.01.17 <<
        // IF STRLEN(GETFILTER("Line No.")) > 10 THEN
        //     CurrPage.EDITABLE := FALSE ELSE BEGIN
        //     IF STRLEN(GETFILTER("Project Turn Code")) = 0 THEN
        //         CurrPage.EDITABLE := FALSE ELSE BEGIN
        //         IF US.GET(USERID) THEN BEGIN
        //             IF US."Administrator PRJ" THEN BEGIN
        //                 CurrPage.bt.VISIBLE := TRUE;
        //                 CurrPage.EDITABLE := TRUE;
        //             END;
        //         END;
        //     END;
        // END;

        //SWC760 AKA 251215 >>
        /*IF ShowReversed THEN
          SETRANGE(Reversed)
        ELSE
          SETRANGE(Reversed,FALSE);*/
        //SWC760 AKA 251215 <<

        // IF US.GET(USERID) THEN BEGIN
        //     IF US."Administrator PRJ" THEN CurrPage.bCh.VISIBLE := TRUE ELSE CurrPage.bCh.VISIBLE := FALSE;
        // END;

        // IF GETFILTER("Analysis Type") = 'Adv' THEN BEGIN
        //     CurrPage.bt.VISIBLE := FALSE;
        //     CurrPage.bCh.VISIBLE := FALSE;
        // END;

        //SWC433 AKA 270215 >>
        // IF BuildProject.GET("Project Code") THEN;
        // BuildProject.CALCFIELDS("Building turn");
        // IF BuildProject."Building turn" IN [0, 1] THEN BEGIN
        //     IF US."Administrator PRJ" THEN BEGIN
        //         CurrPage.bt.VISIBLE := TRUE;
        //         CurrPage.EDITABLE := TRUE;
        //     END;
        // END;
        // //SWC433 AKA 270215 <<
        // //SWC437 SM 020315 >>
        // IF "Analysis Type" = "Analysis Type"::Estimate THEN BEGIN
        //     CurrPage.EDITABLE(FALSE);
        //     CurrPage.bCh.ENABLED(FALSE);
        //     CurrPage.bt.ENABLED(FALSE);
        // END;

        // SWC DD 12.05.17 >>
        Rec.SETRANGE("Project Storno", FALSE);
        // SWC DD 12.05.17 <<
    end;

    var
        US: record "User Setup";
        grPCCE: Record "Projects Cost Control Entry" temporary;
        Vendor: record Vendor;
        Customer: record Customer;
        VendorAgreement: record "Vendor Agreement";
        CustomerAgreement: record "Customer Agreement";
        PurchaseHeader: record "Purchase Header";
        gEditField: boolean;
        DocNoStyle: text;
        TEXT001: Label 'Operations cannot be changed!';
        TEXT002: Label 'Operations cannot be deleted!';
        Text003: Label 'Attention! VAT rate = 0. To recalculate, enter the correct rate and then the new Amount without VAT.';

    procedure SetEditable(pEditable: boolean)
    begin
        gEditField := pEditable;
    end;

    local procedure VATOnAfterValidate()
    begin
        //NC 28312 HR beg
        Rec."Amount 2" := Rec."Without VAT";
        IF Rec.IsProductionProject THEN BEGIN
            Rec."Amount Including VAT 2" := ROUND(Rec."Without VAT" * (100 + Rec."VAT %") / 100, 0.01);
            Rec."VAT Amount 2" := Rec."Amount Including VAT 2" - Rec."Amount 2";
        END;
        //NC 28312 HR end
    end;

    local procedure WithoutVATOnAfterValidate()
    begin
        //NC 28312 HR beg
        //IF "Entry No." <> 0 THEN BEGIN
        //  IF xRec."Without VAT" <> 0 THEN BEGIN
        //    MESSAGE(TEXT001);
        //    "Without VAT":=xRec."Without VAT";
        //  END;
        //END;

        Rec."Amount 2" := Rec."Without VAT";
        IF Rec.IsProductionProject THEN BEGIN
            IF Rec."VAT %" <= 0 THEN
                MESSAGE(Text003)
            ELSE BEGIN
                Rec."Amount Including VAT 2" := ROUND(Rec."Without VAT" * (100 + Rec."VAT %") / 100, 0.01);
                Rec."VAT Amount 2" := Rec."Amount Including VAT 2" - Rec."Amount 2";
            END
        END;
        //NC 28312 HR end
    end;

    procedure ExistDoc() Ret: boolean
    var
        PurchInvHeader: record "Purch. Inv. Header";
    begin
        IF Rec."Doc Type" = 0 THEN BEGIN
            PurchaseHeader.SETRANGE("No.", Rec."Doc No.");
            IF PurchaseHeader.FINDFIRST THEN
                EXIT(TRUE)
            ELSE BEGIN
                PurchInvHeader.SETRANGE("No.", Rec."Doc No.");
                IF PurchInvHeader.FINDFIRST THEN
                    EXIT(TRUE);


            END;
        END;

        IF Rec."Doc Type" = 1 THEN BEGIN
            PurchInvHeader.SETRANGE("No.", Rec."Doc No.");
            IF PurchInvHeader.FINDFIRST THEN
                EXIT(TRUE);


        END;
    end;

    local procedure DocNoOnFormat()
    begin
        IF NOT ExistDoc THEN DocNoStyle := 'Attention' else DocNoStyle := '';
    end;
}
