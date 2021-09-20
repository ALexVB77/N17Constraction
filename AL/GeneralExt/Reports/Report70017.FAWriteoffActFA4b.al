report 70017 "FA Write-off Act FA-4b"
{
    Caption = 'FA Write-off Act FA-4b';
    ProcessingOnly = true;

    dataset
    {
        dataitem("FA Document Header"; "FA Document Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const("Writeoff"));
            dataitem("FA Document Line"; "FA Document Line")
            {
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                DataItemLinkReference = "FA Document Header";
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                dataitem("ItemFA Precious Metal Unposted"; "Item/FA Precious Metal")
                {
                    DataItemTableView = sorting("Item Type", "No.", "Precious Metals Code") where("Item Type" = const("FA"));
                    DataItemLinkReference = "FA Document Line";
                    DataItemLink = "No." = field("FA No.");
                    CalcFields = Name;

                    trigger OnAfterGetRecord()
                    begin
                        AppendString(PrecMetalNames, Name);
                        AppendString(PrecMetalNos, "Nomenclature No.");
                        AppendString(PrecMetalUnitOfMeasureCodes, "Unit of Measure Code");
                        AppendString(PrecMetalQtys, Format(Quantity));
                        AppendString(PrecMetalMasses, Format(Mass));
                    end;
                }
                dataitem("Item Document Line"; "Item Document Line")
                {
                    DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const("Receipt"));
                    DataItemLinkReference = "FA Document Line";
                    DataItemLink = "Document No." = field("Item Receipt No.");
                    trigger OnPreDataItem()
                    begin
                        SetSheet(2);
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        SetConclusionLine("Item Document Line");
                    end;
                }
                trigger OnPreDataItem()
                begin
                    TotalAmount := 0;
                    ConcTotalAmount := 0;
                    LineNo := 0;
                end;

                trigger OnAfterGetRecord()
                begin
                    Clear(PrecMetalNames);
                    Clear(PrecMetalMasses);
                    Clear(PrecMetalNos);
                    Clear(PrecMetalQtys);
                    Clear(PrecMetalUnitOfMeasureCodes);

                    SetLine("FA Document Line");
                end;

                trigger OnPostDataItem()
                begin
                    SetFooter();
                end;
            }
            trigger OnPreDataItem()
            begin
                if "FA Document Header".GetFilters = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                SetHeader("FA Location Code", "FA Employee No.", "FA Posting Date", "Posting Date", "No.");
                SetConclusionHeader("FA Document Header");

                ItemLedgEntry.Reset();
                ItemLedgEntry.SetCurrentKey("Document No.", "Posting Date");
                ItemLedgEntry.SetRange("Document No.", "No.");
            end;
        }
        dataitem("Posted FA Doc. Header"; "Posted FA Doc. Header")
        {
            DataItemTableView = sorting("Document Type", "No.");
            dataitem("Posted FA Doc. Line"; "Posted FA Doc. Line")
            {
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                DataItemLinkReference = "Posted FA Doc. Header";
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                dataitem("ItemFA Precious Metal Posted"; "Item/FA Precious Metal")
                {
                    DataItemTableView = sorting("Item Type", "No.", "Precious Metals Code") where("Item Type" = const("FA"));
                    DataItemLinkReference = "Posted FA Doc. Line";
                    DataItemLink = "No." = field("FA No.");
                }
                dataitem("Item Receipt Line"; "Item Receipt Line")
                {
                    DataItemTableView = sorting("Document No.", "Line No.");
                    DataItemLinkReference = "Posted FA Doc. Line";
                    DataItemLink = "Document No." = field("Item Receipt No.");
                    trigger OnPreDataItem()
                    begin
                        SetSheet(2);
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        SetConclusionLine("Item Receipt Line");
                    end;
                }
                trigger OnPreDataItem()
                begin
                    TotalAmount := 0;
                    ConcTotalAmount := 0;
                    LineNo := 0;
                end;

                trigger OnAfterGetRecord()
                begin
                    SetLine("Posted FA Doc. Line");
                end;

                trigger OnPostDataItem()
                begin
                    SetFooter();
                end;
            }
            trigger OnPreDataItem()
            begin
                if "Posted FA Doc. Header".GetFilters() = '' then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                SetHeader("FA Location Code", "FA Employee No.", "FA Posting Date", "Posting Date", "No.");
                SetConclusionHeader("Posted FA Doc. Header");

                ItemLedgEntry.Reset();
                ItemLedgEntry.SetCurrentKey("Document No.", "Posting Date");
                ItemLedgEntry.SetRange("Document No.", "No.");
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    ShowCaption = false;
                    field("Depreciation Group"; DepricationGroup)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Depreciation Group Code';
                        TableRelation = "Depreciation Group";
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    var
        Employee: Record Employee;
    begin
        CompanyInfo.Get();
        FASetup.Get();
        if Employee.Get(CompanyInfo."Director No.") then
            DirectorPosition := Employee.GetJobTitleName();
    end;

    trigger OnPreReport()
    begin
        InitReportTemplate();
    end;

    trigger OnPostReport()
    begin
        if FileName = '' then
            ExcelReportBuilderManager.ExportData
        else
            ExcelReportBuilderManager.ExportDataToClientFile(FileName);
    end;

    var
        CompanyInfo: Record "Company Information";
        FASetup: Record "FA Setup";
        ItemLedgEntry: Record "Item Ledger Entry";
        ExcelReportBuilderManager: Codeunit "Excel Report Builder Manager";
        LocMgt: Codeunit "Localisation Management";
        StdRepMgt: Codeunit "Local Report Management";
        Conclusion: array[5] of Text[80];
        Appendix: array[5] of Text[80];
        Result: array[5] of Text[80];
        DepricationGroup: Code[10];
        FactYears: Text[30];
        DirectorPosition: Text[80];
        FileName: Text;
        TotalAmount: Decimal;
        ConcTotalAmount: Decimal;
        ProceedsFromDispAmount: Decimal;
        LineNo: Integer;
        IsHeaderPrinted: Boolean;
        PrecMetalNames: Text;
        PrecMetalNos: Text;
        PrecMetalUnitOfMeasureCodes: Text;
        PrecMetalQtys: Text;
        PrecMetalMasses: Text;

    local procedure InitReportTemplate()
    begin
        FASetup.TestField("FA-4b Template Code");
        ExcelReportBuilderManager.InitTemplate(FASetup."FA-4b Template Code");
    end;

    local procedure SetSheet(SheetNumber: Integer)
    begin
        case SheetNumber of
            1:
                ExcelReportBuilderManager.SetSheet('Sheet1');
            2:
                ExcelReportBuilderManager.SetSheet('Sheet2');
        end;
    end;

    local procedure TryAddBodySection()
    begin
        if not ExcelReportBuilderManager.TryAddSection('STATEBODY') then begin
            ExcelReportBuilderManager.AddPagebreak;
            ExcelReportBuilderManager.AddSection('STATEPAGEHEADER');
            ExcelReportBuilderManager.AddSection('STATEBODY');
        end;
    end;

    local procedure SetHeader(FALocationCode: Code[10]; FAEmployeeNo: Code[20]; FaPostingDate: Date; PostingDate: Date; No: Code[20])
    var
        CompanyAddress: Record "Company Address";
        FALocation: Record "FA Location";
        CompanyName: Text;
        DepartamentName: Text;
    begin
        SetSheet(1);

        CompanyAddress.Reset();
        CompanyAddress.SetRange("Address Type", CompanyAddress."Address Type"::Legal);
        if CompanyAddress.FindFirst() then
            CompanyName := StrSubstNo('%1 %2', CompanyAddress.Name, CompanyAddress."Name 2")
        else
            CompanyName := StdRepMgt.GetCompanyName;

        if FALocation.GET(FALocationCode) then
            DepartamentName := FALocation.Name;
        if DepartamentName = '' then
            DepartamentName := StdRepMgt.GetEmpDepartment(FAEmployeeNo);

        FillHeader(CompanyName, DepartamentName, StdRepMgt.GetEmpName(FAEmployeeNo),
            FAEmployeeNo, Format(FaPostingDate), DirectorPosition, No, Format(PostingDate),
            Format(PostingDate, 2, '<Day>'), LocMgt.Month2Text(PostingDate), Format(PostingDate, 2, '<Year>'));
    end;

    local procedure FillHeader(CompanyName: Text; DepartamentName: Text; FAEmployeeName: Text; FAEmployeeNo: Text; FAPostingDate: Text; DirectorPosition: Text; DocNo: Text; DocDate: Text; DocDateDay: Text; DocDateMonth: Text; DocDateYear: Text)

    begin
        CompanyInfo.Get();

        ExcelReportBuilderManager.AddSection('REPORTHEADER');
        ExcelReportBuilderManager.AddDataToSection('CompanyName', CompanyName);
        ExcelReportBuilderManager.AddDataToSection('CodeOKPO', CompanyInfo."OKPO Code");
        ExcelReportBuilderManager.AddDataToSection('DepartamentName', DepartamentName);
        ExcelReportBuilderManager.AddDataToSection('ResponsibleEmployeeName', FAEmployeeName);
        ExcelReportBuilderManager.AddDataToSection('ResponsibleEmployeeNo', FAEmployeeNo);
        ExcelReportBuilderManager.AddDataToSection('FromBusinessAccount', FAPostingDate);
        ExcelReportBuilderManager.AddDataToSection('ChiefName', CompanyInfo."Director Name");
        ExcelReportBuilderManager.AddDataToSection('ChiefPost', DirectorPosition);
        ExcelReportBuilderManager.AddDataToSection('ActNumber', DocNo);
        ExcelReportBuilderManager.AddDataToSection('ActDate', DocDate);
        ExcelReportBuilderManager.AddDataToSection('PostingDateDay', DocDateDay);
        ExcelReportBuilderManager.AddDataToSection('PostingDateMonth', DocDateMonth);
        ExcelReportBuilderManager.AddDataToSection('PostingDateYear', DocDateYear);

        ExcelReportBuilderManager.AddSection('STATEPAGEHEADER');
    end;

    local procedure SetConclusionHeader(FADocHeader: Record "FA Document Header")
    var
        FAComment: Record "FA Comment";
        Chairman: Record "Document Signature";
        Member1: Record "Document Signature";
        Member2: Record "Document Signature";
    begin
        SetSheet(2);
        CheckSignature(Chairman, Chairman."Employee Type"::Chairman);
        CheckSignature(Member1, Member1."Employee Type"::Member1);
        CheckSignature(Member2, Member2."Employee Type"::Member2);

        FADocHeader.GetFAComments(Conclusion, FAComment.Type::Conclusion);
        FADocHeader.GetFAComments(Appendix, FAComment.Type::Appendix);
        FADocHeader.GetFAComments(Result, FAComment.Type::Result);

        FillConclusionHeader(Conclusion[1], Conclusion[2], Appendix[1],
            Chairman."Employee Job Title", Chairman."Employee Name",
            Member1."Employee Job Title", Member1."Employee Name",
            Member2."Employee Job Title", Member2."Employee Name")
    end;

    local procedure SetConclusionHeader(PostedFADocHeader: Record "Posted FA Doc. Header")
    var
        FAComment: Record "FA Comment";
        Chairman: Record "Posted Document Signature";
        Member1: Record "Posted Document Signature";
        Member2: Record "Posted Document Signature";
    begin
        SetSheet(2);
        CheckSignature(Chairman, Chairman."Employee Type"::Chairman);
        CheckSignature(Member1, Member1."Employee Type"::Member1);
        CheckSignature(Member2, Member2."Employee Type"::Member2);

        PostedFADocHeader.GetFAComments(Conclusion, FAComment.Type::Conclusion);
        PostedFADocHeader.GetFAComments(Appendix, FAComment.Type::Appendix);
        PostedFADocHeader.GetFAComments(Result, FAComment.Type::Result);

        FillConclusionHeader(Conclusion[1], Conclusion[2], Appendix[1],
            Chairman."Employee Job Title", Chairman."Employee Name",
            Member1."Employee Job Title", Member1."Employee Name",
            Member2."Employee Job Title", Member2."Employee Name")
    end;

    local procedure FillConclusionHeader(Conclusion1: Text; Conclusion2: Text; Appendix: Text; Chairman: Text; ChairmanName: Text; Member1: Text; Member1Name: Text; Member2: Text; Member2Name: Text)
    begin
        ExcelReportBuilderManager.AddSection('CONCLUSIONHEADER');
        ExcelReportBuilderManager.AddDataToSection('Conclusion1', Conclusion1);
        ExcelReportBuilderManager.AddDataToSection('Conclusion2', Conclusion2);
        ExcelReportBuilderManager.AddDataToSection('Appendix', Appendix);
        ExcelReportBuilderManager.AddDataToSection('Chairman', Chairman);
        ExcelReportBuilderManager.AddDataToSection('ChairmanName', ChairmanName);
        ExcelReportBuilderManager.AddDataToSection('Member1', Member1);
        ExcelReportBuilderManager.AddDataToSection('Member1Name', Member1Name);
        ExcelReportBuilderManager.AddDataToSection('Member2', Member2);
        ExcelReportBuilderManager.AddDataToSection('Member2Name', Member2Name);

        ConcTotalAmount := 0;
    end;

    local procedure SetLine(FADocLine: Record "FA Document Line")
    var
        FADepreciationBook: Record "FA Depreciation Book";
        FA: Record "Fixed Asset";
        FAComment: Record "FA Comment";
        ReasonCode: Record "Reason Code";
    begin
        FactYears := PrepareLine(FADepreciationBook, FA, ReasonCode, FADocLine."FA No.",
            FADocLine."Depreciation Book Code", FADocLine."Reason Code", "FA Document Header"."Posting Date");

        if FASetup."FA Location Mandatory" then
            FADocLine.TestField("FA Location Code");
        if FASetup."Employee No. Mandatory" then
            FADocLine.TestField("FA Employee No.");

        FADocLine.GetFAComments(Conclusion, FAComment.Type::Conclusion);
        FADocLine.GetFAComments(Appendix, FAComment.Type::Appendix);
        FADocLine.GetFAComments(Result, FAComment.Type::Result);

        FillStateLine(Format(LineNo), FADocLine.Description, FA."Inventory Number", FactYears,
            StdRepMgt.FormatReportValue(FADepreciationBook."Acquisition Cost", 2),
            StdRepMgt.FormatReportValue(FADepreciationBook.Depreciation, 2),
            StdRepMgt.FormatReportValue(FADepreciationBook."Book Value", 2),
            ReasonCode.Description);
    end;

    local procedure SetLine(PostedFADocLine: Record "Posted FA Doc. Line")
    var
        FADepreciationBook: Record "FA Depreciation Book";
        FA: Record "Fixed Asset";
        FAComment: Record "FA Comment";
        ReasonCode: Record "Reason Code";
    begin
        FactYears := PrepareLine(FADepreciationBook, FA, ReasonCode, PostedFADocLine."FA No.",
            PostedFADocLine."Depreciation Book Code", PostedFADocLine."Reason Code", "Posted FA Doc. Header"."Posting Date");

        if FASetup."FA Location Mandatory" then
            PostedFADocLine.TestField("FA Location Code");
        if FASetup."Employee No. Mandatory" then
            PostedFADocLine.TestField("FA Employee No.");

        PostedFADocLine.GetFAComments(Conclusion, FAComment.Type::Conclusion);
        PostedFADocLine.GetFAComments(Appendix, FAComment.Type::Appendix);
        PostedFADocLine.GetFAComments(Result, FAComment.Type::Result);

        FillStateLine(Format(LineNo), PostedFADocLine.Description, FA."Inventory Number", FactYears,
            StdRepMgt.FormatReportValue(FADepreciationBook."Acquisition Cost", 2),
            StdRepMgt.FormatReportValue(FADepreciationBook.Depreciation, 2),
            StdRepMgt.FormatReportValue(FADepreciationBook."Book Value", 2),
            ReasonCode.Description);
    end;

    local procedure PrepareLine(var FADepreciationBook: Record "FA Depreciation Book"; var FA: Record "Fixed Asset"; var Reason: Record "Reason Code"; FANo: Code[20]; DeprBookCode: Code[10]; ReasonCode: Code[10]; PostingDate: Date) FactYears: Text
    begin
        SetSheet(1);

        LineNo += 1;

        FA.Get(FANo);
        if (DepricationGroup <> '') and (DepricationGroup <> FA."Depreciation Group") then
            CurrReport.Break();
        FADepreciationBook.Get(FANo, DeprBookCode);
        FADepreciationBook.CalcFields("Acquisition Cost", Depreciation, "Book Value");
        ProceedsFromDispAmount += FADepreciationBook."Proceeds on Disposal";

        if Reason.Get(ReasonCode) then;
        FactYears := LocMgt.GetPeriodDate(FA."Initial Release Date", "FA Document Header"."Posting Date", 2);
    end;

    procedure FillStateLine(LineNo: Text; Description: Text; InventoryNumber: Text; FactYears: Text; AcquisitionCost: Text; Depreciation: Text; BookValue: Text; ReasonDescription: Text)
    begin
        TryAddBodySection;

        ExcelReportBuilderManager.AddDataToSection('LineNo', LineNo);
        ExcelReportBuilderManager.AddDataToSection('AssetName', Description);
        ExcelReportBuilderManager.AddDataToSection('AssetAccountNum', InventoryNumber);
        ExcelReportBuilderManager.AddDataToSection('ObservedLife', FactYears);
        ExcelReportBuilderManager.AddDataToSection('AcquisitionPrice', AcquisitionCost);
        ExcelReportBuilderManager.AddDataToSection('AmountDepreciation', Depreciation);
        ExcelReportBuilderManager.AddDataToSection('DeprCost', BookValue);
        ExcelReportBuilderManager.AddDataToSection('ReasonDescription', ReasonDescription);

        ExcelReportBuilderManager.AddDataToSection('PrecMetalNames', PrecMetalNames);
        ExcelReportBuilderManager.AddDataToSection('PrecMetalNos', PrecMetalNos);
        ExcelReportBuilderManager.AddDataToSection('PrecMetalUnitOfMeasureCodes', PrecMetalUnitOfMeasureCodes);
        ExcelReportBuilderManager.AddDataToSection('PrecMetalQtys', PrecMetalQtys);
        ExcelReportBuilderManager.AddDataToSection('PrecMetalMasses', PrecMetalMasses);
    end;

    local procedure SetConclusionLine(ItemDocLine: Record "Item Document Line")
    var
        Item: Record Item;
        InvPostSetup: Record "Inventory Posting Setup";
        GenPostSetup: Record "General Posting Setup";
        ItemDocHeader: Record "Item Document Header";
    begin
        with ItemDocLine do begin
            ItemDocHeader.Get(ItemDocHeader."Document Type"::Receipt, "Document No.");
            Item.Get("Item No.");

            InvPostSetup.Get(ItemDocHeader."Location Code", Item."Inventory Posting Group");
            GenPostSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");

            ItemLedgEntry.SetRange("Item No.", "Item No.");
            IF ItemLedgEntry.FindSet(false) then;

            FillConclusionLine(ItemDocHeader."Posting Description", Format(ItemDocHeader."Posting Date"), ItemDocHeader."No.",
                Description, "Item No.", "Unit of Measure Code", StdRepMgt.FormatReportValue(Quantity, 2), StdRepMgt.FormatReportValue("Unit Amount", 2),
                Amount, InvPostSetup."Inventory Account", GenPostSetup."Inventory Adjmt. Account", Format(ItemLedgEntry."Entry No."));
        end;

    end;

    local procedure SetConclusionLine(ItemReceiptLine: Record "Item Receipt Line")
    var
        Item: Record Item;
        InvPostSetup: Record "Inventory Posting Setup";
        GenPostSetup: Record "General Posting Setup";
        ItemReceiptHeader: Record "Item Receipt Header";
    begin
        with ItemReceiptLine do begin
            ItemReceiptHeader.Get("Document No.");
            Item.Get("Item No.");

            InvPostSetup.Get(ItemReceiptHeader."Location Code", Item."Inventory Posting Group");
            GenPostSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");

            ItemLedgEntry.SetRange("Item No.", "Item No.");
            IF ItemLedgEntry.FindSet(false) then;

            FillConclusionLine(ItemReceiptHeader."Posting Description", Format(ItemReceiptHeader."Posting Date"), ItemReceiptHeader."No.",
                Description, "Item No.", "Unit of Measure Code", StdRepMgt.FormatReportValue(Quantity, 2), StdRepMgt.FormatReportValue("Unit Amount", 2),
                Amount, InvPostSetup."Inventory Account", GenPostSetup."Inventory Adjmt. Account", Format(ItemLedgEntry."Entry No."));
        end;

    end;

    local procedure FillConclusionLine(DocName: Text; DocDate: Text; DocNo: Text; Description: Text; ItemNo: Text; UnitOfMeasure: Text; Qty: Text; UnitAmount: Text; Amount: Decimal; InventoryAccount: Text; InventoryAdjmtAccount: Text; EntryNo: Text)
    begin
        if not ExcelReportBuilderManager.TryAddSectionWithPlaceForFooter('CONCLUSIONBODY', 'CONCLUSIONPAGEHEADER') then begin
            ExcelReportBuilderManager.AddPagebreak;
            ExcelReportBuilderManager.AddSection('CONCLUSIONPAGEHEADER');
            ExcelReportBuilderManager.AddSection('CONCLUSIONBODY');
        end;

        ExcelReportBuilderManager.AddDataToSection('ConDocName', DocName);
        ExcelReportBuilderManager.AddDataToSection('ConDocDate', DocDate);
        ExcelReportBuilderManager.AddDataToSection('ConDocNo', DocNo);
        ExcelReportBuilderManager.AddDataToSection('ConDescription', Description);

        ExcelReportBuilderManager.AddDataToSection('ConItemNo', ItemNo);
        ExcelReportBuilderManager.AddDataToSection('ConUOM', UnitOfMeasure);
        ExcelReportBuilderManager.AddDataToSection('ConQty', Qty);
        ExcelReportBuilderManager.AddDataToSection('ConUnitAmount', UnitAmount);
        ExcelReportBuilderManager.AddDataToSection('ConAmount', StdRepMgt.FormatReportValue(Amount, 2));
        ExcelReportBuilderManager.AddDataToSection('InventoryAccount', InventoryAccount);
        ExcelReportBuilderManager.AddDataToSection('InventoryAdjmtAccount', InventoryAdjmtAccount);
        ExcelReportBuilderManager.AddDataToSection('ItemLEEntryNo', EntryNo);

        ConcTotalAmount += Amount;
    end;

    local procedure SetFooter()
    begin
        SetSheet(2);
        FillConclusionPageFooter();
        FillReportFooter(Result[1]);
    end;

    local procedure FillConclusionPageFooter()
    begin
        ExcelReportBuilderManager.AddSection('CONCLUSIONPAGEFOOTER');
        ExcelReportBuilderManager.AddDataToSection('ScrapTotal', StdRepMgt.FormatReportValue(ConcTotalAmount, 2));
    end;

    local procedure FillReportFooter(Result1: Text)
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        ExcelReportBuilderManager.AddSection('REPORTFOOTER');
        ExcelReportBuilderManager.AddDataToSection('Result', Result1);
        ExcelReportBuilderManager.AddDataToSection('SalesProceeds', LocMgt.Amount2Text('', ProceedsFromDispAmount));
        ExcelReportBuilderManager.AddDataToSection('ChiefAccountantName', CompanyInfo."Accountant Name");
        ExcelReportBuilderManager.AddPagebreak;
    end;

    local procedure CheckSignature(var DocSign: Record "Document Signature"; EmpType: Integer)
    var
        DocSignMgt: Codeunit "Doc. Signature Management";
    begin
        DocSignMgt.GetDocSign(DocSign, DATABASE::"FA Document Header",
            "FA Document Header"."Document Type", "FA Document Header"."No.", EmpType, true);
    end;

    local procedure CheckSignature(var PostedDocSign: Record "Posted Document Signature"; EmpType: Integer)
    var
        DocSignMgt: Codeunit "Doc. Signature Management";
    begin
        DocSignMgt.GetPostedDocSign(PostedDocSign, DATABASE::"Posted FA Doc. Header",
            "Posted FA Doc. Header"."Document Type", "Posted FA Doc. Header"."No.", EmpType, false);
    end;

    local procedure AppendString(var String: text[250]; StrToAppend: text[250]);
    begin

        if StrLen(String) = 0 then
            String := StrToAppend
        else
            String := String + '; ' + StrToAppend;

    end;
}