page 70215 "Budget Cor. Journal Constr"
{
    Permissions = TableData 17 = rm;
    InsertAllowed = false;
    SourceTable = "Budget Correction Journal";
    SourceTableView = WHERE(Posted = CONST(false));
    PageType = ListPlus;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Budget Adjustment Journal';


    layout
    {
        area(content)
        {
            group(Control12370004)
            {
                Caption = 'Lines Quantity';
                field(COUNT1; Rec.COUNT)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ShowCaption = false;

                }

                field(GetAmount1; GetAmount)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ShowCaption = false;
                }



            }
            group(Posting)
            {
                part(SubForm1; "Budget Correction Journal Sub")
                {
                    ApplicationArea = All;

                }



            }
            // group(Unbound12370002)
            // {
            //     field(HideNull; HideNull)
            //     {
            //         Visible = false;
            //         ShowCaption = false;
            //         ApplicationArea = All;
            //         Caption = 'Only with line budget';

            //     }



            // }
            repeater(Repeater12370003)
            {
                field(ID; Rec.ID)
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Entry No"; Rec."Entry No")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Code; Rec.Code)
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Posted; Rec.Posted)
                {
                    Visible = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field("Project Code"; Rec."Project Code")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Doc No"; Rec."Doc No")
                {
                    Editable = false;
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        NavigateForm.SetDoc(Date, "Doc No");
                        NavigateForm.RUN;
                    end;


                }

                field("Agreement No."; Rec."Agreement No.")
                {
                    Editable = true;
                    ApplicationArea = All;
                    trigger OnLookup(var Text: text): boolean
                    var
                        VendorAgreement: record "Vendor Agreement";
                    begin
                        IF VendorAgreement.GET("Vendor No.", "Agreement No.") THEN
                            PAGE.RUN(14902, VendorAgreement);
                    end;


                }

                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("External Agreement No."; Rec."External Agreement No.")
                {
                    Editable = true;
                    ApplicationArea = All;

                }

                field("Vendor No."; Rec."Vendor No.")
                {
                    Editable = true;
                    ApplicationArea = All;

                }

                field("Vendor Name"; Rec."Vendor Name")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Name; Rec.Name)
                {
                    Editable = true;
                    ApplicationArea = All;

                }

                field("Dimension Totaling 1"; Rec."Dimension Totaling 1")
                {
                    Editable = false;
                    ApplicationArea = All;
                    trigger OnLookup(var Text: text): boolean
                    begin
                        EXIT(LookUpDimFilter(1, Text));
                    end;


                }

                field("Dimension Totaling 2"; Rec."Dimension Totaling 2")
                {
                    Editable = true;
                    ApplicationArea = All;
                    trigger OnLookup(var Text: text): boolean
                    begin
                        EXIT(LookUpDimFilter(2, Text));
                    end;


                }

                field("Cost Type"; Rec."Cost Type")
                {
                    Editable = true;
                    ApplicationArea = All;

                }

                field(Date; Rec.Date)
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Original Date"; Rec."Original Date")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Amount; Rec.Amount)
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                // field("Apply Amount"; Rec."Apply Amount")
                // {
                //     Visible = false;
                //     Editable = false;
                //     ApplicationArea = All;
                //     trigger OnDrillDown()
                //     var 
                //         vBCJ: record "Budget Correction Journal";
                //     begin
                //         /*IF "Apply Corrections"=FALSE THEN EXIT;

                //         vBCJ.GET(ID);

                //         CLEAR(ApplyForm);
                //         ApplyForm.SetPar(ID);
                //         ApplyForm.GetBudgetEntry;
                //         ApplyForm.RUN;
                //          */
                //     end;


                // }   

                field("Diff Amount"; Rec."Diff Amount")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Advances; Rec.Advances)
                {
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field(Allocation; Rec.Allocation)
                {
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field("G/L Account Totaling"; Rec."G/L Account Totaling")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                    trigger OnLookup(var Text: text): boolean
                    var
                        GLAccList: page "G/L Account List";
                    begin
                        GLAccList.LOOKUPMODE(TRUE);
                        IF NOT (GLAccList.RUNMODAL = ACTION::LookupOK) THEN
                            EXIT(FALSE)
                        ELSE
                            Text := GLAccList.GetSelectionFilter;
                        EXIT(TRUE);
                    end;


                }

                field("Priod Group Type"; Rec."Priod Group Type")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Description; Rec.Description)
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                // field("Journal Batch Name"; Rec."Journal Batch Name")
                // {
                //     Visible = false;
                //     Editable = false;
                //     ApplicationArea = All;

                // }   

                field("Correction Batch"; Rec."Correction Batch")
                {
                    Visible = false;
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field("Source Code"; Rec."Source Code")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Company Name"; Rec."Company Name")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Creation Date"; Rec."Creation Date")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("User id"; Rec."User id")
                {
                    Editable = false;
                    ApplicationArea = All;

                }



            }
        }
    }


    actions
    {
        area(navigation)
        {
            group(Options)
            {
                Caption = 'Functions';
                // action(Get)
                // {
                //     Visible = No;
                //     Caption = 'Get';
                //     trigger OnAction()
                //     begin
                //         CLEAR(Rep1);
                //         Rep1.RUNMODAL;
                //     end;


                // }   

                // action(Apply)
                // {
                //     Visible = No;
                //     Caption = 'Apply';
                //     trigger OnAction()
                //     var 
                //         vBCJ: record "Budget Correction Journal";
                //     begin
                //         IF "Apply Corrections"=FALSE THEN EXIT;

                //         vBCJ.GET(ID);

                //         /*CLEAR(ApplyForm);
                //         ApplyForm.SetPar(ID);
                //         ApplyForm.GetBudgetEntry;
                //         ApplyForm.RUN;
                //          */
                //     end;
                // }   

                action(Control12370049)
                {
                    Caption = 'Get';
                    trigger OnAction()
                    var
                        Buildingproject: record "Building project";
                    begin
                        CLEAR(Rep2);
                        Rec.FILTERGROUP := 0;
                        Buildingproject.GET(Rec.GETFILTER("Project Code"));
                        Rec.FILTERGROUP := 2;
                        // Rep2.Setdate(Buildingproject."Dev. Starting Date", Buildingproject.Code);
                        Rep2.RUNMODAL;
                    end;


                }

                // action(Control12370052)
                // {
                //     Visible = No;
                //     Caption = 'qqq';
                //     trigger OnAction()
                //     begin
                //         Synch;
                //     end;


                // }   


            }
            action(PostA)
            {
                Caption = 'Post';
                trigger OnAction()
                begin
                    IF CONFIRM(Text004) THEN BEGIN
                        // SWC936 DD 17.11.16 >>
                        //IF UPPERCASE(USERID) <> 'RUDMIDAN' THEN
                        // IF CONFIRM('Запустить синхронизацию?',TRUE) THEN
                        // SWC936 DD 17.11.16 <<
                        //  Synch;

                        Post;

                        CurrPage.UPDATE(FALSE);
                        CurrPage.SubForm1.PAGE.UpdateForm;
                    END;
                end;


            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        // CALCFIELDS("Apply Corrections");
        // "Diff Amount":=Amount-"Apply Amount";
    end;

    trigger OnOpenPage()
    begin

        // IF HideNull THEN
        //  SETRANGE("Apply Corrections",TRUE)
        // ELSE
        //  SETRANGE("Apply Corrections");
    end;



    var
        // Rep1: report "Get Lines for Budget";
        GLS: record "General Ledger Setup";
        Text001: Label 'Powered by budget lines: %1';
        Text002: Label 'Do not set no budget line';
        HideNull: boolean;
        Text003: Label 'Operation canceled by user.';
        Rep2: report "Get Lines for Budget Constr";
        ERPC: codeunit "ERPC Funtions";
        NavigateForm: page Navigate;
        Text004: Label 'Post Budget Agjustment Journal?';
        gvError: boolean;
        ProjCodeFilter: Code[1024];


    procedure Post()
    var
        BudgetAmount: decimal;
        ApplyAmount: decimal;
        DiffAmount: decimal;
        LocBCJ: record "Budget Correction Journal";
        LocBPE: record "Projects Budget Entry";
        LocBPE1: record "Projects Budget Entry";
        EntryNo: integer;
        LocPV: record "Project Version";
        LocDV: record "Dimension Value";
        LocBT: record "Building turn";
        // LocABC: record "Apply Budget Correction";
        LocPLD: record "Projects Line Dimension";
        LocPSL: record "Projects Structure Lines";
        LocPSLTemp: record "Projects Structure Lines" temporary;
        Cnt: integer;
        Window: dialog;
        dd: integer;
        i: integer;
        posted: boolean;
    begin
        GLS.GET;

        EntryNo := 1;
        LocBPE.RESET;
        LocBPE.SETCURRENTKEY("Entry No.");
        IF LocBPE.FINDLAST THEN
            EntryNo := LocBPE."Entry No." + 1;

        Cnt := 0;

        LocBCJ.RESET;
        LocBCJ.COPY(Rec);
        LocBCJ.FILTERGROUP(2);
        LocBCJ.SETRANGE(Posted, FALSE);
        LocBCJ.SETRANGE("Project Code", ProjCodeFilter);
        IF LocBCJ.FIND('-') THEN BEGIN
            Window.OPEN('Учет данных ...\' +
                               '@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
            dd := LocBCJ.COUNT;
            REPEAT
                IF NOT TestDate(LocBCJ) THEN BEGIN
                    // NC 36695 >>
                    //ERPC.CreateBCPreBookingJ(LocBCJ);
                    //LocBCJ.Posted:=TRUE;                    
                    posted := ERPC.CreateBCPreBookingJConstr(LocBCJ);
                    LocBCJ.Posted := posted;
                    // NC 36695 <<
                    LocBCJ.MODIFY;
                    Cnt := Cnt + 1;
                END;
                i := i + 1;
                Window.UPDATE(1, ROUND(i / dd * 10000, 1));
            UNTIL LocBCJ.NEXT = 0;
            Window.CLOSE;
        END;

        IF Cnt = 0 THEN
            MESSAGE(Text002)
        ELSE
            MESSAGE(Text001, Cnt);
    end;

    procedure TestDate(pRec: record "Budget Correction Journal") Ret: boolean
    var
        Buildingturn: record "Building turn";
        ProjectsLineDimension: record "Projects Line Dimension";
        ProjectsStructureLines: record "Projects Structure Lines";
    begin
        Message('P70187.TestDate');
        //todo
        // Buildingturn.SETRANGE("Turn Dimension Code",pRec."Dimension Totaling 1");
        // // SWC936 DD 17.11.16 >>
        // Buildingturn.SETRANGE("Development/Production",Buildingturn."Development/Production"::Development);
        // IF NOT Buildingturn.FINDFIRST THEN
        //   Buildingturn.SETRANGE("Development/Production");
        // // SWC936 DD 17.11.16 <<
        // IF NOT Buildingturn.FINDFIRST THEN EXIT(TRUE);

        // // SWC936 DD 16.11.16 >>
        // IF pRec."Dimension Totaling 2" = '' THEN BEGIN
        //   ProjectsStructureLines.RESET;
        //   ProjectsStructureLines.SETRANGE("Project Code",pRec."Project Code");
        //   ProjectsStructureLines.SETRANGE(Code,'XXXX');
        //   IF ProjectsStructureLines.FINDFIRST THEN
        //     EXIT(FALSE);
        //   ProjectsStructureLines.RESET;
        // END;
        // // SWC936 DD 16.11.16 <<

        // ProjectsLineDimension.SETRANGE("Project No.",Buildingturn."Building project Code");
        // ProjectsLineDimension.SETRANGE("Dimension Value Code",pRec."Dimension Totaling 2");
        // ProjectsLineDimension.SETRANGE("Detailed Line No.",0);
        // ProjectsLineDimension.SETRANGE("Dimension Code",'CC');
        // ProjectsLineDimension.SETRANGE("Project Version No.",GetDefVersion1(Buildingturn."Building project Code"));
        // IF NOT ProjectsLineDimension.FINDFIRST THEN EXIT(TRUE);

        // ProjectsStructureLines.SETRANGE("Project Code",Buildingturn."Building project Code");
        // ProjectsStructureLines.SETRANGE("Line No.",ProjectsLineDimension."Project Line No.");
        // IF NOT ProjectsStructureLines.FINDFIRST THEN EXIT(TRUE);
    end;

    procedure GetDefVersion1(pProjectCode: code[20]) Ret: code[20]
    var
        lrProjectVersion: record "Project Version";
    begin
        lrProjectVersion.SETRANGE("Project Code", pProjectCode);
        lrProjectVersion.SETRANGE("Fixed Version");
        lrProjectVersion.SETRANGE("First Version", TRUE);
        IF lrProjectVersion.FIND('-') THEN
            Ret := lrProjectVersion."Version Code";
    end;

    procedure GetAmount() Ret: decimal
    var
        BudgetCorrectionJournal: record "Budget Correction Journal";
    begin
        BudgetCorrectionJournal.COPY(Rec);
        IF BudgetCorrectionJournal.FINDSET THEN BEGIN
            REPEAT
                Ret := Ret + BudgetCorrectionJournal.Amount;
            UNTIL BudgetCorrectionJournal.NEXT = 0;
        END;
    end;

    procedure TestAgreement(pRec: record "Budget Correction Journal") Ret: boolean
    var
        lrAgreement: record "Vendor Agreement";
    begin
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
        VendorAgreementDetails: record "Vendor Agreement Details";
        VendorAgreement: record "Vendor Agreement";
    begin
        Message('P70187.Synch');
        //todo
        // FILTERGROUP := 0;
        // //ProjectsCostControlEntry.SETRANGE("Project Code",GETFILTER("Project Code"));
        // FILTERGROUP := 2;
        // //ProjectsCostControlEntry.SETRANGE(Code,'0311');
        // //ProjectsCostControlEntry.SETRANGE("Project Code",'AP');
        // ProjectsCostControlEntry.SETFILTER("Analysis Type", '%1|%2|%3', ProjectsCostControlEntry."Analysis Type"::Actuals,
        //                                                            ProjectsCostControlEntry."Analysis Type"::Adv,
        //                                                             ProjectsCostControlEntry."Analysis Type"::AllocActuals);

        // // SWC936 DD 16.11.16 >>
        // ProjectsCostControlEntry.SETCURRENTKEY("Analysis Type");
        // BudgetCorrectionJournal.SETCURRENTKEY("Project Code");
        // // SWC936 DD 16.11.16 >>
        // IF ProjectsCostControlEntry.FINDSET THEN BEGIN
        //     Window.OPEN('Синхронизация данных ...\' +
        //                        '@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        //     dd := ProjectsCostControlEntry.COUNT;
        //     REPEAT
        //         BudgetCorrectionJournal.SETRANGE(ID, ProjectsCostControlEntry.ID);
        //         BudgetCorrectionJournal.SETRANGE("Doc No", ProjectsCostControlEntry."Doc No.");
        //         BudgetCorrectionJournal.SETRANGE("Project Code", ProjectsCostControlEntry."Project Code");
        //         IF BudgetCorrectionJournal.FINDSET THEN
        //             REPEAT
        //                 GLE.CHANGECOMPANY(BudgetCorrectionJournal."Company Name");
        //                 GLE1.CHANGECOMPANY(BudgetCorrectionJournal."Company Name");
        //                 GLE.SETCURRENTKEY(ID);
        //                 GLE.SETRANGE(ID, BudgetCorrectionJournal.ID);
        //                 IF GLE.FINDFIRST THEN BEGIN
        //                     ProjectsCostControlEntry.Reversed := GLE.Reversed;

        //                     IF ProjectsCostControlEntry.Reversed THEN BEGIN
        //                         IF GLE."Reversed by Entry No." <> 0 THEN
        //                             GLE1.GET(GLE."Reversed by Entry No.");
        //                         IF GLE."Reversed Entry No." <> 0 THEN
        //                             GLE1.GET(GLE."Reversed Entry No.");


        //                         ProjectsCostControlEntry."Reversed ID" := GLE1.ID;
        //                         IF (GLE."Reversed by Entry No." = 0) AND (GLE."Reversed Entry No." = 0) THEN BEGIN
        //                             ProjectsCostControlEntry."Reversed ID" := 0;
        //                             ProjectsCostControlEntry.Reversed := FALSE;
        //                         END;
        //                     END;
        //                     IF GLE.Reversed AND (GLE."Reversed by Entry No." = 0) AND (GLE."Reversed Entry No." = 0) THEN BEGIN
        //                         ProjectsCostControlEntry."Reversed Without Entry" := TRUE;
        //                     END;

        //                     ProjectsCostControlEntry.MODIFY;
        //                 END;
        //             UNTIL BudgetCorrectionJournal.NEXT = 0;
        //         i := i + 1;
        //         Window.UPDATE(1, ROUND(i / dd * 10000, 1));
        //     UNTIL ProjectsCostControlEntry.NEXT = 0;
        //     ProjectsCostControlEntry.RESET;
        //     ProjectsCostControlEntry.SETCURRENTKEY("Reversed Without Entry");
        //     ProjectsCostControlEntry.SETRANGE("Reversed Without Entry", TRUE);
        //     IF ProjectsCostControlEntry.FINDSET THEN BEGIN
        //         REPEAT
        //             IF VendorAgreement.GET(ProjectsCostControlEntry."Contragent No.", ProjectsCostControlEntry."Agrrement No.") THEN BEGIN
        //                 IF VendorAgreement.WithOut THEN BEGIN
        //                     VendorAgreementDetails.SETRANGE("Vendor No.", ProjectsCostControlEntry."Contragent No.");
        //                     VendorAgreementDetails.SETRANGE("Agreement No.", ProjectsCostControlEntry."Agrrement No.");
        //                     VendorAgreementDetails.SETRANGE("Global Dimension 1 Code", ProjectsCostControlEntry."Shortcut Dimension 1 Code");
        //                     VendorAgreementDetails.SETRANGE("Global Dimension 2 Code", ProjectsCostControlEntry."Shortcut Dimension 2 Code");
        //                     IF VendorAgreementDetails.FINDFIRST THEN BEGIN
        //                         VendorAgreementDetails.Amount := VendorAgreementDetails.Amount - ProjectsCostControlEntry."Without VAT";
        //                         //SWC862 KAE 140716 >>
        //                         //VendorAgreementDetails.MODIFY;
        //                         VendorAgreementDetails.MODIFY(TRUE);
        //                         //SWC862 KAE 140716 <<
        //                     END;
        //                 END;
        //             END;
        //             ProjectsCostControlEntry.DELETE;

        //         UNTIL ProjectsCostControlEntry.NEXT = 0;
        //     END;

        //     Window.CLOSE;
        // END;
    end;
}

