report 70055 "Get Lines for Budget Constr"
{
    Permissions = TableData 17 = rm;
    ProcessingOnly = true;
    Caption = 'Get Lines';


    dataset
    {

    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field(StartDate; StartDate)
                {
                    Caption = 'Start Date';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        IF (EndDate <> 0D) AND (StartDate > EndDate) THEN BEGIN
                            MESSAGE(Text001);
                            StartDate := 0D;
                        END;
                    end;
                }
                field(EndDate; EndDate)
                {
                    Caption = 'End Date';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        IF (EndDate <> 0D) AND (StartDate > EndDate) THEN BEGIN
                            MESSAGE(Text001);
                            EndDate := 0D;
                        END;
                    end;
                }
            }
        }
    }

    trigger OnPreReport()
    var
        vDate1: date;
        vDate2: date;
        StartDate1: date;
        EndDate1: date;
        DateCount: integer;
        // ProjectPerionClose: record "Project Perion Close";
        // Dim: record Dim;
        Agr: record "Vendor Agreement";
        VATCoef: decimal;
        ExistFirst: boolean;
        PreBooking: boolean;
    begin
        IF StartDate = 0D THEN ERROR(Text002);
        IF EndDate = 0D THEN ERROR(Text003);



        BC.RESET;
        BC.FILTERGROUP(2);
        BC.SETRANGE(Status, BC.Status::Active);
        BC.SETFILTER("Project Code", '%1|%2', gPrjCode, '');
        BC.FILTERGROUP(0);
        IF BC.FINDFIRST THEN;

        CLEAR(BudgetForm);
        BudgetForm.SETTABLEVIEW(BC);
        BudgetForm.SETRECORD(BC);
        BudgetForm.EDITABLE := FALSE;
        BudgetForm.LOOKUPMODE(TRUE);

        IF BudgetForm.RUNMODAL = ACTION::LookupOK THEN BEGIN
            BudgetForm.GETRECORD(BC);
            gCode := BC.Code;
            BudgetForm.GetRec(BC);
            BC.MARKEDONLY(TRUE);
            IF NOT BC.FINDFIRST THEN BEGIN
                BC.MARKEDONLY(FALSE);
                BC.SETRANGE(Code, gCode);
            END;

            IF NOT BC.FINDFIRST THEN
                ERROR(Text004);
            IF BC.FIND('-') THEN BEGIN
                gID := 1;
                //   BCJ.RESET;
                //   IF BCJ.FINDLAST THEN
                //    gID:=BCJ.ID+1;


                GLE.RESET;
                w := 0;
                Window.OPEN(Text005);

                REPEAT

                    Window.UPDATE(1, BC.Code);

                    vDate1 := 0D;
                    vDate2 := 0D;

                    GLE.RESET;
                    IF BC."Company Name" <> '' THEN BEGIN
                        GLE.CHANGECOMPANY(BC."Company Name");
                    END ELSE BEGIN
                        GLE.CHANGECOMPANY(COMPANYNAME);
                    END;

                    GLE.SETCURRENTKEY(ID);
                    IF GLE.FINDLAST THEN
                        gID := GLE.ID + 1;

                    GLE.RESET;

                    IF BC."Company Name" <> '' THEN BEGIN
                        GLE.CHANGECOMPANY(BC."Company Name");
                    END ELSE BEGIN
                        GLE.CHANGECOMPANY(COMPANYNAME);
                    END;

                    GLE.SETCURRENTKEY("G/L Account No.", "Posting Date", "Journal Batch Name",
                      "Global Dimension 1 Code", "Global Dimension 2 Code", "Source Code", ID);
                    GLE.SETRANGE("Posting Date", StartDate, EndDate);
                    IF BC."Dimension Totaling 1" <> '' THEN
                        GLE.SETFILTER("Global Dimension 1 Code", CreateCPFilter(BC."Dimension Totaling 1"));
                    IF BC."Dimension Totaling 2" <> '' THEN
                        GLE.SETFILTER("Global Dimension 2 Code", BC."Dimension Totaling 2");
                    IF BC."G/L Account Totaling" <> '' THEN
                        GLE.SETFILTER("G/L Account No.", BC."G/L Account Totaling" + BC."G/L Account Totaling 1" +
                          BC."G/L Account Totaling 2" + BC."G/L Account Totaling 3");
                    IF BC."Journal Batch Name" <> '' THEN
                        GLE.SETFILTER("Journal Batch Name", BC."Journal Batch Name");
                    IF BC."Source Code" <> '' THEN
                        GLE.SETFILTER("Source Code", BC."Source Code");


                    GLE.SETRANGE(ID, 0);

                    w := 0;

                    IF GLE.FINDSET THEN BEGIN
                        REPEAT
                            IF GLE."Document No." = 'PIB016899' THEN
                                MESSAGE('МЕЛИКОНПОЛАР КОР.СС');
                            w += 1;
                            Window.UPDATE(2, ROUND(w / GLE.COUNT * 10000, 1));

                            IF GLE.Amount <> 0 THEN BEGIN
                                IF NOT IsrecognitionOfExpenses(GLE."G/L Account No.", GLE."Entry No.", BC."Company Name") THEN BEGIN

                                    //NC 22512 > DP
                                    //IF NOT IsPreBooking(GLE."Document No.") THEN BEGIN
                                    // TO DO CHECK
                                    PreBooking := IsPreBooking(GLE."Document No.");
                                    //NC 32716 HR beg
                                    //IF (NOT PreBooking) OR (PreBooking AND IsLocationDocument(GLE."Document No.")) THEN BEGIN
                                    IF (NOT PreBooking)
                                      //OR (PreBooking AND IsLocationDocument(GLE."Document No."))
                                      OR (NOT GLE."System-Created Entry")
                                    THEN BEGIN
                                        //NC 32716 HR end
                                        //NC 22512 < DP

                                        BCJ.INIT;
                                        BCJ.RecognitionOfExpenses := IsrecognitionOfExpenses(GLE."G/L Account No.", GLE."Entry No.", BC."Company Name");
                                        BCJ.ID := gID;
                                        BCJ.Code := BC.Code;
                                        BCJ."Project Code" := gPrjCode;
                                        BCJ.Name := BC.Name;
                                        BCJ."Entry No" := GLE."Entry No.";
                                        //
                                        // IF NOT BC."Agreement From Current Company" THEN
                                        BCJ."Agreement No." := GLE."Agreement No.";
                                        // ELSE
                                        //   BCJ."Agreement No.":=GetAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");

                                        // IF NOT BC."Agreement From Current Company" THEN BEGIN
                                        //    BCJ."Vendor Name":=GetVendorNameAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                        //    BCJ."Vendor No.":=GetVendorAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                        //    BCJ."External Agreement No.":=GetExtAgreement(GLE."Document No.",GLE.Amount,BC."Agreement Company Name");
                                        // END ELSE BEGIN
                                        BCJ."Vendor Name" := GetVendorNameAgreement(GLE."Document No.", GLE.Amount, BC."Company Name");
                                        BCJ."Vendor No." := GetVendorAgreement(GLE."Document No.", GLE.Amount, BC."Company Name");
                                        BCJ."External Agreement No." := GetExtAgreement(GLE."Document No.", GLE.Amount, BC."Company Name");
                                        // END;


                                        BCJ."Doc No" := GLE."Document No.";
                                        BCJ.Description := BC.Description;
                                        IF BC.Description = '' THEN
                                            BCJ.Description := GLE.Description;
                                        BCJ."Dimension Totaling 1" := GLE."Global Dimension 1 Code";//DV.Code;
                                        BCJ."Dimension Totaling 2" := GLE."Global Dimension 2 Code";//DV1.Code;
                                                                                                    // Dim.SETRANGE("Old Dim Code",GLE."Global Dimension 2 Code");
                                                                                                    // CHECK таблица пустая, не используется
                                                                                                    // IF Dim.FINDFIRST THEN
                                                                                                    //     BCJ."Dimension Totaling 2" := Dim."New Dim Code";

                                        // GLE.CALCFIELDS("Cost Type");
                                        // BCJ."Cost Type":=GLE."Cost Type";
                                        BCJ."G/L Account Totaling" := GLE."G/L Account No.";//BC."G/L Account Totaling";

                                        BCJ."Priod Group Type" := BC."Period Group Type";
                                        BCJ."Journal Template Name" := BC."Journal Template Name";
                                        BCJ."Journal Batch Name" := GLE."Journal Batch Name";//BC."Journal Batch Name";
                                        BCJ."Source Code" := GLE."Source Code";
                                        BCJ."Company Name" := BC."Company Name";
                                        // BCJ.Advances:=BC.Advances;
                                        // IF BCJ."Agreement No."='' THEN
                                        //   BCJ."Agreement No.":=BC."Virtual Agreement";
                                        Agr.SETRANGE("No.", BCJ."Agreement No.");
                                        IF Agr.FINDFIRST THEN
                                            BCJ."Vendor No." := Agr."Vendor No.";
                                        BCJ."Original Date" := GLE."Posting Date";
                                        // CHECK использование периода проектов под вопросом
                                        // IF IsPeriodClose(BCJ."Project Code",BCJ."Original Date") THEN BEGIN
                                        //   ProjectPerionClose.SETRANGE("Project code",BCJ."Project Code");
                                        //   ProjectPerionClose.SETRANGE(Close,FALSE);
                                        //   IF ProjectPerionClose.FINDFIRST THEN
                                        //     BCJ.Date:=ProjectPerionClose."Period Date";
                                        // END ELSE
                                        BCJ.Date := GLE."Posting Date";

                                        //NC 28312 HR beg
                                        // VATCoef:=1;
                                        // IF BC."Without VAT" THEN VATCoef:=1.18;

                                        // IF NOT BC."Correction Batch" THEN
                                        //   BCJ.Amount:=ABS(ROUND(GLE.Amount/VATCoef,0.01))
                                        // ELSE
                                        //   BCJ.Amount:=ROUND(GLE.Amount/VATCoef,0.01);
                                        VATAmount := 0;
                                        // IF BC."Without VAT" THEN
                                        //   VATAmount := GLE."VAT Amount";
                                        BCJ.Amount := GLE.Amount + VATAmount;
                                        IF BC."Correction Batch" THEN
                                            VATCoef := 1
                                        ELSE BEGIN
                                            BCJ.Amount := ABS(BCJ.Amount);
                                            VATCoef := -1;
                                        END;

                                        BCJ."Amount 2" := VATCoef * GLE.Amount;
                                        BCJ."Amount Including VAT 2" := VATCoef * (GLE.Amount + GLE."VAT Amount");
                                        BCJ."VAT Amount 2" := VATCoef * GLE."VAT Amount";
                                        //NC 28312 HR end

                                        BCJ."Original Amount" := GLE.Amount;
                                        BCJ.Reversed := GLE.Reversed;

                                        IF BC."Company Name" <> '' THEN
                                            GLE2.CHANGECOMPANY(BC."Company Name")
                                        ELSE
                                            GLE2.CHANGECOMPANY(COMPANYNAME);

                                        ExistFirst := FALSE;
                                        IF BCJ.Reversed THEN BEGIN
                                            IF GLE."Reversed by Entry No." <> 0 THEN
                                                GLE2.GET(GLE."Reversed by Entry No.");
                                            IF GLE."Reversed Entry No." <> 0 THEN
                                                GLE2.GET(GLE."Reversed Entry No.");

                                            BCJ."Reversed ID" := GLE2.ID;

                                        END;
                                        //SWC855 KAE 080716 >>
                                        //BCJ.INSERT;
                                        BCJ.INSERT(TRUE);
                                        //SWC855 KAE 080716 <<

                                        IF BC."Company Name" <> '' THEN
                                            GLE1.CHANGECOMPANY(BC."Company Name")
                                        ELSE
                                            GLE1.CHANGECOMPANY(COMPANYNAME);

                                        IF GLE1.GET(GLE."Entry No.") THEN BEGIN
                                            GLE1.ID := gID;
                                            GLE1.MODIFY;
                                        END;

                                        gID += 1;
                                    END;
                                END;
                            END;
                        UNTIL GLE.NEXT = 0;

                    END;
                UNTIL BC.NEXT = 0;

                Window.CLOSE;
            END;
            COMMIT;
            Synch;
            BCJ.RESET;
            BCJ.SETRANGE(Reversed, TRUE);
            BCJ.SETRANGE("Reversed ID", 0);
            IF BCJ.FINDFIRST THEN BCJ.DELETEALL(TRUE);
        END;
    end;



    var
        StartDate: date;
        EndDate: date;
        BC: record "Budget Correction";
        GLE: record "G/L Entry";
        GLETemp: record "G/L Entry" temporary;
        BudgetForm: page "Budget Corrections";
        gCode: code[20];
        BCJ: record "Budget Correction Journal";
        gID: integer;
        tDate: record Date;
        w: integer;
        Window: dialog;
        DV: record "Dimension Value";
        DV1: record "Dimension Value";
        DV2: record "Dimension Value";
        GLE1: record "G/L Entry";
        Buildingproject: record "Building project";
        gPrjCode: code[20];
        GLE2: record "G/L Entry";
        BudgetCorrectionJournal: record "Budget Correction Journal";
        GLE3: record "G/L Entry";
        VATAmount: decimal;

        Text001: Label 'Start date cannot be greater End date';
        Text002: Label 'Set start date';
        Text003: Label 'Set end date';
        Text004: Label 'Create Correction budget';
        Text005: Label 'Line    #1###################\Receiving @2@@@@@@@@@@@@@@@@@@@';


    procedure Setdate(pStartDate: date; pProgectCode: code[20])
    begin
        StartDate := pStartDate;
        gPrjCode := pProgectCode;
    end;

    // procedure IsPeriodClose(pCode: code[20]; pDate: date)Ret: boolean
    // var 
    //     ProjectPerionClose: record "Project Perion Close";
    // begin
    //     ProjectPerionClose.SETRANGE("Project code",pCode);
    //     ProjectPerionClose.SETRANGE("Period Date",CALCDATE('<-CM>',pDate));
    //     IF ProjectPerionClose.FINDFIRST THEN Ret:=ProjectPerionClose.Close;
    // end;

    procedure GetAgreement(DocNo: code[20]; Amount: decimal; CompanyName: text[250]) Ret: code[20]
    var
        lrGE: record "G/L Entry";
    begin
        lrGE.RESET;
        IF CompanyName <> '' THEN
            lrGE.CHANGECOMPANY(CompanyName);
        lrGE.SETCURRENTKEY("Document No.");
        lrGE.SETRANGE("Document No.", DocNo);
        lrGE.SETFILTER("Agreement No.", '<>%1', '');
        lrGE.SETFILTER(Amount, '%1|%2', Amount, -Amount);

        IF lrGE.FINDFIRST THEN
            Ret := lrGE."Agreement No.";
    end;

    procedure IsrecognitionOfExpenses(AccountNo: code[20]; EntryNo: integer; CompanyNo: text[250]) Ret: boolean
    var
        GLCorrespondenceEntry: record "G/L Correspondence Entry";
    begin

        IF CompanyNo <> '' THEN
            GLCorrespondenceEntry.CHANGECOMPANY(CompanyNo)
        ELSE
            GLCorrespondenceEntry.CHANGECOMPANY(COMPANYNAME);


        Ret := FALSE;

        IF COPYSTR(AccountNo, 1, 5) = '14623' THEN BEGIN
            GLCorrespondenceEntry.SETCURRENTKEY("Credit Entry No.");
            GLCorrespondenceEntry.SETRANGE("Credit Entry No.", EntryNo);
            IF GLCorrespondenceEntry.FINDFIRST THEN BEGIN
                IF COPYSTR(GLCorrespondenceEntry."Debit Account No.", 1, 5) = '41110' THEN Ret := TRUE;
            END;
        END;

        //Ret:=FALSE;
    end;

    procedure CreateCPFilter(pInFlt: text[250]) OutFlt: text[250]
    var
        DimensionValue: record "Dimension Value";
    begin
        OutFlt := pInFlt;
        DimensionValue.SETRANGE("Dimension Code", 'CP');
        DimensionValue.SETFILTER(Code, pInFlt);
        IF DimensionValue.FINDFIRST THEN BEGIN
            IF DimensionValue.COUNT = 1 THEN BEGIN
                IF DimensionValue.Totaling <> '' THEN
                    OutFlt := DimensionValue.Totaling;
            END;
        END;
    end;

    procedure IsPreBooking(pDocNo: code[20]) Ret: boolean
    var
        PurchInvHeader: record "Purch. Inv. Header";
    begin
        // IF BC."IFRS Costs" THEN EXIT(FALSE); //SWC587 AKA 040815
        IF PurchInvHeader.GET(pDocNo) THEN
            EXIT(PurchInvHeader."Pre-booking Document");
    end;

    procedure Synch()
    var
        ProjectsCostControlEntry: record "Projects Cost Control Entry";
        Window: dialog;
        dd: integer;
        i: integer;
        BudgetCorrectionJournal: record "Budget Correction Journal";
        GLE: record "G/L Entry";
        GLE1: record "G/L Entry";
    begin
        BudgetCorrectionJournal.SETRANGE(Posted, FALSE);

        IF BudgetCorrectionJournal.FINDSET THEN BEGIN
            Window.OPEN('Синхронизация данных ...\' +
                               '@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
            dd := BudgetCorrectionJournal.COUNT;
            REPEAT
            BEGIN
                //SWC697 AKA 271015 >>
                IF gPrjCode = BudgetCorrectionJournal."Project Code" THEN BEGIN
                    //SWC697 AKA 271015 <<
                    GLE.CHANGECOMPANY(BudgetCorrectionJournal."Company Name");
                    GLE1.CHANGECOMPANY(BudgetCorrectionJournal."Company Name");

                    GLE.SETCURRENTKEY(ID);
                    GLE.SETRANGE(ID, BudgetCorrectionJournal.ID);
                    IF GLE.FINDFIRST THEN BEGIN
                        BudgetCorrectionJournal.Reversed := GLE.Reversed;

                        IF BudgetCorrectionJournal.Reversed THEN BEGIN
                            IF GLE."Reversed by Entry No." <> 0 THEN
                                GLE1.GET(GLE."Reversed by Entry No.");
                            IF GLE."Reversed Entry No." <> 0 THEN
                                GLE1.GET(GLE."Reversed Entry No.");

                            BudgetCorrectionJournal."Reversed ID" := GLE1.ID;
                        END;
                        BudgetCorrectionJournal.MODIFY;
                    END;
                END; //SWC697 AKA 271015
            END;
            i := i + 1;
            Window.UPDATE(1, ROUND(i / dd * 10000, 1));
            UNTIL BudgetCorrectionJournal.NEXT = 0;
            Window.CLOSE;
        END;
    end;

    procedure GetExtAgreement(DocNo: code[20]; Amount: decimal; CompanyName: text[250]) Ret: text[30]
    var
        lrGE: record "G/L Entry";
        lrVA: record "Vendor Agreement";
    begin
        lrGE.RESET;

        IF CompanyName <> '' THEN BEGIN
            lrGE.CHANGECOMPANY(CompanyName);
            lrVA.CHANGECOMPANY(CompanyName);
        END;
        lrGE.SETCURRENTKEY("Document No.");
        lrGE.SETRANGE("Document No.", DocNo);
        lrGE.SETFILTER("Agreement No.", '<>%1', '');
        lrGE.SETFILTER(Amount, '%1|%2', Amount, -Amount);

        IF lrGE.FINDFIRST THEN BEGIN
            lrVA.SETRANGE("No.", lrGE."Agreement No.");
            IF lrVA.FINDFIRST THEN
                Ret := lrVA."External Agreement No.";


        END;
    end;

    procedure GetVendorAgreement(DocNo: code[20]; Amount: decimal; CompanyName: text[250]) Ret: code[20]
    var
        lrGE: record "G/L Entry";
        lrVA: record "Vendor Agreement";
        lrVendor: record Vendor;
    begin
        lrGE.RESET;
        IF CompanyName <> '' THEN BEGIN
            lrGE.CHANGECOMPANY(CompanyName);
            lrVA.CHANGECOMPANY(CompanyName);
            lrVendor.CHANGECOMPANY(CompanyName);
        END;

        lrGE.SETCURRENTKEY("Document No.");
        lrGE.SETRANGE("Document No.", DocNo);
        lrGE.SETFILTER("Agreement No.", '<>%1', '');
        lrGE.SETFILTER(Amount, '%1|%2', Amount, -Amount);


        IF lrGE.FINDFIRST THEN BEGIN
            lrVA.SETRANGE("No.", lrGE."Agreement No.");
            IF lrVA.FINDFIRST THEN BEGIN
                IF lrVendor.GET(lrVA."Vendor No.") THEN
                    Ret := lrVendor."No.";

            END;
        END;
    end;

    procedure GetVendorNameAgreement(DocNo: code[20]; Amount: decimal; CompanyName: text[250]) Ret: text[250]
    var
        lrGE: record "G/L Entry";
        lrVA: record "Vendor Agreement";
        lrVendor: record Vendor;
    begin
        lrGE.RESET;
        IF CompanyName <> '' THEN BEGIN
            lrGE.CHANGECOMPANY(CompanyName);
            lrVA.CHANGECOMPANY(CompanyName);
            lrVendor.CHANGECOMPANY(CompanyName);
        END;

        lrGE.SETCURRENTKEY("Document No.");
        lrGE.SETRANGE("Document No.", DocNo);
        lrGE.SETFILTER("Agreement No.", '<>%1', '');
        lrGE.SETFILTER(Amount, '%1|%2', Amount, -Amount);


        IF lrGE.FINDFIRST THEN BEGIN
            lrVA.SETRANGE("No.", lrGE."Agreement No.");
            IF lrVA.FINDFIRST THEN BEGIN
                IF lrVendor.GET(lrVA."Vendor No.") THEN
                    Ret := lrVendor.Name;

            END;
        END;
    end;

    // procedure IsLocationDocument(pDocNo: code[20])Ret: boolean
    // var 
    //     PurchInvHeader: record "Purch. Inv. Header";
    // begin
    //     //NC 22512 > DP
    //     IF PurchInvHeader.GET(pDocNo) THEN
    //       EXIT(PurchInvHeader."Location Document");
    //     //NC 22512 < DP
    // end;

    local procedure PageFieldOnAfterValidate()
    begin
        IF (EndDate <> 0D) AND (StartDate > EndDate) THEN BEGIN
            MESSAGE('Начало Периода не можеть быть больше Конца Периода');
            EndDate := 0D;
        END;
    end;


}

