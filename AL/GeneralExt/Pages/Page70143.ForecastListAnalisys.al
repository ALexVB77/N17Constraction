page 70143 "Forecast List Analisys"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = true;
    DeleteAllowed = false;
    SourceTable = "Projects Budget Entry";
    SourceTableView = sorting(Date) order(descending);
    DelayedInsert = true;
    PopulateAllFields = true;
    Caption = 'Transaction Register';

    layout
    {
        area(Content)
        {
            group(FilterGr2)
            {
                Caption = 'Filters';
                field(TemplateCode; TemplateCode)
                {
                    ApplicationArea = All;
                    Caption = 'Project Code';
                    trigger OnLookup(var Text: text): boolean
                    var
                        lDimVal: Record "Dimension Value";
                    begin
                        GLSetup.Get();
                        GLSetup.TestField("Project Dimension Code");
                        lDimVal.Reset();
                        lDimVal.SetRange("Dimension Code", GLSetup."Project Dimension Code");
                        if Page.RunModal(PAGE::"Dimension Values", lDimVal) = Action::LookupOK then begin
                            TemplateCode := lDimVal.Code;
                            ValidateProject();
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        TemplateCodeOnAfterValidate; //navnav;

                    end;
                }
                field(TemplateDescription; TemplateDescription)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ShowCaption = false;

                }

                field(DateFilter1; DateFilter1)
                {
                    ApplicationArea = All;
                    Caption = 'Date Filter';
                    trigger OnValidate()
                    var
                        FltHelpTrigs: codeunit "Filter Helper Triggers";
                    begin
                        FltHelpTrigs.MakeDateFilter(DateFilter1);
                        GLAccBudgetBuf.SETFILTER("Date Filter", DateFilter1);
                        DateFilter1 := GLAccBudgetBuf.GETFILTER("Date Filter");
                        Rec.SetFilter(Date, DateFilter1);
                        CurrPage.Update(false);
                    end;


                }

                field(CostPlaceFlt; CostPlaceFlt)
                {
                    ApplicationArea = All;
                    Caption = 'COST PLACE';
                    trigger OnLookup(var Text: text): boolean
                    var
                        lDimVal: Record "Dimension Value";
                    begin
                        lDimVal.Reset();
                        lDimVal.SetRange("Global Dimension No.", 1);
                        lDimVal.SetFilter("Project Code", TemplateCode);
                        if Page.RunModal(PAGE::"Dimension Values", lDimVal) = Action::LookupOK then begin
                            CostPlaceFlt := lDimVal.Code;
                            Rec.SetFilter("Shortcut Dimension 1 Code", CostPlaceFlt);
                            CurrPage.Update(false);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Shortcut Dimension 1 Code", CostPlaceFlt);
                        CurrPage.Update(false);
                    end;


                }

                field(CostCodeFlt; CostCodeFlt)
                {
                    ApplicationArea = All;
                    Caption = 'COST CODE';
                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Shortcut Dimension 2 Code", CostCodeFlt);
                        CurrPage.Update(false);
                    end;

                    trigger OnLookup(var Text: text): boolean
                    var
                        lDimVal: Record "Dimension Value";
                    begin
                        lDimVal.Reset();
                        lDimVal.SetRange("Global Dimension No.", 2);
                        IF PAGE.RUNMODAL(PAGE::"Dimension Values", lDimVal) = ACTION::LookupOK THEN BEGIN
                            CostCodeFlt := lDimVal.Code;
                            Rec.SETFILTER("Shortcut Dimension 2 Code", CostCodeFlt);
                            CurrPage.UPDATE;
                        END;
                    end;


                }

                field(Overdue; Overdue)
                {
                    ApplicationArea = All;
                    Caption = 'Overdue';
                    trigger OnValidate()
                    begin
                        setOverdueFlt();
                    end;


                }

                field(gDate; gDate)
                {
                    ApplicationArea = All;
                    Caption = 'Overdue on Date';
                    trigger OnValidate()
                    begin
                        setOverdueFlt();
                    end;


                }

                field(HideZeroAmountLine; HideZeroAmountLine)
                {
                    ApplicationArea = All;
                    Caption = 'Don''t show zero amount lines';
                    trigger OnValidate()
                    begin
                        BuildView();
                    end;


                }
            }
            repeater(Repeater12370003)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;

                }

                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;

                }
                field(Close; Rec.Close)
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Actual Flag';
                    StyleExpr = LineStyletxt;
                    trigger OnValidate()
                    begin
                        // CloseOnAfterValidate; //navnav;

                    end;


                }

                field("Date"; Rec.Date)
                {
                    Editable = LineEditable;
                    NotBlank = true;
                    ApplicationArea = All;
                    Caption = 'Date';
                    StyleExpr = LineStyletxt;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        // DateOnAfterValidate; //navnav;

                        //NC 27251 HR beg
                        //CheckUniqMonthCFLine;
                        //NC 27251 HR end
                    end;


                }

                field("Project Code"; Rec."Project Code")
                {
                    Editable = ProjectEditable;
                    ApplicationArea = All;
                    Caption = 'Project Code';
                    StyleExpr = LineStyletxt;
                    ShowMandatory = true;

                }
                // field("Cost Code"; Rec."Cost Code")
                // {
                //     Visible = false;
                //     Editable = false;
                //     ApplicationArea = All;
                //     StyleExpr = LineStyletxt;

                // }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Visible = CPEditable;
                    Editable = LineEditable;
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;
                    ShowMandatory = true;

                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Editable = LineEditable;
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;

                }
                field(Description; Rec.Description)
                {
                    Editable = LineEditable;
                    ApplicationArea = All;
                    Caption = 'Description';
                    StyleExpr = LineStyletxt;
                    trigger OnAssistEdit()
                    var
                        lrPL: record "Purchase Line";
                        lrPH: record "Purchase Header";
                    begin
                        IF Close THEN BEGIN
                            lrPL.SETCURRENTKEY("Forecast Entry");
                            lrPL.SETRANGE("Forecast Entry", "Entry No.");
                            IF lrPL.FINDFIRST THEN BEGIN
                                lrPH.SETRANGE("Document Type", lrPL."Document Type");
                                lrPH.SETRANGE("No.", lrPL."Document No.");
                                IF lrPH.FINDFIRST THEN BEGIN
                                    PAGE.RUN(70000, lrPH);

                                END;
                            END;
                        END;
                    end;


                }
                field("Description 2"; Rec."Description 2")
                {
                    Editable = LineEditable;
                    ApplicationArea = All;
                    Caption = 'Description 2';
                    StyleExpr = LineStyletxt;

                }
                field("Payment Description"; Rec."Payment Description")
                {
                    Editable = LineEditable;
                    Visible = false;
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;
                }
                field("Without VAT (LCY)"; Rec."Without VAT (LCY)")
                {
                    Visible = true;
                    Editable = LineEditable;
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;
                    ShowMandatory = true;

                }
                field("Contragent No."; Rec."Contragent No.")
                {
                    Editable = LineEditable;
                    ApplicationArea = All;
                    Caption = 'Vendor No.';
                    StyleExpr = LineStyletxt;
                    trigger OnValidate()
                    begin
                        //NC 27251 HR beg
                        //CheckUniqMonthCFLine;
                        //NC 27251 HR end
                    end;

                    trigger OnLookup(var Text: text): boolean
                    begin

                        IF grVendor.FINDFIRST THEN BEGIN
                            IF grVendor.GET(Rec."Contragent No.") THEN;
                            IF PAGE.RUNMODAL(PAGE::"Vendor List", grVendor) = ACTION::LookupOK THEN BEGIN
                                Rec."Contragent Type" := Rec."Contragent Type"::Vendor;
                                Rec.VALIDATE("Contragent No.", grVendor."No.");
                            END;
                        END;
                    end;
                }
                field(CName; Rec."Contragent Name")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Vendor Name';
                    StyleExpr = LineStyletxt;

                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    Editable = LineEditable;
                    ApplicationArea = All;
                    Caption = 'Agreement No.';
                    StyleExpr = LineStyletxt;
                    trigger OnLookup(var Text: text): boolean
                    var
                        lrProjectsBudgetEntry: record "Projects Budget Entry";
                        lfCFCorrection: page "Forecast List Analisys Correct";
                    begin
                        CurrPage.SAVERECORD;
                        COMMIT;
                        grVendorAgreement.SETRANGE("Vendor No.", Rec."Contragent No.");
                        grVendorAgreement.SETRANGE(Active, TRUE);
                        IF grVendorAgreement.FINDFIRST THEN BEGIN
                            IF grVendorAgreement.GET(Rec."Contragent No.", Rec."Agreement No.") THEN;
                            IF PAGE.RUNMODAL(PAGE::"Vendor Agreements", grVendorAgreement) = ACTION::LookupOK THEN BEGIN
                                IF grVendorAgreement."No." <> '' THEN BEGIN
                                    IF Rec."Building Turn" = '' THEN BEGIN
                                        MESSAGE(TEXT0004);
                                        EXIT;
                                    END;

                                    //NC 28666 HR beg
                                    //IF "Cost Code"  = '' THEN
                                    //BEGIN
                                    //  MESSAGE(TEXT0005);
                                    //  EXIT;
                                    //END;
                                    IF (NOT IsProductionProject) AND (Rec."Cost Code" = '') THEN BEGIN
                                        MESSAGE(TEXT0005);
                                        EXIT;
                                    END;
                                    //NC 28666 HR end

                                    IF Rec."Without VAT" = 0 THEN BEGIN
                                        MESSAGE(TEXT0006);
                                        EXIT;
                                    END;
                                END;

                                Delta := Rec.Amount;
                                vAgreement.GET("Contragent No.", grVendorAgreement."No.");
                                // IF NOT vAgreement.Virtual THEN   // CHECK
                                if true then BEGIN
                                    // SWC DD 20.07.17 >>
                                    IF NOT vAgreement."Don't Check CashFlow" THEN
                                        // SWC DD 20.07.17 <<
                                        //   IF Delta>(vAgreement."Agreement Amount"-GetAmount(grVendorAgreement."No.")) THEN
                                        //   BEGIN
                                        //     MESSAGE(TEXT001);
                                        //     EXIT;
                                        //   END;


                                        VALIDATE("Agreement No.", grVendorAgreement."No.");
                                    IF (Rec."Agreement No." <> '') AND (xRec."Agreement No." = '') THEN BEGIN
                                        //NC 29435 HR beg
                                        ////NC 28666 HR beg
                                        //IF NOT (IsProductionProject AND ("Cost Code" = '')) THEN BEGIN
                                        ////NC 28666 HR end
                                        IF NOT IsProductionProject THEN BEGIN
                                            //NC 29435 HR end

                                            MESSAGE(TEXT0008);
                                            CLEAR(lfCFCorrection);
                                            lfCFCorrection.LOOKUPMODE := TRUE;
                                            lrProjectsBudgetEntry.SETCURRENTKEY(Date);
                                            lrProjectsBudgetEntry.SETRANGE("Project Code", Rec."Project Code");
                                            lrProjectsBudgetEntry.SETRANGE("Project Turn Code", Rec."Project Turn Code");
                                            lrProjectsBudgetEntry.SETRANGE("Cost Code", Rec."Cost Code");
                                            lrProjectsBudgetEntry.SETFILTER("Contragent No.", '%1|%2', '', Rec."Contragent No.");
                                            lrProjectsBudgetEntry.SETRANGE("Agreement No.", '');
                                            lrProjectsBudgetEntry.SETFILTER("Entry No.", '<>%1', Rec."Entry No.");
                                            lrProjectsBudgetEntry.SETRANGE(NotVisible, FALSE);
                                            IF lrProjectsBudgetEntry.FINDFIRST THEN;
                                            lfCFCorrection.SETTABLEVIEW(lrProjectsBudgetEntry);
                                            lfCFCorrection.SetData(Rec);
                                            IF lfCFCorrection.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                                // SetSum;
                                            END
                                            ELSE BEGIN
                                                // ClearSum;
                                                Rec.VALIDATE("Agreement No.", OldAgreement);
                                                MESSAGE(TEXT0009);
                                            END;
                                        END; //NC 28666 HR <>
                                    END;
                                END
                                ELSE
                                    VALIDATE("Agreement No.", grVendorAgreement."No.");

                            END;
                        END;
                        OldAgreement := "Agreement No.";
                        CurrPage.UPDATE;
                    end;

                    trigger OnValidate()
                    begin
                        // AgreementNoOnAfterValidate; //navnav;

                    end;


                }

                field(AE; Rec."External Agreement No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'External Agreement No.';
                    StyleExpr = LineStyletxt;

                }
                field("Payment Doc. No."; Rec."Payment Doc. No.")
                {
                    Visible = true;
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;

                }

                field("Create User"; Rec."Create User")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;
                    Editable = CreateUIDEditable;

                }
                field("Parent Entry"; Rec."Parent Entry")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyletxt;
                    Editable = false;
                }
                field("Close Date"; Rec."Close Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = LineStyletxt;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateSTEntries)
            {
                Caption = 'Create short-term planning lines';
                ApplicationArea = All;

                trigger OnAction()
                var
                    CreateSTPrBEntPage: Page "Create ST Proj Budget Entries";
                begin
                    US.Get(UserId);
                    if not (US."CF Allow Short Entries Edit") then
                        Error(TEXT0015);
                    Clear(CreateSTPrBEntPage);
                    CreateSTPrBEntPage.SetProjBudEntry(Rec);
                    if CreateSTPrBEntPage.RunModal() = action::LookupOK then;
                    CurrPage.update(false);
                end;
            }
            action(DeleteSTEntries)
            {
                Caption = 'Delete short-term planning lines';
                ApplicationArea = All;
                trigger OnAction()
                var
                    lPrBudEntry: Record "Projects Budget Entry";
                begin
                    CurrPage.SetSelectionFilter(lPrBudEntry);
                    PrjBudMgt.DeleteSTLine(lPrBudEntry);
                end;
            }
            action(ShowRelatedEntries)
            {
                Caption = 'Show related lines';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    if Rec.GetFilter("Parent Entry") <> '' then
                        Rec.SetRange("Parent Entry")
                    else
                        Rec.SetRange("Parent Entry", Rec."Parent Entry");
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        //HideZeroAmountLine := true;
        BuildView();
        if gDate = 0D then
            gDate := Today;
        if US.Get(UserId) then
            TemplateCode := US."Last Project Code";
        ValidateProject();
        setOverdueFlt();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        lDimVal: Record "Dimension Value";
    begin
        CheckAllowChanges();
        GLSetup.Get;
        if TemplateCode <> '' then
            Rec."Project Code" := TemplateCode;
        if CostPlaceFlt <> '' then begin
            lDimVal.reset;
            lDimVal.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
            lDimVal.SetFilter(Code, CostPlaceFlt);
            if lDimVal.Count > 1 then
                Error(StrSubstNo(TEXT0990, TEXT0991));
            if lDimVal.FindFirst() then
                Rec."Shortcut Dimension 1 Code" := lDimVal.Code;
        end;
        if CostCodeFlt <> '' then begin
            lDimVal.reset;
            lDimVal.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
            lDimVal.SetFilter(Code, CostCodeFlt);
            if lDimVal.Count > 1 then
                Error(StrSubstNo(TEXT0990, TEXT0992));
            if lDimVal.FindFirst() then
                Rec."Shortcut Dimension 2 Code" := lDimVal.Code;
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        GetLineStyle(Rec);
        GetLineEditable(Rec);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckAllowChanges();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CheckAllowChanges();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CheckAllowChanges();
    end;

    trigger OnClosePage()
    begin
        if US.Get(UserId) then begin
            US."Last Project Code" := TemplateCode;
            if US.Modify() then;
        end;
    end;

    var
        LineStyletxt: Text;
        CurrTrType: code[20];
        GLSetup: record "General Ledger Setup";
        TemplateName: code[10];
        LineDimOption: Option structure,period,"global dimension 1","global dimension 2";
        ColumnDimOption: Option structure,period,"global dimension 1","global dimension 2";
        LineDimCode: text[30];
        ColumnDimCode: text[30];
        PeriodType: Option day,week,month,quarter,year,"accounting period";
        RoundingFactor: Option "none","1","1000","1000000";
        ShowColumnName: boolean;
        StructAmount: decimal;
        DateFilter: text[30];
        InternalDateFilter: text[30];
        MatrixHeader: text[50];
        PeriodInitialized: boolean;
        InputError: boolean;
        InputErrorText: text[250];
        NormalFormatString: text[80];
        StructLine: record "Projects Structure Lines";
        ProjectStructure: record "Projects Structure";
        gvBuildingTurn: record "Building turn";
        TemplateCode: code[20];
        TemplateDescription: text[250];
        AnalysisType: Option inv,det,est;
        grProjectsStructure: record "Projects Structure";
        JT: record "Projects Structure Lines";
        DevSetup: record "Projects Structure";
        CalcType: Option "0","1","2","3";
        VersionCode: code[20];
        grPrjVesion: record "Project Version";
        grPrjStructure: record "Projects Structure";
        gvAnalysisType: integer;
        grPrjVesionNav: record "Project Version";
        ProjectsStructureLines: record "Projects Structure Lines";
        // ProjectStructureList: page "Project Structure List";
        ProjectsBudgetEntry: record "Projects Budget Entry";
        OldLineNo: integer;
        ProjectsBudgetEntry1: record "Projects Budget Entry";
        // gfTurnStructureAnalisys: page "Turn Structure Analisys";
        AnalysisDataType: Option bdir,bdds;
        gAmountTotal: decimal;
        gcduERPC: codeunit "ERPC Funtions";
        BudgetOnDate: date;
        FixBudget: boolean;
        gAmountTotalBudget: decimal;
        AmountType: Option amount,wamount,vat;
        grProjectsBudgetEntry: record "Projects Budget Entry";
        grProjectsStructureLines: record "Projects Structure Lines";
        grCustomerAgreement: record "Customer Agreement";
        // grInvestmentAgreementLIne: record "Investment Agreement LIne";
        DateFilter1: text[30];
        GLAccBudgetBuf: record "G/L Acc. Budget Buffer";
        CostPlaceFlt: text[200];
        CostCodeFlt: text[200];
        gSorting: Option pdate,pcontrname,costcode;
        Overdue: boolean;
        OnlyOpen: boolean;
        grDevelopmentSetup: record "Development Setup";
        TypeOper: Option all,open,close;
        gDate: date;
        grPrjStrLine: record "Projects Structure Lines";
        // frmAdjustedBudget: page "Adjusted Budget";
        DataType: Option all,act,comm,res,ytb;
        vAgreement: record "Vendor Agreement";
        Delta: decimal;
        grProjectsStructureLines1: record "Projects Structure Lines";
        ProjectVersion: record "Project Version";
        grVendor: record Vendor;
        grVendorAgreement: record "Vendor Agreement";
        OldAgreement: code[20];
        US: record "User Setup";
        TEXT0012: Label 'Operation is bound to document IW \ Amount available for transfer to 1st level = %1 \ Continue?';
        TEXT0013: Label 'Operation is bound to document IW \ Amount available for transfer to 1st level= %1 \ Transfer is not possible!';
        TEXT0004: Label 'You must set the Project Code!';
        TEXT0005: Label 'You must set CC!';
        TEXT0006: Label 'The amount of the transaction must be determined!';
        TEXT0007: Label 'Clear contract number!';
        TEXT001: Label 'The Contract Balance Amount has been exceeded!';
        TEXT0008: Label 'You must select the Cash Flow records from which you want to debit this amount.';
        TEXT0009: Label 'Canceled by user.';
        TEXT0010: Label 'Unlink payment from supplier and contract (move to level 1)?';
        TEXT0011: Label 'Operations cannot be deleted!';
        TEXT0014: Label 'You are not allowed to copy actual operations.';
        TEXT0015: Label 'You do not have sufficient rights to perform the action!';
        TEXT0990: Label 'Select distinct %1 Filter to create new line!';
        TEXT0991: Label 'Cost Place';
        TEXT0992: Label 'Cost Code';
        HideZeroAmountLine: boolean;
        PrjBudMgt: Codeunit "Project Budget Management";
        [InDataSet]
        LineEditable: Boolean;
        [InDataSet]
        ProjectEditable: Boolean;
        [InDataSet]
        CPEditable: Boolean;
        [InDataSet]
        CreateUIDEditable: Boolean;



    local procedure CheckAllowChanges()
    begin
        if not PrjBudMgt.AllowLTEntryChange() then
            Error(TEXT0015);
    end;

    local procedure setOverdueFlt()
    begin
        if Overdue then begin
            Rec.SetFilter(Date, '<%1', gDate);
            Rec.SetRange(Close, false);
        end else begin
            Rec.SetRange(Date);
            Rec.SetRange(Close);
        end;
        CurrPage.Update(false);
    end;

    local procedure BuildView();
    begin
        if HideZeroAmountLine then
            Rec.SetFilter("Without VAT (LCY)", '<>0')
        else
            Rec.SetRange("Without VAT (LCY)");
        CurrPage.UPDATE(FALSE);
    end;

    local procedure TemplateCodeOnAfterValidate()
    begin
        ValidateProject;

    end;

    procedure ValidateProject()
    var
        lDimVal: Record "Dimension Value";
    begin
        //NC 27251 HR beg
        // IF TemplateCode = '' THEN
        //   gcduERPC.TestBldProjectCode(TemplateCode, 70072);

        // IF grProjectsStructure.GET(TemplateCode,AnalysisType) THEN BEGIN
        //   gvAnalysisType:=grProjectsStructure.Type;
        //   TemplateDescription:=grProjectsStructure.Description;
        //   CalcType:=grProjectsStructure.Type+1;
        // END ELSE BEGIN
        //   TemplateDescription:='';
        //   CalcType:=0;
        // END;
        GLSetup.Get();
        GLSetup.TestField("Project Dimension Code");
        if lDimVal.Get(GLSetup."Project Dimension Code", TemplateCode) then
            TemplateDescription := lDimVal.Name;

        // //SETRANGE("Project Code");
        // //FILTERGROUP(2);
        Rec.SETFILTER("Project Code", TemplateCode);
        // //FILTERGROUP(0);


        IF Rec.FIND('-') THEN;
        CurrPage.UPDATE(FALSE);
        //NC 27251 HR end
    end;

    local procedure GetLineStyle(pPrBudEnt: Record "Projects Budget Entry")
    begin
        LineStyletxt := '';
        if (pPrBudEnt."Parent Entry" = 0) or (pPrBudEnt."Entry No." = pPrBudEnt."Parent Entry") then
            LineStyletxt := 'StandardAccent';
    end;

    local procedure GetLineEditable(pPBE: Record "Projects Budget Entry")
    begin
        LineEditable := true;
        CPEditable := true;
        ProjectEditable := true;
        CreateUIDEditable := PrjBudMgt.IsMasterCF();
        pPBE.CalcFields("Payment Doc. No.");
        if (pPBE."Payment Doc. No." <> '') and (pPBE."Entry No." <> pPBE."Parent Entry") then begin
            LineEditable := false;
            CPEditable := false;
            ProjectEditable := false;
        end;
        if (pPBE."Entry No." = pPBE."Parent Entry") then begin
            LineEditable := true;
            CPEditable := not PrjBudMgt.HaveSTEntries(pPBE);
            ProjectEditable := CPEditable;
        end;
    end;
}