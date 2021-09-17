report 70001 "Import Budget CC"
{
    ProcessingOnly = true;
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ToItemBudgetName; ToItemBudgetName)
                    {
                        Visible = false;
                        Caption = 'Budget Name';
                        ApplicationArea = All;
                    }
                    field(Description1; Description1)
                    {
                        Caption = 'Version Description';
                        ApplicationArea = All;
                        Visible = VersionDescVisible;
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            grPrjVesion: Record "Project Version";
                        begin

                            grPrjVesion.SETRANGE("Project Code", ToItemBudgetName);
                            grPrjVesion.SETFILTER("Version Code", '<>%1', 'WORK');
                            IF grPrjVesion.FIND('-') THEN BEGIN
                                IF Page.RUNMODAL(Page::"Projects Version", grPrjVesion) = ACTION::LookupOK THEN BEGIN
                                    VersionCode := grPrjVesion."Version Code";
                                    Description1 := grPrjVesion.Description;
                                END;
                            END;
                        end;
                    }
                    field(ImportOption; ImportOption)
                    {
                        Caption = 'Parametr';
                        ApplicationArea = All;
                        Visible = ParamVisible;
                    }
                    field(Description; Description)
                    {
                        Caption = 'Description';
                        ApplicationArea = All;
                    }
                    field(BuildTurn; BuildTurn)
                    {
                        Visible = false;
                        Caption = 'Build Turn';
                        ApplicationArea = All;
                    }
                    field(FirstLine; FirstLine)
                    {
                        Caption = 'Skip first line';
                        ApplicationArea = All;
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            Description := Text005 + FORMAT(WORKDATE) + ' ' + FORMAT(TIME);
            Description1 := '';
            ToItemBudgetName := gCode;
            VersionCode := '';

            ImportOption := 0;
            IF gType = 1 THEN BEGIN
                ParamVisible := FALSE;
                VersionDescVisible := TRUE;
                // //NC 30425, 28312 HR beg
                // IF NewXLSFormatForTargetBudget THEN BEGIN
                //     ImportType := ImportType::"Excel Template";
                //     RequestOptionsForm.cImport.EDITABLE := FALSE;
                //     RequestOptionsForm.SkipReadingFristLine.EDITABLE := FALSE;
                // END;
                // //NC 30425, 28312 HR end
            END ELSE BEGIN
                VersionDescVisible := FALSE;
                ParamVisible := TRUE;
            END;

            IF gType = 6 THEN BEGIN
                // ImportType := ImportType::"Excel Template";
                // RequestOptionsForm.cImport.EDITABLE := FALSE;

                ParamVisible := FALSE;
                VersionDescVisible := TRUE;
            END;
        end;
    }

    trigger OnPreReport()
    begin
        ImportType := ImportType::"excel template";
    end;

    trigger OnPostReport()
    var
        i: integer;
        EndOfLoop: integer;
        Found: boolean;
        xlsNomCode: code[35];
        xlsDate: date;
        xlsNomCodePrev: code[35];
        xlsQuantityTxt: text[30];
        lPCCE: record "Projects Cost Control Entry";
        grNewVersion: record "Project Version";
        CPCode: code[20];
        PostAmount: decimal;
        CostCode: code[20];
        CostPlace: code[20];
        // ProjectsStructureLines: record "Projects Structure Lines";
        // BT: record "Building turn";
        XLSDescr: text[250];
        xlsSumTxt: text[30];
        xlsSum: decimal;
        CostType: code[20];
        LineNo: integer;
        DimValue: record "Dimension Value";
    // ProjectsStructureLines2: record "Projects Structure Lines";
    // BuildingProjectLoc: record "Building project";
    begin
        Uploaded := UploadIntoStream(TextUp001, '', Excel2007FileType, FileName, InStr);
        if not Uploaded then
            exit;
        ExcelBuf.Reset();
        SheetName := ExcelBuf.SelectSheetsNameStream(InStr);
        ExcelBuf.OpenBookStream(InStr, SheetName);
        ExcelBuf.ReadSheet();

        IF gType = 1 THEN BEGIN
            IF VersionCode = '' THEN BEGIN
                gVer := grVer.GetNextVersion;
                grNewVersion."Version Code" := gVer;
                grNewVersion."Project Code" := ToItemBudgetName;
                grNewVersion.Description := Description1;
                grNewVersion.TESTFIELD(Description);
                grNewVersion.INSERT(TRUE);
                gVer := grNewVersion."Version Code";
            END ELSE
                gVer := VersionCode;
        END;
        Window.OPEN(TextImport);
        IF FirstLine THEN
            Var1 := 2
        ELSE
            Var1 := 1;

        IF ImportOption = ImportOption::"Replace entries" THEN BEGIN
            IF gType <> 1 THEN BEGIN
                lPCCE.SETRANGE("Project Code", ToItemBudgetName);
                lPCCE.SETRANGE("Analysis Type", gType);
                // IF BuildTurn <> '' THEN
                //     lPCCE.SETRANGE("Project Turn Code", BuildTurn);
                IF lPCCE.FINDSET THEN
                    lPCCE.DELETEALL(TRUE);
            END ELSE BEGIN
                IF VersionCode <> '' THEN BEGIN
                    lPCCE.SETRANGE("Project Code", ToItemBudgetName);
                    lPCCE.SETRANGE("Analysis Type", gType);
                    lPCCE.SETRANGE("Version Code", VersionCode);
                    // IF BuildTurn <> '' THEN
                    //     lPCCE.SETRANGE("Project Turn Code", BuildTurn);
                    IF lPCCE.FINDSET THEN
                        lPCCE.DELETEALL(TRUE);
                    //SWC274 SM 181114 >>
                    IF gType = lPCCE."Analysis Type"::"Current Budget".AsInteger() THEN BEGIN
                        lPCCE.SETRANGE("Analysis Type", lPCCE."Analysis Type"::Estimate);
                        IF lPCCE.FINDSET THEN
                            lPCCE.DELETEALL(TRUE);
                    END;
                    //SWC274 SM 181114 <<

                    //NC 30425, 28312 HR beg
                    IF
                    // NewXLSFormatForTargetBudget AND 
                    (gType = 1) THEN BEGIN
                        lPCCE.SETRANGE("Analysis Type", lPCCE."Analysis Type"::Forecast);
                        lPCCE.SETRANGE("Imported Form File", TRUE);
                        lPCCE.DELETEALL(TRUE);
                    END;
                    //NC 30425, 28312 HR end

                END;
            END;
        END;
        IF ImportType = ImportType::"Estimate Template" THEN begin


            ExcelBuf.reset;
            ExcelBuf.SetRange("Column No.", 7);
            ExcelBuf.SetFilter("Cell Value as Text", '<>%1', '');
            if ExcelBuf.FindLast() then begin
                Rows := ExcelBuf."Row No.";
                Var1 := ExcelBuf."Row No.";
            end;
        end
        ELSE BEGIN
            IF NewXLSFormatForTargetBudget THEN BEGIN
                Var1 := 3;
                Rows := Var1 - 1;
                ExcelBuf.reset;
                ExcelBuf.SetRange("Column No.", 4);
                ExcelBuf.SetFilter("Cell Value as Text", '<>%1', '');
                if ExcelBuf.FindLast() then begin
                    Rows := ExcelBuf."Row No." - 1;
                    Var1 := ExcelBuf."Row No.";
                end;
            END ELSE BEGIN
                ExcelBuf.reset;
                ExcelBuf.SetRange("Column No.", 1);
                ExcelBuf.SetFilter("Cell Value as Text", '<>%1', '');
                if ExcelBuf.FindLast() then begin
                    Rows := ExcelBuf."Row No.";
                    Var1 := ExcelBuf."Row No.";
                end;
            END;
        END;
        ExcelBuf.Reset;
        IF NewXLSFormatForTargetBudget THEN BEGIN
            Var1 := 3;

            CostTemp.RESET;
            CostTemp.DELETEALL;

        END ELSE BEGIN
            Var1 := 1;
            IF FirstLine THEN BEGIN
                Rows := Rows + 1;
                Var1 := 2;
            END;
            i := Rows;
        END;

        xlDataRowsCount := Rows - Var1;
        //NC 30425, 28312 HR end

        lPCCE.RESET;
        lPCCE.SETCURRENTKEY("Entry No.");
        IF lPCCE.FINDLAST THEN
            EntryNo := lPCCE."Entry No." + 1
        ELSE
            EntryNo := 1;

        // //SWC274 SM 011214 >>
        // IF ImportType=ImportType::"Estimate Template" THEN BEGIN
        //   SaveVar1 := Var1;
        //   FOR Var1:=Var1 TO Rows DO BEGIN
        //     xlsNomCode:=FORMAT(XlWorkSheet.Range('U'+FORMAT(Var1)+':'+'U'+FORMAT(Var1)).Value);
        //     xlsNomCodePrev:=DellNull(FORMAT(xlsNomCode));
        //     LineNo:= cduERPC.GetLineCode(ToItemBudgetName,xlsNomCodePrev,GetDefVersion1(ToItemBudgetName));
        //     xlsSumTxt:=FORMAT(XlWorkSheet.Range('S'+FORMAT(Var1)+':'+'S'+FORMAT(Var1)).Value);
        //     xlsQuantityTxt:=FORMAT(XlWorkSheet.Range('I'+FORMAT(Var1)+':'+'I'+FORMAT(Var1)).Value);
        //     EVALUATE(xlsQuantity,xlsQuantityTxt);
        //     EVALUATE(xlsSum,xlsSumTxt);
        //     xlsSum := ROUND(xlsSum * xlsQuantity,0.01);

        //     IF (LineNo =0) AND (xlsSum <> 0) AND (xlsNomCodePrev <> '') THEN
        //      IF STRPOS(ErrorTXT, xlsNomCodePrev) = 0 THEN
        //        ErrorTXT:=ErrorTXT+xlsNomCodePrev+'\';
        //   END;
        //   IF ErrorTXT <>'' THEN
        //    IF CONFIRM('Статьи\'+ErrorTXT+'\не существует в структуре бюджета '+ ToItemBudgetName +
        //               '\версии '+ gVer + '\Создать?') THEN
        //      CreateCC := TRUE;
        //   ErrorTXT:='';
        //   Var1 := SaveVar1;
        // END;
        // //SWC274 SM 011214 <<

        FOR Var1 := Var1 TO Rows DO BEGIN

            //   dd:=dd+1;
            //   RecNo := RecNo + 1;
            //   //IF dd=10 THEN ERROR('1111');
            //   IF ImportType=ImportType::"CMPro Template" THEN BEGIN
            //     xlsNomCode:=FORMAT(XlWorkSheet.Range('A'+FORMAT(Var1)+':'+'A'+FORMAT(Var1)).Value);
            //     xlsQuantityTxt:=FORMAT(XlWorkSheet.Range('C'+FORMAT(Var1)+':'+'C'+FORMAT(Var1)).Value);
            //     DescriptionEntry:=FORMAT(XlWorkSheet.Range('D'+FORMAT(Var1)+':'+'D'+FORMAT(Var1)).Value);
            //     XLSDescr:=DellNull1(FORMAT(XlWorkSheet.Range('B'+FORMAT(Var1)+':'+'B'+FORMAT(Var1)).Value));
            //     EVALUATE(xlsQuantity,xlsQuantityTxt);
            //     IF GetValue1(xlsNomCode,StageCode,DimCode,CPCode,XLSDescr) THEN BEGIN
            //       EntryNo := EntryNo + 1;
            //       CLEAR(lPCCE);
            //       lPCCE.INIT;
            //       lPCCE."Line No.":=cduERPC.GetLineCode(ToItemBudgetName,xlsNomCodePrev,GetDefVersion1(ToItemBudgetName));

            //       lPCCE."Entry No.":=EntryNo;
            //       lPCCE."Version Code":=gVer;
            //       lPCCE."Analysis Type":=gType;
            //       lPCCE."Project Code":=ToItemBudgetName;
            //       lPCCE.VALIDATE("Without VAT",xlsQuantity);
            //       IF DescriptionEntry = '' THEN
            //         lPCCE."Description 2":=Description
            //       ELSE
            //         lPCCE."Description 2":=DescriptionEntry;
            //       lPCCE."Shortcut Dimension 1 Code":=CPCode;
            //       lPCCE."Shortcut Dimension 2 Code":=xlsNomCodePrev;
            //       lPCCE.Date:=TODAY;
            //       lPCCE."Project Turn Code":=StageCode;
            //       lPCCE.Description :=
            //        cduERPC.GetLineDescription(ToItemBudgetName,xlsNomCodePrev,GetDefVersion1(ToItemBudgetName));
            //       lPCCE.Code:=cduERPC.GetLineNo(ToItemBudgetName,xlsNomCodePrev,GetDefVersion1(ToItemBudgetName));
            //       lPCCE."Cost Type":=GetCostType(xlsNomCode);
            //       IF (lPCCE."Line No."<>0) AND (lPCCE."Without VAT"<>0) THEN
            //         lPCCE.INSERT(TRUE)
            //       ELSE
            //         IF (lPCCE."Without VAT"<>0) THEN
            //           ErrorTXT:=ErrorTXT+xlsNomCodePrev+'\';
            //     END ELSE
            //       xlsNomCodePrev:=DellNull(FORMAT(xlsNomCode));

            //   END;

            IF ImportType = ImportType::"Excel Template" THEN BEGIN
                //NC 30425, 28312 HR beg   $$$$
                //xlsQuantity:=(XlWorkSheet.Range('C'+FORMAT(Var1)+':'+'C'+FORMAT(Var1)).Value);
                //DescriptionEntry:=FORMAT(XlWorkSheet.Range('D'+FORMAT(Var1)+':'+'D'+FORMAT(Var1)).Value);
                //CostCode:=FORMAT(XlWorkSheet.Range('A'+FORMAT(Var1)+':'+'A'+FORMAT(Var1)).Value);

                IF NewXLSFormatForTargetBudget THEN BEGIN
                    ReadXLLineOfTargetBudget(Var1, Buff);
                    xlsQuantity := Buff."Without VAT";
                    DescriptionEntry := Buff."Description 2";
                    CostPlace := Buff."Shortcut Dimension 1 Code";
                    CostCode := Buff."Shortcut Dimension 2 Code";
                    AmtInclVAT := Buff."Amount Including VAT 2";
                    VATAmt := Buff."VAT Amount 2";
                    VATprc := Buff."VAT %";
                    CostType := Buff."Cost Type";
                END ELSE BEGIN
                    if ExcelBuf.Get(Var1, 3) then
                        Evaluate(xlsQuantity, ExcelBuf."Cell Value as Text");
                    if ExcelBuf.Get(Var1, 4) then
                        DescriptionEntry := ExcelBuf."Cell Value as Text";
                    if ExcelBuf.Get(Var1, 1) then
                        CostCode := ExcelBuf."Cell Value as Text";
                    if ExcelBuf.Get(Var1, 12) then
                        CostPlace := ExcelBuf."Cell Value as Text";
                END;
                //NC 30425, 28312 HR beg

                IF gType = 6 THEN begin
                    if ExcelBuf.Get(Var1, 2) then
                        Evaluate(xlsDate, ExcelBuf."Cell Value as Text");
                end
                ELSE
                    xlsDate := TODAY;
                //todo check
                // ProjectsStructureLines.SETRANGE("Project Code", ToItemBudgetName);
                // ProjectsStructureLines.SETRANGE(Version, GetDefVersion1(ToItemBudgetName));
                // ProjectsStructureLines.SETRANGE(Code, CostCode);
                // IF ProjectsStructureLines.FINDFIRST THEN BEGIN
                //     IF ProjectsStructureLines."Structure Post Type" = ProjectsStructureLines."Structure Post Type"::Posting THEN BEGIN
                EntryNo := EntryNo + 1;
                CLEAR(lPCCE);
                lPCCE.INIT;
                //todo check
                // lPCCE."Line No." := ProjectsStructureLines."Line No.";

                lPCCE."Entry No." := EntryNo;
                lPCCE."Version Code" := gVer;
                lPCCE."Analysis Type" := Enum::"Analysis Type".FromInteger(gType);
                lPCCE."Project Code" := ToItemBudgetName;

                IF gType = 6 THEN
                    lPCCE.Date := xlsDate
                ELSE
                    lPCCE.Date := TODAY;

                lPCCE.VALIDATE("Without VAT", xlsQuantity);
                lPCCE."Description 2" := Description;

                IF DescriptionEntry = '' THEN
                    lPCCE."Description 2" := Description
                ELSE
                    lPCCE."Description 2" := DescriptionEntry;

                // BT.GET(BuildTurn);
                // lPCCE."Shortcut Dimension 1 Code" := BT."Turn Dimension Code";
                lPCCE."Shortcut Dimension 1 Code" := CostPlace;
                lPCCE."Shortcut Dimension 2 Code" := CostCode;
                // lPCCE."Project Turn Code" := BuildTurn;
                lPCCE.Description := Description;
                // lPCCE.Description := ProjectsStructureLines.Description;
                // lPCCE.Code := ProjectsStructureLines.Code;

                //NC 28312 HR beg
                //IF (lPCCE."Line No."<>0) AND (lPCCE."Without VAT"<>0) THEN
                //   lPCCE.INSERT(TRUE)
                //END;
                IF NewXLSFormatForTargetBudget THEN BEGIN
                    lPCCE.VALIDATE("Cost Type", CostType);
                    lPCCE."Amount 2" := lPCCE."Without VAT";
                    lPCCE."Amount Including VAT 2" := AmtInclVAT;
                    lPCCE."VAT Amount 2" := VATAmt;
                    lPCCE."VAT %" := VATprc;
                END;

                IF (lPCCE."Line No." <> 0) AND (lPCCE."Without VAT" <> 0) THEN BEGIN

                    lPCCE.INSERT(TRUE);
                    IF gType > 0 THEN BEGIN // NC 35213
                        EntryNo := EntryNo + 1;
                        lPCCE."Analysis Type" := lPCCE."Analysis Type"::Forecast;
                        lPCCE."Entry No." := EntryNo;
                        lPCCE."Imported Form File" := TRUE;
                        lPCCE.INSERT(TRUE);
                    END;     // NC 35213
                    xlAffectedRows += 1;

                END ELSE BEGIN
                    WriteLog(Var1, CostCode);
                END;
                //     END ELSE
                //         WriteLog(Var1, CostCode);
                //     //NC 28312, 28312 HR end

                // END ELSE BEGIN
                //     WriteLog(Var1, CostCode);
                // END;

            END;
            //SWC274 SM 121114 >>
            //   IF ImportType=ImportType::"Estimate Template" THEN BEGIN
            //    CLEAR(lPCCE);

            //    xlsNomCode:=FORMAT(XlWorkSheet.Range('U'+FORMAT(Var1)+':'+'U'+FORMAT(Var1)).Value);
            //    xlsQuantityTxt:=FORMAT(XlWorkSheet.Range('I'+FORMAT(Var1)+':'+'I'+FORMAT(Var1)).Value);
            //    xlsSumTxt:=FORMAT(XlWorkSheet.Range('S'+FORMAT(Var1)+':'+'S'+FORMAT(Var1)).Value);
            //    DescriptionEntry:=FORMAT(XlWorkSheet.Range('H'+FORMAT(Var1)+':'+'H'+FORMAT(Var1)).Value);
            //    EVALUATE(xlsQuantity,xlsQuantityTxt);
            //    EVALUATE(xlsSum,xlsSumTxt);
            //    xlsSum := ROUND(xlsSum * xlsQuantity,0.01);
            //    xlsNomCodePrev:=DellNull(FORMAT(xlsNomCode));
            //    CostType := FORMAT(XlWorkSheet.Range('K'+FORMAT(Var1)+':'+'K'+FORMAT(Var1)).Value);

            //    StageCode :=  FORMAT(XlWorkSheet.Range('W'+FORMAT(Var1)+':'+'W'+FORMAT(Var1)).Value);
            //    //SWC437 SM 180215 >>
            //    SubStageCode := FORMAT(XlWorkSheet.Range('Y'+FORMAT(Var1)+':'+'Y'+FORMAT(Var1)).Value);
            //    ELineNo := 0;
            //    ElineID := 0;
            //    IF EVALUATE(ELineNo, FORMAT(XlWorkSheet.Range('G'+FORMAT(Var1)+':'+'G'+FORMAT(Var1)).Value)) THEN;
            //    EUnitPrice:=0;
            //    IF EVALUATE(EUnitPrice, xlsSumTxt) THEN;
            //    EUM := FORMAT(XlWorkSheet.Range('J'+FORMAT(Var1)+':'+'J'+FORMAT(Var1)).Value);
            //    IF EVALUATE(ElineID, FORMAT(XlWorkSheet.Range('G'+FORMAT(Var1)+':'+'G'+FORMAT(Var1)).Value)) THEN;
            //    BuildingProjectLoc.GET(ToItemBudgetName);
            //    BuildingProjectLoc.CALCFIELDS("Building turn");
            //    //SWC437 SM 180215 <<
            //    IF (SubStageCode = '') OR (BuildingProjectLoc."Building turn" IN [0,1]) THEN
            //     CPCode := StageCode
            //    ELSE
            //     CPCode := StageCode + '-' + SubStageCode;

            //    IF NOT DimValue.GET('CP',CPCode) THEN
            //      ERROR(Text022,CPCode);

            //    LineNo:= cduERPC.GetLineCode(ToItemBudgetName,xlsNomCodePrev,GetDefVersion1(ToItemBudgetName));
            //    IF (LineNo = 0) AND (xlsSum <> 0) AND (xlsNomCodePrev <> '') AND CreateCC THEN
            //    BEGIN
            //     ProjectsStructureLines.RESET;
            //     ProjectsStructureLines.SETRANGE("Project Code",ToItemBudgetName);
            //     ProjectsStructureLines.SETRANGE(Version, GetDefVersion1(ToItemBudgetName));
            //     ProjectsStructureLines.SETFILTER(Code,'..%1',xlsNomCodePrev);
            //     IF ProjectsStructureLines.FINDLAST THEN
            //     BEGIN
            //      ProjectsStructureLines2.INIT;
            //      ProjectsStructureLines2 := ProjectsStructureLines;
            //      ProjectsStructureLines2.VALIDATE(Code, xlsNomCodePrev);
            //      ProjectsStructureLines2."Line No." := ProjectsStructureLines."Line No."+1;
            //      ProjectsStructureLines2."Structure Post Type":=ProjectsStructureLines2."Structure Post Type"::Posting;
            //      ProjectsStructureLines2.INSERT(TRUE);
            //      LineNo:= cduERPC.GetLineCode(ToItemBudgetName,xlsNomCodePrev,GetDefVersion1(ToItemBudgetName));
            //     END;
            //    END;

            //    IF (LineNo <>0) AND (xlsSum <> 0) THEN
            //    BEGIN
            //       EntryNo := EntryNo + 1;
            //       //Project Code,Analysis Type,Version Code,Line No.,Entry No.,Project Turn Code,Temp Line No.,Cost Type
            //       lPCCE.SETRANGE("Project Code",ToItemBudgetName);
            //       lPCCE.SETRANGE("Analysis Type",gType);
            //       lPCCE.SETRANGE("Version Code",gVer);
            //       lPCCE.SETRANGE("Line No.",LineNo);
            //       lPCCE.SETRANGE("Project Turn Code",StageCode);
            //       lPCCE.SETRANGE("Cost Type",CostType);
            //       lPCCE.SETRANGE("Shortcut Dimension 1 Code",CPCode);
            //       lPCCE.SETRANGE("Shortcut Dimension 2 Code",xlsNomCodePrev);
            //       IF lPCCE.FINDFIRST THEN
            //       BEGIN
            //         lPCCE.VALIDATE("Without VAT",lPCCE."Without VAT" + xlsSum);
            //         lPCCE.MODIFY(TRUE);

            //         EntryNo := EntryNo + 1;
            //         CreateEstimateEntry (lPCCE,xlsSum,CPCode);
            //       END
            //       ELSE BEGIN
            //         lPCCE.INIT;
            //         lPCCE."Line No.":= LineNo;
            //         lPCCE."Entry No.":=EntryNo;
            //         lPCCE."Version Code":=gVer;
            //         lPCCE."Analysis Type":=gType;
            //         lPCCE."Project Code":=ToItemBudgetName;
            //         lPCCE.VALIDATE("Without VAT",xlsSum);
            //         lPCCE.VALIDATE("Shortcut Dimension 2 Code",xlsNomCodePrev);
            //         lPCCE.Date:=TODAY;
            //         lPCCE."Project Turn Code":=StageCode;
            //         lPCCE.Description:=cduERPC.GetLineDescription(ToItemBudgetName,
            //                                       xlsNomCodePrev,GetDefVersion1(ToItemBudgetName));
            //         lPCCE.Code:=cduERPC.GetLineNo(ToItemBudgetName,xlsNomCodePrev,GetDefVersion1(ToItemBudgetName));
            //         lPCCE."Cost Type":=CostType;
            //         lPCCE."Description 2":=Description;
            //         //SWC854 KAE 050716 >>
            //         lPCCE.SetStructurePostTypeIsTotal(cduERPC.StructurePostTypeIsTotal(ToItemBudgetName,
            //                                                                                          xlsNomCodePrev,
            //                                                                                          GetDefVersion1(ToItemBudgetName)));
            //         //SWC854 KAE 050716 <<
            //         lPCCE.INSERT(TRUE);
            //         lPCCE.VALIDATE("Shortcut Dimension 1 Code",CPCode);
            //         lPCCE.MODIFY(TRUE);

            //         EntryNo +=1;
            //         CreateEstimateEntry (lPCCE,xlsSum,CPCode);
            //       END;
            //    END
            //    ELSE
            //      IF xlsSum <> 0 THEN
            //       IF STRPOS(ErrorTXT, xlsNomCodePrev) = 0 THEN
            //         ErrorTXT:=ErrorTXT+xlsNomCodePrev+'\';
            //   END;
            //  //SWC274 SM 121114 <<
            Window.UPDATE(1, ROUND(dd / i * 10000, 1));

        END;
        Window.Close();
        //NC 28312, 28312 HR beg
        IF ImportType = ImportType::"Excel Template" THEN BEGIN
            ShowLog;
        END;
        //NC 28312, 28312 HR end

        IF ErrorTXT <> '' THEN BEGIN
            MESSAGE('Статьи\' + ErrorTXT + 'Не существует!');
            ERROR('');
        END;




    End;

    var
        FileName: text[250];
        SheetName: text[250];
        ParamVisible: Boolean;
        VersionDescVisible: Boolean;
        Uploaded: Boolean;
        InStr: InStream;
        ExcelBuf: Record "Excel Buffer" temporary;
        TextUp001: Label 'Select file';
        Excel2007FileType: Label 'Excel Files (*.xlsx;*.xls)|*.xlsx;*.xls', Comment = '{Split=r''\|''}{Locked=s''1''}';
        TextImport: Label 'Import Data ...\@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        // Text000: Label 'You must specify a budget name to import to.';
        // Text001: Label 'Do you want to create %1 %2.';
        // Text002: Label '%1 %2 is blocked. You cannot import entries.';
        // Text003: Label 'Are you sure you want to %1 for %2 %3.';
        // Text004: Label '%1 table has been successfully updated with %2 entries.';
        Text005: Label 'Imported from Excel ';
        // Text006: Label 'Import Excel File';
        // Text007: Label 'Table Data';
        // Text008: Label 'Show as Lines';
        // Text009: Label 'Show as Columns';
        // Text010: Label 'Replace entries,Add entries';
        // Text011: Label 'The text %1 can only be specified once in the Excel worksheet.';
        // Text012: Label 'The filters specified by worksheet must be placed in the lines before the table.';
        // Text013: Label 'Date Filter';
        // Text014: Label 'Customer Filter';
        // Text015: Label 'Vendor Filter';
        // Text016: Label 'Analyzing Data...\\';
        // Text017: Label 'Item Filter';
        // Text018: Label '%1 is not a valid dimension value.';
        // Text019: Label '%1 is not a valid line definition.';
        // Text020: Label '%1 is not a valid column definition.';
        // Text021: Label 'You must specify a dimension value in row %1, column %2.';
        // Text022: Label 'Значение Измерения CP в таблице Измерение Значение, Код Номер %1 отсутствует\Загрузка отменена';
        Text023: Label 'Import Error: Cell (line %1, column %2) must contain a number.';
        // Text024: Label 'Загружено строк бюджета: %1 из %2 строк файла Excel.';
        // Text025: Label 'Некоторые строки не были загружены. Детальная информация в файле лога на экране.';
        ToItemBudgetName: code[10];
        RecNo: integer;
        EntryNo: integer;
        ImportOption: Option "replace entries","add entries";
        Description: text[250];
        gCode: code[20];
        FirstLine: boolean;
        Window: dialog;
        Var1: integer;
        Rows: integer;
        dd: integer;
        StageCode: code[20];
        DimCode: code[10];
        gType: integer;
        cduERPC: codeunit "ERPC Funtions";
        ErrorTXT: text[1000];
        gVer: code[20];
        grVer: record "Project Version";
        Description1: text[250];
        BuildTurn: code[20];
        gvBuildingTurn: record "Building turn";
        ImportType: Option "cmpro template","excel template","estimate template";
        DescriptionEntry: text[250];
        VersionCode: code[20];
        CreateCC: boolean;
        SaveVar1: integer;
        SubStageCode: code[20];
        ELineNo: integer;
        xlsQuantity: decimal;
        EUnitPrice: decimal;
        ElineID: integer;
        EUM: text[10];
        VATAmt: decimal;
        AmtInclVAT: decimal;
        VATprc: decimal;
        NewXLSFormatForTargetBudget: boolean;
        Buff: record "Projects Cost Control Entry" temporary;
        xlDataRowsCount: integer;
        xlAffectedRows: integer;
        CostTemp: record "Projects Article" temporary;

    procedure SetCode(pCode: code[20]; pVer: code[20])
    begin
        gCode := pCode;
        gVer := pVer;
    end;

    procedure SetImportType(pType: integer)
    begin
        gType := pType;
    end;

    procedure DellNull(pText: text[30]) Ret: text[30]
    var
        i: integer;
        txt: text[30];
        Buildingturn: record "Building turn";
        txt1: text[30];
    begin
        FOR i := 1 TO 10 DO BEGIN
            //SWC832 KAE 130516 >>
            //IF pText[i] IN ['0','1','2','3','4','5','6','7','8','9','-','F'] THEN
            IF pText[i] IN ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', 'A' .. 'Z', 'a' .. 'z'] THEN
            //SWC832 KAE 130516 <<
            BEGIN
                Ret := Ret + FORMAT(pText[i]);
            END;
        END;
    end;

    procedure UseNewXLSFormatForTargetBudget(NewVal: boolean)
    begin
        //NC 30425, 28312 HR beg
        NewXLSFormatForTargetBudget := NewVal;
        //NC 30425, 28312 HR end
    end;

    procedure ReadXLLineOfTargetBudget(xlRowNo: integer; var Out: record "Projects Cost Control Entry")
    begin
        //NC 30425, 28312 HR beg
        Out.INIT;
        if ExcelBuf.Get(xlRowNo, 9) then
            IF NOT EVALUATE(Out."Without VAT", ExcelBuf."Cell Value as Text") THEN
                ERROR(Text023, xlRowNo, 'I');

        if ExcelBuf.Get(xlRowNo, 3) then
            Out."Description 2" :=
              //NC 48183 > DP
              //  COPYSTR(XlWorkSheet.Range('C'+FORMAT(xlRowNo)+':'+'C'+FORMAT(xlRowNo)).Text, 1, MAXSTRLEN(Out."Description 2"));
              COPYSTR(ExcelBuf."Cell Value as Text", 1, MAXSTRLEN(Out."Description 2"));
        //NC 48183 < DP
        IF Out."Description 2" = '' THEN
            Out."Description 2" := Description;
        if ExcelBuf.Get(xlRowNo, 12) then
            Out."Shortcut Dimension 1 Code" := ExcelBuf."Cell Value as Text";
        if ExcelBuf.Get(xlRowNo, 4) then
            Out."Shortcut Dimension 2 Code" := ExcelBuf."Cell Value as Text";
        if ExcelBuf.Get(xlRowNo, 5) then
            Out."Cost Type" := ExcelBuf."Cell Value as Text";

        Out."Amount 2" := Out."Without VAT";
        if ExcelBuf.Get(xlRowNo, 11) then
            IF NOT EVALUATE(Out."Amount Including VAT 2", ExcelBuf."Cell Value as Text") THEN
                ERROR(Text023, xlRowNo, 'K');
        if ExcelBuf.Get(xlRowNo, 10) then
            IF NOT EVALUATE(Out."VAT Amount 2", ExcelBuf."Cell Value as Text") THEN
                ERROR(Text023, xlRowNo, 'J');

        IF Out."Amount 2" <> 0 THEN
            Out."VAT %" := ROUND(Out."VAT Amount 2" * 100 / Out."Amount 2", 1);
        //NC 30425, 28312 HR end
    end;

    procedure WriteLog(ExcelRowNoRef: integer; NewSkippedCostCodeValue: code[20])
    begin
        //NC 28312 HR beg
        CostTemp.Code := NewSkippedCostCodeValue;
        CostTemp.Sequence := ExcelRowNoRef;
        IF CostTemp.INSERT THEN;
        //NC 28312 HR end
    end;

    procedure ShowLog()
    var
        MsgText: text[1024];
        T: text[30];
    begin
        //NC 28312 HR beg
        CostTemp.RESET;
        IF NOT CostTemp.FINDSET THEN
            EXIT;

        MsgText := 'Не загружены Статьи бюджета: ';
        REPEAT
            T := STRSUBSTNO('%1 (%2), ', CostTemp.Code, CostTemp.Sequence);
            IF STRLEN(MsgText + T) <= MAXSTRLEN(MsgText) THEN
                MsgText := MsgText + T;
        UNTIL CostTemp.NEXT = 0;

        MsgText := DELSTR(MsgText, STRLEN(MsgText) - 1, 2);

        MESSAGE(MsgText);
        //NC 28312 HR end
    end;

    procedure ExistCreatedCC(): boolean
    begin
        EXIT(CreateCC); //SWC274 SM 011214
    end;
}