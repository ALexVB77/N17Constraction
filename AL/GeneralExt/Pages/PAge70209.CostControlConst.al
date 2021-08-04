page 70209 "Cost Control Construction"
{
    SaveValues = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Dimension Value";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Cost Control Construction';
    Editable = true;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Options';
                field(TemplateCode; TemplateCode)
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    trigger OnLookup(var Text: text): boolean
                    var
                        lDimVal: Record "Dimension Value";
                    begin
                        lDimVal.reset;
                        lDimVal.SetRange("Dimension Code", GLSetup."Project Dimension Code");
                        // lDimVal.SetRange("Project Code", TemplateCode);
                        IF lDimVal.FINDFIRST THEN BEGIN
                            IF PAGE.RUNMODAL(PAGE::"Dimension Values", lDimVal) = ACTION::LookupOK THEN BEGIN
                                TemplateCode := lDimVal.Code;
                                TemplateDescription := lDimVal.Name;
                            END;
                        END;
                    end;
                }
                field(TemplateDescription; TemplateDescription)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
                field(VersionDescription; VersionDescription)
                {
                    Editable = false;
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        grPrjVesion.FILTERGROUP := 2;
                        grPrjVesion.SETRANGE("Project Code", TemplateCode);
                        // grPrjVesion.SETRANGE("Analysis Type",grProjectsStructure.Type);
                        grPrjVesion.FILTERGROUP := 0;
                        IF grPrjVesion.FIND('-') THEN BEGIN
                            grPrjVesion.GET(Rec."Project Code", VersionCode);
                            IF PAGE.RUNMODAL(PAGE::"Projects Version", grPrjVesion) = ACTION::LookupOK THEN BEGIN
                                VersionCode := grPrjVesion."Version Code";
                                Rec.FILTERGROUP := 2;
                                Rec.SETRANGE("Project Code", TemplateCode);
                                Rec.FILTERGROUP := 0;
                                IF Rec.FIND('-') THEN;
                                grPrjVesion.GET(TemplateCode, VersionCode);
                                VersionDescription := grPrjVesion.Description;
                                CurrPage.UPDATE(FALSE);
                            END;
                        END;
                    end;
                }
                field(FrcVersionDescription; FrcVersionDescription)
                {
                    Editable = false;
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        grFrcPrjVesion.FILTERGROUP := 2;
                        grFrcPrjVesion.SETRANGE("Project Code", TemplateCode);
                        grFrcPrjVesion.FILTERGROUP := 0;
                        IF grFrcPrjVesion.FIND('-') THEN BEGIN
                            grFrcPrjVesion.GET(Rec."Project Code", FrcVersionCode);
                            IF PAGE.RUNMODAL(PAGE::"Forecast Versions", grFrcPrjVesion) = ACTION::LookupOK THEN BEGIN
                                FrcVersionCode := grFrcPrjVesion."Version Code";
                                Rec.FILTERGROUP := 2;
                                Rec.SETRANGE("Project Code", TemplateCode);
                                Rec.FILTERGROUP := 0;
                                IF Rec.FIND('-') THEN;
                                grFrcPrjVesion1.GET(TemplateCode, FrcVersionCode);
                                FrcVersionDescription := grFrcPrjVesion1.Description;
                                CurrPage.UPDATE(FALSE);
                            END;
                        END;
                    end;
                }
                field(CostPlaceFlt; CostPlaceFlt)
                {
                    ApplicationArea = All;
                    Caption = 'Cost Place filter';
                    trigger OnLookup(var Text: text): boolean
                    var
                        lDimVal: Record "Dimension Value";
                    begin
                        lDimVal.reset;
                        lDimVal.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                        lDimVal.SetRange("Project Code", TemplateCode);
                        IF lDimVal.FINDFIRST THEN BEGIN
                            IF PAGE.RUNMODAL(PAGE::"Dimension Values", lDimVal) = ACTION::LookupOK THEN BEGIN
                                CostPlaceFlt := lDimVal.Code;
                            END;
                        END;
                    end;
                }
                field(CostCodeFlt; CostCodeFlt)
                {
                    ApplicationArea = All;
                    Caption = 'Cost Code filter';
                    trigger OnLookup(var Text: text): boolean
                    var
                        lDimVal: Record "Dimension Value";
                    begin
                        lDimVal.reset;
                        lDimVal.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                        IF lDimVal.FINDFIRST THEN BEGIN
                            IF PAGE.RUNMODAL(PAGE::"Dimension Values", lDimVal) = ACTION::LookupOK THEN BEGIN
                                CostCodeFlt := lDimVal.Code;
                            END;
                        END;
                    end;
                }
                field(HideNullAmounts; HideNullAmounts)
                {
                    ApplicationArea = All;
                    Caption = 'Hide Zero Amounts';
                }
            }
            repeater(repeat1)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ForecastNav)
            {
                Caption = 'Forecast';
                action(FrcPrev)
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = PreviousRecord;
                    trigger OnAction()
                    begin
                        grFrcPrjVesion.SETRANGE("Project Code", TemplateCode);
                        IF grFrcPrjVesion.FIND('-') THEN BEGIN
                            grFrcPrjVesion.GET(TemplateCode, FrcVersionCode);
                            IF grFrcPrjVesion.NEXT(-1) <> 0 THEN BEGIN
                                Rec.FILTERGROUP := 2;
                                Rec.SETRANGE("Project Code", TemplateCode);
                                FrcVersionCode := grFrcPrjVesion."Version Code";
                                grFrcPrjVesion1.GET(TemplateCode, FrcVersionCode);
                                FrcVersionDescription := grFrcPrjVesion1.Description;
                                Rec.FILTERGROUP := 0;
                            END;
                        END;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
                action(FrcNext)
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = NextRecord;
                    trigger OnAction()
                    begin
                        grFrcPrjVesion.SETRANGE("Project Code", TemplateCode);
                        IF grFrcPrjVesion.FIND('-') THEN BEGIN
                            grFrcPrjVesion.GET(TemplateCode, FrcVersionCode);
                            IF grFrcPrjVesion.NEXT(1) <> 0 THEN BEGIN
                                Rec.FILTERGROUP := 2;
                                Rec.SETRANGE("Project Code", TemplateCode);
                                FrcVersionCode := grFrcPrjVesion."Version Code";
                                grFrcPrjVesion1.GET(TemplateCode, FrcVersionCode);
                                FrcVersionDescription := grFrcPrjVesion1.Description;
                                Rec.FILTERGROUP := 0;
                            END;
                        END;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
            }
            group(PrjVersion)
            {
                Caption = 'Budget';
                action(PrjVerPrev)
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = PreviousSet;
                    trigger OnAction()
                    begin
                        grPrjVesionNav.SETRANGE("Project Code", TemplateCode);
                        IF grPrjVesionNav.FIND('-') THEN BEGIN
                            grPrjVesionNav.GET(TemplateCode, VersionCode);
                            IF grPrjVesionNav.NEXT(-1) <> 0 THEN BEGIN
                                Rec.FILTERGROUP := 2;
                                Rec.SETRANGE("Project Code", TemplateCode);
                                VersionCode := grPrjVesionNav."Version Code";
                                grPrjVesion.GET(TemplateCode, VersionCode);
                                VersionDescription := grPrjVesion.Description;

                                Rec.FILTERGROUP := 0;
                            END;
                        END;
                    end;
                }
                action(PrjVerNext)
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = NextSet;
                    trigger OnAction()
                    begin
                        grPrjVesionNav.SETRANGE("Project Code", TemplateCode);
                        IF grPrjVesionNav.FIND('-') THEN BEGIN
                            grPrjVesionNav.GET(TemplateCode, VersionCode);
                            IF grPrjVesionNav.NEXT <> 0 THEN BEGIN
                                Rec.FILTERGROUP := 2;
                                Rec.SETRANGE("Project Code", TemplateCode);
                                VersionCode := grPrjVesionNav."Version Code";
                                grPrjVesion.GET(TemplateCode, VersionCode);
                                VersionDescription := grPrjVesion.Description;
                                Rec.FILTERGROUP := 0;
                            END;
                        END;
                    end;
                }
            }
            group(Functions)
            {
                action(FixForecast)
                {
                    ApplicationArea = All;
                    Image = Forecast;
                    trigger OnAction()
                    begin
                        CLEAR(FixForecast);
                        FixForecast.SetProject(TemplateCode);
                        FixForecast.RUNMODAL;
                        FrcVersionCode := GetDefFrcVersion(TemplateCode);
                        IF grFrcPrjVesion.GET(TemplateCode, FrcVersionCode) THEN
                            FrcVersionDescription := grFrcPrjVesion.Description;
                    end;
                }
                action(RefreshCommited)
                {
                    ApplicationArea = All;
                    Image = RefreshPlanningLine;
                    trigger OnAction()
                    var
                        lERPC: Codeunit "ERPC Funtions";
                    begin
                        lERPC.FiltersForCommitted(TemplateCode, CostPlaceFlt, CostTypeFlt);
                        MESSAGE('Done!');
                    end;
                }
            }
            group(Data)
            {
                action(LoadTargetBudget)
                {
                    ApplicationArea = All;
                    Image = ImportExcel;
                    trigger OnAction()
                    begin

                        CLEAR(ImportBudgetCC);
                        ImportBudgetCC.UseNewXLSFormatForTargetBudget(TRUE);
                        ImportBudgetCC.SetImportType(1);
                        ImportBudgetCC.SetCode(TemplateCode, VersionCode);
                        ImportBudgetCC.RUNMODAL;
                        VersionCode := GetDefVersion(TemplateCode);
                        grPrjVesion.GET(TemplateCode, VersionCode);
                        VersionDescription := grPrjVesion.Description;
                        // probably not use
                        // IF ImportBudgetCC.ExistCreatedCC THEN
                        //     FillData;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
                action(LoadForecast)
                {
                    ApplicationArea = All;
                    Image = ImportExcel;
                    trigger OnAction()
                    begin
                        r70095.SETRANGE("Project Code", TemplateCode);
                        r70095.SETRANGE("Analysis Type", r70095."Analysis Type"::Forecast);
                        IF r70095.FINDFIRST THEN BEGIN
                            UserSetup.GET(USERID);
                            IF NOT UserSetup."Administrator PRJ" THEN
                                ERROR(TEXT003)
                            ELSE BEGIN
                                IF NOT CONFIRM(TEXT004) THEN ERROR('');
                            END;
                        END;
                        CLEAR(ImportBudgetCC);
                        ImportBudgetCC.SetImportType(4);
                        ImportBudgetCC.SetCode(TemplateCode, GetDefVersion(TemplateCode));
                        ImportBudgetCC.RUNMODAL;
                    end;
                }
                action(RefreshActualsJournal)
                {
                    ApplicationArea = All;
                    Image = RefreshLines;
                    trigger OnAction()
                    begin

                        grBudgetCorrectionJournal.SETRANGE("Project Code", TemplateCode);
                        IF grBudgetCorrectionJournal.FINDFIRST THEN;
                        //grBudgetCorrectionJournal.FILTERGROUP:=2;

                        CLEAR(BudgetCorrectionJournal);
                        BudgetCorrectionJournal.SETRECORD(grBudgetCorrectionJournal);
                        BudgetCorrectionJournal.SETTABLEVIEW(grBudgetCorrectionJournal);
                        BudgetCorrectionJournal.RUNMODAL;

                    end;
                }
            }
        }
    }

    var
        GLSetup: record "General Ledger Setup";
        TemplateName: code[10];
        LineDimOption: Option structure,period,"global dimension 1","global dimension 2";
        ColumnDimOption: Option structure,period,"global dimension 1","global dimension 2";
        LineDimCode: text[30];
        HideNullAmounts: Boolean;
        ColumnDimCode: text[30];
        PeriodType: Option day,week,month,quarter,year,"accounting period";
        RoundingFactor: Option none,"1","1000","1000000";
        ShowColumnName: boolean;
        StructAmount: decimal;
        DateFilter: text[30];
        InternalDateFilter: text[30];
        PeriodInitialized: boolean;
        InputError: boolean;
        InputErrorText: text[250];
        NormalFormatString: text[80];
        // StructLine: record "Projects Structure Lines";
        // ProjectStructure: record "Projects Structure";
        TemplateCode: code[20];
        TemplateDescription: text[250];
        AnalysisType: Option inv,det,est;
        // grProjectsStructure: record "Projects Structure";
        JT: record "Projects Structure Lines";
        DevSetup: record "Projects Structure";
        CalcType: Option "0","1","2","3";
        VersionCode: code[20];
        grPrjVesion: record "Project Version";
        // grPrjStructure: record "Projects Structure";
        gvAnalysisType: integer;
        grPrjVesionNav: record "Project Version";
        // ProjectsStructureLines: record "Projects Structure Lines";
        // ProjectStructureList: page "Project Structure List";
        VersionDescription: text[250];
        OldLineNo: integer;
        ActualExpansionStatus1: integer;
        ActualExpansionStatus2: integer;
        ImportBudgetCC: report "Import Budget CC";
        OriginalBudget: decimal;
        UserSetup: record "User Setup";
        CurrentBudget: decimal;
        r70095: record "Projects Cost Control Entry";
        // gfTurnStructureAnalisys: page "Cost Control Detail Constr";
        gForecast: decimal;
        BoundCosts: decimal;
        gActuals: decimal;
        CostPlaceFlt: code[1024];
        CostCodeFlt: Code[1024];
        CostTypeFlt: code[20];
        // gvBuildingTurn: record "Building turn";
        GLS: record "General Ledger Setup";
        DimensionValue: record "Dimension Value";

        BudgetCorrectionJournal: page "Budget Cor. Journal Constr";
        grBudgetCorrectionJournal: record "Budget Correction Journal";
        gYTB: decimal;
        OpenAdvances: decimal;
        rDate: record Date;

        gForecastPrev: decimal;
        gForecastVariance: decimal;
        СurrentBudgetForecast: decimal;
        ForecastActual: decimal;
        CurrentBudgetActual: decimal;
        // ClosePeriod: report "Close Period";
        PeriodName: text[30];
        Period: date;
        // ProjectPerionClose: record "Project Perion Close";
        StartDate: date;
        EndDatePer: date;
        ExportReport: boolean;
        FixForecast: report "Fix Forecast";
        FrcVersionCode: code[20];
        FrcVersionDescription: text[250];
        grFrcPrjVesion: record "Forecast Version";
        grFrcPrjVesion1: record "Forecast Version";
        // Buildingproject: record "Building project";
        US: record "User Setup";
        CI: record "Company Information";

        ProjectsCostControlEntry: record "Projects Cost Control Entry";
        VendorAgreementDetails: record "Vendor Agreement Details";
        gCommited: decimal;
        gcduERPC: codeunit "ERPC Funtions";
        BC: decimal;
        actualscommited: decimal;
        actualsforecast: decimal;
        gActualsIFRS: decimal;
        BoundCostsOrd: decimal;
        OriginalBudgetCalculated: decimal;
        CurrentBudgetCalculated: decimal;
        LnAmt: array[30] of decimal;
        LnAmtEnum: Option " ",origbudgetvat,origbudgetinclvat,currbudgetvat,currbudgetinclvat,actualvat,actualinclvat,forecastvat,forecastinclvat,commitedvat,commitedinclvat,comittedforecastrate,actualforecastrate,orderedvat,orderedinclvat,currbudgetexclvat,"forecast-actuals","currbudget-forecast","currbudget-actuals",pforecastvat,pforecastinclvat,forecastvar,"commited-forecast";
        DBGText: text[30];
        // TEXT001: Label 'Original Budget может изменить только Администратор!';
        // TEXT002: Label 'Original Budget будет изменен! Продолжить?';
        TEXT003: Label 'Only Administrator can change Forecast!';
        TEXT004: Label 'Forecast Budget will be changed! Proceed?';
    // TEXT005: Label 'Cash Flow может изменить только Администратор!';
    // TEXT006: Label 'Cash Flow Budget будет изменен! Продолжить?';
    // Text012: Label '<Precision,';
    // Text013: Label '><Standard Format,0>';
    // CFCheck: decimal;
    // TEXT0014: Label 'Фиксировать прогноз?';
    // TEXT0015: Label 'Недоступно для данного типа компании!';
    procedure GetDefFrcVersion(pProjectCode: code[20]) Ret: code[20]
    var
        lrProjectVersion: record "Forecast Version";
    begin
        lrProjectVersion.SETCURRENTKEY(Int);
        lrProjectVersion.SETRANGE("Project Code", pProjectCode);
        IF lrProjectVersion.FINDLAST THEN
            Ret := lrProjectVersion."Version Code";
    end;

    procedure GetDefVersion(pProjectCode: code[20]) Ret: code[20]
    var
        lrProjectVersion: record "Project Version";
    begin
        lrProjectVersion.SETCURRENTKEY(Int);
        lrProjectVersion.SETRANGE("Project Code", pProjectCode);
        //lrProjectVersion.SETRANGE("Fixed Version",TRUE);
        IF lrProjectVersion.FINDLAST THEN
            Ret := lrProjectVersion."Version Code"
        ELSE BEGIN
            lrProjectVersion.SETRANGE("Project Code", pProjectCode);
            lrProjectVersion.SETRANGE("Fixed Version");
            lrProjectVersion.SETRANGE("First Version", TRUE);
            IF lrProjectVersion.FIND('-') THEN
                Ret := lrProjectVersion."Version Code";
        END;
    end;

    procedure FillData()
    begin
        Message('p70209.Filldata');
    end;
}