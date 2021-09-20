report 70018 "FA Release Act FA-1a"
{
    Caption = 'FA Release Act FA-1a';
    ProcessingOnly = true;

    dataset
    {
        dataitem("FA Document Header"; "FA Document Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Release));
            RequestFilterFields = "No.";
            dataitem("FA Document Line"; "FA Document Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                RequestFilterFields = "Document No.", "Line No.";
                dataitem("FA Depreciation Book"; "FA Depreciation Book")
                {
                    CalcFields = "Initial Acquisition Cost", Depreciation, "Acquisition Cost";
                    DataItemLink = "FA No." = field("FA No."), "Depreciation Book Code" = field("Depreciation Book Code");
                    DataItemTableView = sorting("FA No.", "Depreciation Book Code");

                    trigger OnPreDataItem()
                    begin
                        SetSheet(2);
                        FillDataPageHeader;
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        ActualUse := FA1Helper.CalcActualUse("FA Document Header"."Posting Date", FA."Initial Release Date");

                        if NoOfDeprMonths = 0 then
                            NoOfDeprMonths := "No. of Depreciation Months";
                        if "No. of Depreciation Months" = 0 then
                            "No. of Depreciation Months" := "No. of Depreciation Years" * 12;

                        FillDataLine(
                          Format(InitialReleaseDate), Format("Last Maintenance Date"), Format(FA."Last Renovation Date"), ActualUse,
                          Depreciation, "Book Value", "Acquisition Cost", Format("Initial Acquisition Cost"),
                          Format("No. of Depreciation Months"), Format("Depreciation Method"),
                          Format(FA1Helper.CalcDepreciationRate("FA Depreciation Book")));
                    end;

                    trigger OnPostDataItem()
                    begin
                        CalcFields("Initial Acquisition Cost", "Acquisition Cost", Depreciation);
                    end;

                }
                dataitem("Item/FA Precious Metal"; "Item/FA Precious Metal")
                {
                    DataItemLink = "No." = field("FA No.");
                    DataItemTableView = sorting("Item Type");

                    trigger OnPreDataItem()
                    begin
                        FillCharPageHeader();
                        if IsHideOutput(false) then
                            CurrReport.Break();
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        FillCharLine(Name, "Nomenclature No.", "Unit of Measure Code", Format(Quantity), Format(Mass));
                    end;

                }
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    MaxIteration = 1;

                    trigger OnPreDataItem()
                    begin
                        FillCharPageFooter();
                        if IsHideOutput(false) then
                            CurrReport.Break();

                        SetSheet(3);
                        FillReportFooter(
                          Conclusion[1], Conclusion[2], Conclusion[3], Conclusion[4], Appendix[1], Appendix[2],
                          Chairman."Employee Job Title", Chairman."Employee Name",
                          Member1."Employee Job Title", Member1."Employee Name",
                          Member2."Employee Job Title", Member2."Employee Name",
                          ReceivedBy."Employee Job Title", ReceivedBy."Employee Name",
                          StoredBy."Employee Job Title", StoredBy."Employee Name");
                    end;
                }
                trigger OnPreDataItem()
                begin
                    IsHeaderPrinted := false;
                end;

                trigger OnAfterGetRecord()
                var
                    OrgInfoArray: array[9] of Text;
                begin
                    FA.Get("FA No.");
                    Testfield("Depreciation Book Code");
                    Testfield("FA Posting Group");

                    if FASetup."FA Location Mandatory" then
                        Testfield("FA Location Code");

                    if "FA Location Code" <> '' then
                        FALocation.Get("FA Location Code");

                    if FA."Initial Release Date" <> 0D then
                        InitialReleaseDate := FA."Initial Release Date"
                    else
                        InitialReleaseDate := "FA Document Header"."Posting Date";

                    FADepreciationBook.Get("FA No.", "New Depreciation Book Code");
                    NoOfDeprMonths := FADepreciationBook."No. of Depreciation Months";
                    FAPostingGroup.Get(FADepreciationBook."FA Posting Group");

                    GetFAComments(Characteristics, FAComment.Type::Characteristics);
                    GetFAComments(ExtraWork, FAComment.Type::"Extra Work");
                    GetFAComments(Conclusion, FAComment.Type::Conclusion);
                    GetFAComments(Appendix, FAComment.Type::Appendix);
                    GetFAComments(Result, FAComment.Type::Result);
                    GetFAComments(Reason, FAComment.Type::Reason);

                    if not IsHeaderPrinted then begin
                        OrgInfoArray[1] := SenderDirectorPosition;
                        OrgInfoArray[2] := SenderDirectorName;
                        OrgInfoArray[3] := DirectorPosition;
                        OrgInfoArray[4] := ReceivedBy."Employee Org. Unit";
                        OrgInfoArray[5] := SenderName;
                        OrgInfoArray[6] := SenderAddress;
                        OrgInfoArray[7] := SenderBank;
                        OrgInfoArray[8] := SenderDepartment;
                        OrgInfoArray[9] := Reason[1];

                        FillHeader(
                          OrgInfoArray, "FA Document Header"."Reason Document No.", Format("FA Document Header"."Reason Document Date"),
                          DocumentNo, Format("FA Document Header"."Posting Date"), Format("FA Document Header"."FA Posting Date"),
                          Format(FADepreciationBook."Disposal Date"), FAPostingGroup."Acquisition Cost Account", FA."Depreciation Code",
                          FA."Depreciation Group", FA."Inventory Number", FA."Factory No.",
                          StrSubstNo('%1 %2 %3', FA."No.", FA.Description, FA."Description 2"),
                          FALocation.Name, FA.Manufacturer, SupplementalInformation1, SupplementalInformation2);
                        IsHeaderPrinted := true;
                    end;
                end;

            }

            trigger OnPreDataItem()
            begin
                if ("FA Document Header".GetFilters() = '') or ("FA Document Header".count = 0) then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                FASetup.Get();

                FA1Helper.CheckSignature(StoredBy, DATABASE::"FA Document Header", "Document Type", "No.", StoredBy."Employee Type"::StoredBy);
                FA1Helper.CheckSignature(ReceivedBy, DATABASE::"FA Document Header", "Document Type", "No.", ReceivedBy."Employee Type"::ReceivedBy);
                FA1Helper.CheckSignature(Chairman, DATABASE::"FA Document Header", "Document Type", "No.", Chairman."Employee Type"::Chairman);
                FA1Helper.CheckSignature(Member1, DATABASE::"FA Document Header", "Document Type", "No.", Member1."Employee Type"::Member1);
                FA1Helper.CheckSignature(Member2, DATABASE::"FA Document Header", "Document Type", "No.", Member2."Employee Type"::Member2);
                DocumentNo := "No.";

                SetSheet(1);
            end;

            trigger OnPostDataItem()
            begin
                SetSheet(1);
            end;
        }
        dataitem("Posted FA Doc. Header"; "Posted FA Doc. Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Release));
            RequestFilterFields = "No.";
            dataitem("Posted FA Doc. Line"; "Posted FA Doc. Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                RequestFilterFields = "Document No.", "Line No.";
                dataitem("FA Depreciation Book 2"; "FA Depreciation Book")
                {
                    CalcFields = "Initial Acquisition Cost", Depreciation, "Acquisition Cost";
                    DataItemLink = "FA No." = field("FA No."), "Depreciation Book Code" = field("Depreciation Book Code");
                    DataItemTableView = sorting("FA No.", "Depreciation Book Code");

                    trigger OnPreDataItem()
                    begin
                        SetSheet(2);
                        FillDataPageHeader;
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        ActualUse := FA1Helper.CalcActualUse("FA Document Header"."Posting Date", FA."Initial Release Date");

                        if NoOfDeprMonths = 0 then
                            NoOfDeprMonths := "No. of Depreciation Months";
                        if "No. of Depreciation Months" = 0 then
                            "No. of Depreciation Months" := "No. of Depreciation Years" * 12;

                        FillDataLine(
                          Format(InitialReleaseDate), Format("Last Maintenance Date"), Format(FA."Last Renovation Date"), ActualUse,
                          Depreciation, "Book Value", "Acquisition Cost", Format("Initial Acquisition Cost"),
                          Format("No. of Depreciation Months"), Format("Depreciation Method"),
                          Format(FA1Helper.CalcDepreciationRate("FA Depreciation Book")));
                    end;

                    trigger OnPostDataItem()
                    begin
                        CalcFields("Initial Acquisition Cost", "Acquisition Cost", Depreciation);
                    end;

                }
                dataitem("Item/FA Precious Metal 2"; "Item/FA Precious Metal")
                {
                    DataItemLink = "No." = field("FA No.");
                    DataItemTableView = sorting("Item Type");

                    trigger OnPreDataItem()
                    begin
                        FillCharPageHeader();
                        if IsHideOutput(true) then
                            CurrReport.Break();
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        FillCharLine(Name, "Nomenclature No.", "Unit of Measure Code", Format(Quantity), Format(Mass));
                    end;

                }
                dataitem("Integer 2"; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    MaxIteration = 1;

                    trigger OnPreDataItem()
                    begin
                        FillCharPageFooter();
                        if IsHideOutput(true) then
                            CurrReport.Break();

                        SetSheet(3);
                        FillReportFooter(
                          Conclusion[1], Conclusion[2], Conclusion[3], Conclusion[4], Appendix[1], Appendix[2],
                          Chairman."Employee Job Title", Chairman."Employee Name",
                          Member1."Employee Job Title", Member1."Employee Name",
                          Member2."Employee Job Title", Member2."Employee Name",
                          ReceivedBy."Employee Job Title", ReceivedBy."Employee Name",
                          StoredBy."Employee Job Title", StoredBy."Employee Name");
                    end;
                }
                trigger OnPreDataItem()
                begin
                    IsHeaderPrinted := false;
                end;

                trigger OnAfterGetRecord()
                var
                    OrgInfoArray: array[9] of Text;
                begin
                    FA.Get("FA No.");
                    Testfield("Depreciation Book Code");
                    Testfield("FA Posting Group");

                    if FASetup."FA Location Mandatory" then
                        Testfield("FA Location Code");

                    if "FA Location Code" <> '' then
                        FALocation.Get("FA Location Code");

                    if FA."Initial Release Date" <> 0D then
                        InitialReleaseDate := FA."Initial Release Date"
                    else
                        InitialReleaseDate := "FA Document Header"."Posting Date";

                    FADepreciationBook.Get("FA No.", "New Depreciation Book Code");
                    NoOfDeprMonths := FADepreciationBook."No. of Depreciation Months";
                    FAPostingGroup.Get(FADepreciationBook."FA Posting Group");

                    GetFAComments(Characteristics, FAComment.Type::Characteristics);
                    GetFAComments(ExtraWork, FAComment.Type::"Extra Work");
                    GetFAComments(Conclusion, FAComment.Type::Conclusion);
                    GetFAComments(Appendix, FAComment.Type::Appendix);
                    GetFAComments(Result, FAComment.Type::Result);
                    GetFAComments(Reason, FAComment.Type::Reason);

                    if not IsHeaderPrinted then begin
                        OrgInfoArray[1] := SenderDirectorPosition;
                        OrgInfoArray[2] := SenderDirectorName;
                        OrgInfoArray[3] := DirectorPosition;
                        OrgInfoArray[4] := ReceivedBy."Employee Org. Unit";
                        OrgInfoArray[5] := SenderName;
                        OrgInfoArray[6] := SenderAddress;
                        OrgInfoArray[7] := SenderBank;
                        OrgInfoArray[8] := SenderDepartment;
                        OrgInfoArray[9] := Reason[1];

                        FillHeader(
                          OrgInfoArray, "Posted FA Doc. Header"."Reason Document No.", Format("Posted FA Doc. Header"."Reason Document Date"),
                          DocumentNo, Format("Posted FA Doc. Header"."Posting Date"), Format("Posted FA Doc. Header"."FA Posting Date"),
                          Format(FADepreciationBook."Disposal Date"), FAPostingGroup."Acquisition Cost Account", FA."Depreciation Code",
                          FA."Depreciation Group", FA."Inventory Number", FA."Factory No.",
                          StrSubstNo('%1 %2 %3', FA."No.", FA.Description, FA."Description 2"),
                          FALocation.Name, FA.Manufacturer, SupplementalInformation1, SupplementalInformation2);
                        IsHeaderPrinted := true;
                    end;
                end;

            }

            trigger OnPreDataItem()
            begin
                if ("Posted FA Doc. Header".GetFilters() = '') or ("Posted FA Doc. Header".Count = 0) then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                FASetup.Get();

                FA1Helper.CheckSignature(StoredBy, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", StoredBy."Employee Type"::StoredBy);
                FA1Helper.CheckSignature(ReceivedBy, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", ReceivedBy."Employee Type"::ReceivedBy);
                FA1Helper.CheckSignature(Chairman, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", Chairman."Employee Type"::Chairman);
                FA1Helper.CheckSignature(Member1, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", Member1."Employee Type"::Member1);
                FA1Helper.CheckSignature(Member2, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", Member2."Employee Type"::Member2);
                DocumentNo := "No.";

                SetSheet(1);
            end;

            trigger OnPostDataItem()
            begin
                SetSheet(1);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(SenderDirectorPosition; SenderDirectorPosition)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Sender Director Title';
                        ToolTip = 'Specifies the title of the director who is releasing the fixed asset.';
                    }
                    field(SenderDirectorName; SenderDirectorName)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Sender Director Full Name';
                        ToolTip = 'Specifies the full name of the director who is releasing the fixed asset.';
                    }
                    field(SenderName; SenderName)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Sender Organization';
                        ToolTip = 'Specifies the name of the organization that is releasing the fixed asset.';
                    }
                    field(SenderAddress; SenderAddress)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Sender Address';
                        ToolTip = 'Specifies the address of the organization that is releasing the fixed asset.';
                    }
                    field(SenderBank; SenderBank)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Sender Bank Information';
                        ToolTip = 'Specifies the bank information of the organization that is releasing the fixed asset.';
                    }
                    field(SenderDepartment; SenderDepartment)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Sender Org. Unit';
                        ToolTip = 'Specifies the organizational unit.';
                    }
                    field(SupplementalInformation1; SupplementalInformation1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Owners of shared property';
                        ToolTip = 'Specifies any shared owners of the related property.';
                    }
                    field(SupplementalInformation2; SupplementalInformation2)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Foreign currency';
                        ToolTip = 'Specifies the currency code for the transaction.';
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
        if Employee.Get(CompanyInfo."Director No.") then
            DirectorPosition := Employee.GetJobTitleName;
        FASetup.Get();
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
        FASetup: Record "FA Setup";
        CompanyInfo: Record "Company Information";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        FALocation: Record "FA Location";
        FA: Record "Fixed Asset";
        FAComment: Record "FA Comment";
        ReceivedBy: Record "Document Signature";
        StoredBy: Record "Document Signature";
        Chairman: Record "Document Signature";
        Member1: Record "Document Signature";
        Member2: Record "Document Signature";
        DocSignMgt: Codeunit "Doc. Signature Management";
        FA1Helper: Codeunit "FA-1 Report Helper";
        StdRepMgt: Codeunit "Local Report Management";
        ExcelReportBuilderManager: Codeunit "Excel Report Builder Manager";
        Characteristics: array[5] of Text[80];
        ExtraWork: array[5] of Text[80];
        Conclusion: array[5] of Text[80];
        Appendix: array[5] of Text[80];
        Result: array[5] of Text[80];
        Reason: array[5] of Text[80];
        ActualUse: Text[30];
        SenderName: Text[100];
        SenderAddress: Text[100];
        SenderBank: Text[150];
        SenderDepartment: Text[100];
        SenderDirectorPosition: Text[100];
        SenderDirectorName: Text[100];
        SupplementalInformation1: Text[100];
        SupplementalInformation2: Text[100];
        DirectorPosition: Text[50];
        FileName: Text;
        DocumentNo: Code[20];
        InitialReleaseDate: Date;
        NoOfDeprMonths: Decimal;
        IsHeaderPrinted: Boolean;

    procedure SetFileNameSilent(NewFileName: Text)
    begin
        FileName := NewFileName;
    end;

    local procedure IsHideOutput(IsPosted: Boolean): Boolean
    begin
        If not IsPosted then
            exit(
                ("FA Document Header"."Document Type" = "FA Document Header"."Document Type"::Movement) or
                ("FA Document Header"."Document Type" = 3));
        exit(
            ("Posted FA Doc. Header"."Document Type" = "Posted FA Doc. Header"."Document Type"::Movement) or
            ("Posted FA Doc. Header"."Document Type" = 3));
    end;

    local procedure InitReportTemplate()
    begin
        FASetup.Get();
        FASetup.Testfield("FA-1a Template Code");
        ExcelReportBuilderManager.InitTemplate(FASetup."FA-1a Template Code");
    end;

    local procedure SetSheet(SheetNo: Integer)
        SheetName: Text;
    begin
        Case SheetNo of
            1:
                SheetName := 'Sheet1';
            2:
                SheetName := 'Sheet2';
            3:
                SheetName := 'Sheet3';
            else
                Error('');
        End;
        ExcelReportBuilderManager.SetSheet(SheetName);
    end;

    local procedure FillHeader(OrgInfoArray: array[9] of Text; ReasonDocNo: Text; ReasonDocDate: Text; DocNo: Text; DocDate: Text; DepreciationStartingDate: Text; DisposalDate: Text; AcqCostAccount: Text; DepreciationCode: Text; DepreciationGroup: Text; InventoryNumber: Text; FactoryNo: Text; FADescription: Text; FALocationName: Text; FAManufacturer: Text; SuppInfo1: Text; SuppInfo2: Text)
    begin
        CompanyInfo.Get();
        ExcelReportBuilderManager.AddSection('REPORTHEADER');
        ExcelReportBuilderManager.AddDataToSection('acquireCompanyName', StdRepMgt.GetCompanyName);
        ExcelReportBuilderManager.AddDataToSection('acquireCompanyAddress', StdRepMgt.GetCompanyAddress);
        ExcelReportBuilderManager.AddDataToSection('acquireBank', StdRepMgt.GetCompanyBank);
        ExcelReportBuilderManager.AddDataToSection('acquireChiefName', CompanyInfo."Director Name");
        ExcelReportBuilderManager.AddDataToSection('acquirecodeOKPO', CompanyInfo."OKPO Code");

        ExcelReportBuilderManager.AddDataToSection('deliverChiefPost', OrgInfoArray[1]);
        ExcelReportBuilderManager.AddDataToSection('deliverChiefName', OrgInfoArray[2]);
        ExcelReportBuilderManager.AddDataToSection('acquireChiefPost', OrgInfoArray[3]);
        ExcelReportBuilderManager.AddDataToSection('acquireDepartamentName', OrgInfoArray[4]);
        ExcelReportBuilderManager.AddDataToSection('deliverCompanyName', OrgInfoArray[5]);
        ExcelReportBuilderManager.AddDataToSection('deliverCompanyAddress', OrgInfoArray[6]);
        ExcelReportBuilderManager.AddDataToSection('deliverBank', CopyStr(OrgInfoArray[7], 1, 75));
        ExcelReportBuilderManager.AddDataToSection('deliverDepartamentName', OrgInfoArray[8]);
        ExcelReportBuilderManager.AddDataToSection('Reason', OrgInfoArray[9]);
        ExcelReportBuilderManager.AddDataToSection('ReasonDocNo', ReasonDocNo);
        ExcelReportBuilderManager.AddDataToSection('ReasonDocDate', ReasonDocDate);
        ExcelReportBuilderManager.AddDataToSection('ActNumber', DocNo);
        ExcelReportBuilderManager.AddDataToSection('ActDate', DocDate);
        ExcelReportBuilderManager.AddDataToSection('DateToBusinessAccounting', DepreciationStartingDate);
        ExcelReportBuilderManager.AddDataToSection('DateFromBusinessAccounting', DisposalDate);
        ExcelReportBuilderManager.AddDataToSection('ControlAccount', AcqCostAccount);
        ExcelReportBuilderManager.AddDataToSection('DepreciationCode', DepreciationCode);
        ExcelReportBuilderManager.AddDataToSection('AssetGroup', DepreciationGroup);
        ExcelReportBuilderManager.AddDataToSection('AccountNum', InventoryNumber);
        ExcelReportBuilderManager.AddDataToSection('SerialNum', FactoryNo);
        ExcelReportBuilderManager.AddDataToSection('AssetName', FADescription);
        ExcelReportBuilderManager.AddDataToSection('AssetLocation', FALocationName);
        ExcelReportBuilderManager.AddDataToSection('Make', FAManufacturer);
        ExcelReportBuilderManager.AddDataToSection('SupplementalInfo1', SuppInfo1);
        ExcelReportBuilderManager.AddDataToSection('SupplementalInfo2', SuppInfo2);
    end;

    local procedure FillDataPageHeader()
    begin
        ExcelReportBuilderManager.AddSection('DATAPAGEHEADER');
    end;

    local procedure FillDataLine(InitialReleaseDate: Text; LastMaintenanceDate: Text; LastRenovationDate: Text; ActualUse: Text; Depreciation: Decimal; BookValue: Decimal; AcqCost: Decimal; InitAcqCost: Text; NewNoOfDeprMonths: Text; DeprMethod: Text; DepreciationRate: Text)
    begin
        if not ExcelReportBuilderManager.TryAddSection('DATABODY') then begin
            ExcelReportBuilderManager.AddPagebreak;
            FillDataPageHeader;
            ExcelReportBuilderManager.AddSection('DATABODY');
        end;

        ExcelReportBuilderManager.AddDataToSection('OldTransDate', InitialReleaseDate);
        ExcelReportBuilderManager.AddDataToSection('OldDateReconstructionLast', LastMaintenanceDate);
        ExcelReportBuilderManager.AddDataToSection('OldDateRevaluationLast', LastRenovationDate);
        ExcelReportBuilderManager.AddDataToSection('OldObservedLife', ActualUse);
        ExcelReportBuilderManager.AddDataToSection('OldDepreciation', Format(Depreciation));
        ExcelReportBuilderManager.AddDataToSection('OldDeprCost', Format(BookValue));
        ExcelReportBuilderManager.AddDataToSection('OldAcquisitPrice', Format(AcqCost));
        ExcelReportBuilderManager.AddDataToSection('NewAcquisitionPrice', InitAcqCost);
        ExcelReportBuilderManager.AddDataToSection('NewUsefulLife', NewNoOfDeprMonths);
        ExcelReportBuilderManager.AddDataToSection('NewDeprProfileName', DeprMethod);
        ExcelReportBuilderManager.AddDataToSection('NewDepreciationRate', DepreciationRate);
    end;

    local procedure FillCharPageHeader()
    var
        i: Integer;
    begin
        ExcelReportBuilderManager.AddSection('CHARPAGEHEADER');
        for i := 1 to ArrayLen(Characteristics) do begin
            ExcelReportBuilderManager.AddDataToSection(StrSubstNo('Characteristics%1', format(i)), Characteristics[i]);
        end;
    end;

    local procedure FillCharLine(Name: Text; NomenclatureNo: Text; UOMCode: Code[10]; Quantity: Text; Mass: Text)
    begin
        if not ExcelReportBuilderManager.TryAddSectionWithPlaceForFooter('CHARBODY', 'OTHERCHARFOOTER') then begin
            ExcelReportBuilderManager.AddPagebreak;
            FillCharPageHeader;
            ExcelReportBuilderManager.AddSection('CHARBODY');
        end;

        ExcelReportBuilderManager.AddDataToSection('MetalName', Name);
        ExcelReportBuilderManager.AddDataToSection('MetalNo', NomenclatureNo);
        ExcelReportBuilderManager.AddDataToSection('MetalUOM', StdRepMgt.GetUoMDesc(UOMCode));
        ExcelReportBuilderManager.AddDataToSection('MetalQty', Quantity);
        ExcelReportBuilderManager.AddDataToSection('MetalMass', Mass);
    end;

    local procedure FillCharPageFooter()
    begin
        ExcelReportBuilderManager.AddSection('OTHERCHARFOOTER');
    end;

    local procedure FillReportFooter(Conclusion1: Text; Conclusion2: Text; Conclusion3: Text; Conclusion4: Text; Appendix1: Text; Appendix2: Text; Chairman: Text; ChairmanName: Text; Member1: Text; Member1Name: Text; Member2: Text; Member2Name: Text; Receiver: Text; ReceiverName: Text; StoredBy: Text; StoredByName: Text)
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        ExcelReportBuilderManager.AddSection('REPORTFOOTER');
        ExcelReportBuilderManager.AddDataToSection('Conclusion1', Conclusion1);
        ExcelReportBuilderManager.AddDataToSection('Conclusion2', Conclusion2);
        ExcelReportBuilderManager.AddDataToSection('Conclusion3', Conclusion3);
        ExcelReportBuilderManager.AddDataToSection('Conclusion4', Conclusion4);
        ExcelReportBuilderManager.AddDataToSection('Appendix1', Appendix1);
        ExcelReportBuilderManager.AddDataToSection('Appendix2', Appendix2);
        ExcelReportBuilderManager.AddDataToSection('Chairman', Chairman);
        ExcelReportBuilderManager.AddDataToSection('ChairmanName', ChairmanName);
        ExcelReportBuilderManager.AddDataToSection('Member1', Member1);
        ExcelReportBuilderManager.AddDataToSection('Member1Name', Member1Name);
        ExcelReportBuilderManager.AddDataToSection('Member2', Member2);
        ExcelReportBuilderManager.AddDataToSection('Member2Name', Member2Name);
        ExcelReportBuilderManager.AddDataToSection('Receiver', Receiver);
        ExcelReportBuilderManager.AddDataToSection('ReceiverName', ReceiverName);
        ExcelReportBuilderManager.AddDataToSection('NewEmplTitle', StoredBy);
        ExcelReportBuilderManager.AddDataToSection('NewEmplName', StoredByName);
        ExcelReportBuilderManager.AddDataToSection('NewChiefAccountantName', CompanyInfo."Accountant Name");
        ExcelReportBuilderManager.AddPagebreak;
    end;

}

