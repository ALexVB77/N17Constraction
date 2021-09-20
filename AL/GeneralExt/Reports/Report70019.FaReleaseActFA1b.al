report 70019 "Fa Release Act FA-1b"
{
    Caption = 'Fa Release Act FA-1b';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Posted FA Doc. Header"; "Posted FA Doc. Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Release));
            RequestFilterFields = "No.";
            dataitem("Posted FA Doc. Line"; "Posted FA Doc. Line")
            {

                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                dataitem("FA Depreciation Book"; "FA Depreciation Book")
                {
                    DataItemTableView = SORTING("FA No.", "Depreciation Book Code");
                    DataItemLink = "FA No." = FIELD("FA No."), "Depreciation Book Code" = FIELD("New Depreciation Book Code"), "FA Posting Date Filter" = FIELD("Posting Date");

                    trigger OnAfterGetRecord()
                    var


                        FAComment: Record "Posted FA Comment";
                        PreciousMetal: Record "Item/FA Precious Metal";
                        RowNo: Integer;
                        CommentSum: Text[250];
                        PrecMetalNames: Text[250];
                        PrecMetalNos: Text[250];
                        PrecMetalUnitOfMeasureCodes: Text[250];
                        PrecMetalQtys: Text[250];
                        PrecMetalMasses: Text[250];
                    begin

                        ActualUse := LocMgt.GetPeriodDate(FA."Initial Release Date", "Posted FA Doc. Header"."Posting Date", 2);
                        IF "No. of Depreciation Years" <> 0 THEN
                            PercentPerYear := ROUND(1 / "No. of Depreciation Years", 0.01)
                        ELSE
                            PercentPerYear := "Straight-Line %";
                        //ZNS-087 DP >>
                        CALCFIELDS("Acquisition Cost", Depreciation, "Book Value", "Acquisition Cost", "Initial Acquisition Cost");
                        //ZNS-087 DP <<
                        //if (not manufacturerSet) then begin
                        //    ExcelReportBuilderManager.SetSheet('стр1');
                        //   ExcelReportBuilderManager.AddDataToSection('Make', fa.Manufacturer);
                        //    manufacturerSet := true;
                        //end;

                        ExcelReportBuilderManager.SetSheet('стр2');
                        ExcelReportBuilderManager.AddSection('LINE');
                        ExcelReportBuilderManager.AddDataToSection('NumberLine', FORMAT(nLine));
                        ExcelReportBuilderManager.AddDataToSection('AssetName', FA.Description + ' ' + FA."Description 2");
                        ExcelReportBuilderManager.AddDataToSection('AssetGroup', FA."Depreciation Group");
                        ExcelReportBuilderManager.AddDataToSection('AccountNum', FA."Inventory Number");
                        ExcelReportBuilderManager.AddDataToSection('SerialNum', FA."Factory No.");
                        ExcelReportBuilderManager.AddDataToSection('OldGuaranteeDate', FORMAT(FA."Manufacturing Year"));
                        ExcelReportBuilderManager.AddDataToSection('OldTransDate', FORMAT(FA."Initial Release Date"));
                        ExcelReportBuilderManager.AddDataToSection('OldDateRevaluationLast', FORMAT(FA."Last Renovation Date"));


                        ExcelReportBuilderManager.SetSheet('стр3');
                        ExcelReportBuilderManager.AddSection('LINE3');
                        ExcelReportBuilderManager.AddDataToSection('OldObservedLife', ActualUse);
                        ExcelReportBuilderManager.AddDataToSection('OldDepreciation', FORMAT(Depreciation));
                        ExcelReportBuilderManager.AddDataToSection('OldDeprCost', FORMAT("Book Value"));
                        ExcelReportBuilderManager.AddDataToSection('OldAcquisitPrice1', FORMAT("Acquisition Cost"));
                        ExcelReportBuilderManager.AddDataToSection('OldAcquisitPrice', FORMAT("Acquisition Cost"));
                        ExcelReportBuilderManager.AddDataToSection('NewAcquisitionPrice', FORMAT("Initial Acquisition Cost"));
                        ExcelReportBuilderManager.AddDataToSection('NewUsefulLife', FORMAT("No. of Depreciation Months"));
                        ExcelReportBuilderManager.AddDataToSection('NewDeprProfileName', FORMAT("Depreciation Method"));
                        OldAcquisitPriceTotal += "Acquisition Cost";
                        NewAcquisitionPriceTotal += "Initial Acquisition Cost";



                        ExcelReportBuilderManager.SetSheet('стр4');

                        PreciousMetal.SETRANGE("Item Type", PreciousMetal."Item Type"::FA);
                        PreciousMetal.SETRANGE("No.", "FA No.");


                        FAComment.SETRANGE("Document Type", FAComment."Document Type"::Release);
                        FAComment.SETRANGE("Document No.", "Posted FA Doc. Line"."Document No.");
                        FAComment.SETRANGE("Document Line No.", "Posted FA Doc. Line"."Line No.");
                        FAComment.SETRANGE(Type, FAComment.Type::Characteristics);

                        CLEAR(CommentSum);
                        IF FAComment.FINDFIRST THEN
                            REPEAT
                                AppendString(CommentSum, FAComment.Comment);
                            UNTIL FAComment.NEXT = 0;
                        ExcelReportBuilderManager.AddSection('LINE4');
                        ExcelReportBuilderManager.AddDataToSection('Specification', commentsum);


                        CLEAR(PrecMetalNames);
                        CLEAR(PrecMetalNos);
                        CLEAR(PrecMetalUnitOfMeasureCodes);
                        CLEAR(PrecMetalQtys);
                        CLEAR(PrecMetalMasses);

                        IF PreciousMetal.FINDSET THEN
                            REPEAT
                                PreciousMetal.CALCFIELDS(Name);

                                AppendString(PrecMetalNames, PreciousMetal.Name);
                                AppendString(PrecMetalNos, PreciousMetal."Nomenclature No.");
                                AppendString(PrecMetalUnitOfMeasureCodes, PreciousMetal."Unit of Measure Code");
                                AppendString(PrecMetalQtys, FORMAT(PreciousMetal.Quantity));
                                AppendString(PrecMetalMasses, FORMAT(PreciousMetal.Mass));

                            UNTIL PreciousMetal.NEXT = 0;



                        ExcelReportBuilderManager.AddDataToSection('MetalName', PrecMetalNames);
                        ExcelReportBuilderManager.AddDataToSection('MetalNo', PrecMetalNos);
                        ExcelReportBuilderManager.AddDataToSection('MetalUOM', PrecMetalUnitOfMeasureCodes);
                        ExcelReportBuilderManager.AddDataToSection('MetalQty', PrecMetalQtys);
                        ExcelReportBuilderManager.AddDataToSection('MetalWeight', PrecMetalMasses);

                    end;
                }
                trigger OnPreDataItem()
                var
                    locLabel001: label 'Выберите код амортизации';
                begin
                    //if ("Posted FA Doc. Line".getfilter("Depreciation Book Code") = '') then error(locLabel001);
                    if (DepreciationCode = '') then error(locLabel001);


                    IsHeaderPrinted := FALSE;

                    ExcelReportBuilderManager.SetSheet('стр2');
                    ExcelReportBuilderManager.AddSection('HEADER2');

                    ExcelReportBuilderManager.SetSheet('стр3');
                    ExcelReportBuilderManager.AddSection('HEADER3');

                    ExcelReportBuilderManager.SetSheet('стр4');
                    ExcelReportBuilderManager.AddSection('HEADER4');

                    nLine := 0;

                end;

                trigger OnAfterGetRecord()
                var
                    OrgInfoArray: array[9] of text;
                begin


                    //FA.GET("FA No.");

                    FA.SETRANGE("No.", "FA No.");
                    FA.SETFILTER("Depreciation Group", DepreciationGroup);
                    FA.SETFILTER("Depreciation Code", DepreciationCode);
                    IF not FA.FINDFIRST THEN CurrReport.skip;



                    TESTFIELD("Depreciation Book Code");
                    TESTFIELD("FA Posting Group");

                    IF FASetup."FA Location Mandatory" THEN
                        TESTFIELD("FA Location Code");
                    IF "FA Location Code" <> '' THEN
                        FALocation.GET("FA Location Code");

                    IF FA."Initial Release Date" <> 0D THEN
                        InitialReleaseDate := FA."Initial Release Date"
                    ELSE
                        InitialReleaseDate := "Posted FA Doc. Header"."Posting Date";

                    FADepreciationBook.GET("FA No.", "New Depreciation Book Code");
                    FAPostingGroup.GET(FADepreciationBook."FA Posting Group");

                    GetFAComments(Characteristics, PostedFAComment.Type::Characteristics);
                    GetFAComments(ExtraWork, PostedFAComment.Type::"Extra Work");
                    GetFAComments(Conclusion, PostedFAComment.Type::Conclusion);
                    GetFAComments(Appendix, PostedFAComment.Type::Appendix);
                    GetFAComments(Result, PostedFAComment.Type::Result);
                    GetFAComments(Reason, PostedFAComment.Type::Reason);

                    IF NOT IsHeaderPrinted THEN BEGIN
                        OrgInfoArray[1] := SenderDirectorPosition;
                        OrgInfoArray[2] := SenderDirectorName;
                        OrgInfoArray[3] := DirectorPosition;
                        OrgInfoArray[4] := ReceivedBy."Employee Org. Unit";
                        OrgInfoArray[5] := SenderName;
                        OrgInfoArray[6] := SenderAddress;
                        OrgInfoArray[7] := SenderBank;
                        OrgInfoArray[8] := SenderDepartment;
                        OrgInfoArray[9] := Reason[1];
                        IsHeaderPrinted := TRUE;
                    END;

                    nLine += 1;
                end;

                trigger OnPostDataItem()
                var
                    pd: date;

                    PostedFAComment: Record "Posted FA Comment";
                    str: text;
                    Appendix: text;
                begin

                    ExcelReportBuilderManager.SetSheet('стр2');
                    ExcelReportBuilderManager.AddSection('FOOTER2');
                    ExcelReportBuilderManager.AddDataToSection('Chairman', Chairman."Employee Job Title");
                    ExcelReportBuilderManager.AddDataToSection('ChairmanName', Chairman."Employee Name");
                    ExcelReportBuilderManager.AddDataToSection('Member1', Member1."Employee Job Title");
                    ExcelReportBuilderManager.AddDataToSection('Member1Name', Member1."Employee Name");
                    ExcelReportBuilderManager.AddDataToSection('Member2', Member2."Employee Job Title");
                    ExcelReportBuilderManager.AddDataToSection('Member2Name', Member2."Employee Name");
                    ExcelReportBuilderManager.AddDataToSection('Member3', Member3."Employee Job Title");
                    ExcelReportBuilderManager.AddDataToSection('Member3Name', Member3."Employee Name");


                    pd := "Posted FA Doc. Header"."Posting Date";
                    ExcelReportBuilderManager.AddDataToSection('ResultDateNumber', FORMAT(DATE2DMY(pd, 1)));
                    ExcelReportBuilderManager.AddDataToSection('ResultDateMonth', FORMAT(pd, 0, '<Month Text>'));
                    ExcelReportBuilderManager.AddDataToSection('ResultDateYear', FORMAT(pd, 0, '<Year>'));

                    PostedFAComment.setrange("Document Type", PostedFAComment."Document Type"::Release);

                    PostedFAComment.SETRANGE("Document No.", "Posted FA Doc. Header"."No.");
                    PostedFAComment.SETRANGE(Type, PostedFAComment.Type::Conclusion);
                    IF PostedFAComment.FINDSET THEN BEGIN
                        str += PostedFAComment.Comment;
                        //ExcelMgt.FillCell('Y48', PostedFAComment.Comment);
                        //RowNo := 49;
                        WHILE PostedFAComment.NEXT <> 0 DO BEGIN
                            str += PostedFAComment.Comment;
                            //ExcelMgt.FillCell('A' + FORMAT(RowNo), PostedFAComment.Comment);
                            //RowNo += 1;
                        END;
                    END;
                    ExcelReportBuilderManager.AddDataToSection('CommisionResult', str);

                    PostedFAComment.SETRANGE(Type, PostedFAComment.Type::Appendix);
                    CLEAR(Appendix);
                    IF PostedFAComment.FINDFIRST THEN
                        REPEAT
                            IF STRLEN(Appendix) = 0 THEN
                                Appendix := PostedFAComment.Comment
                            ELSE
                                Appendix := Appendix + ' ' + PostedFAComment.Comment;
                        UNTIL PostedFAComment.NEXT = 0;

                    ExcelReportBuilderManager.AddDataToSection('Appendix', Appendix);


                    ExcelReportBuilderManager.SetSheet('стр3');
                    ExcelReportBuilderManager.AddSection('FOOTER3');
                    ExcelReportBuilderManager.AddDataToSection('AccountantName', CompanyInfo."Accountant Name");
                    ExcelReportBuilderManager.AddDataToSection('PassedBy', PassedBy."Employee Job Title");
                    ExcelReportBuilderManager.AddDataToSection('PassedByName', PassedBy."Employee Name");
                    ExcelReportBuilderManager.AddDataToSection('OldAcquisitPriceTotal', format(OldAcquisitPriceTotal));
                    ExcelReportBuilderManager.AddDataToSection('NewAcquisitionPriceTotal', format(NewAcquisitionPriceTotal));

                    ExcelReportBuilderManager.SetSheet('стр4');
                    ExcelReportBuilderManager.AddSection('FOOTER4');
                    ExcelReportBuilderManager.AddDataToSection('Receiver', ReceivedBy."Employee Job Title");
                    ExcelReportBuilderManager.AddDataToSection('ReceiverName', ReceivedBy."Employee Name");
                    ExcelReportBuilderManager.AddDataToSection('NewChiefAccountantName', CompanyInfo."Accountant Name");
                    ExcelReportBuilderManager.AddDataToSection('NewEmplTitle', Responsible."Employee Job Title");
                    ExcelReportBuilderManager.AddDataToSection('NewEmplName', Responsible."Employee Name");

                    IF AttorneyDate <> 0D THEN BEGIN
                        ExcelReportBuilderManager.AddDataToSection('AttDate', FORMAT(DATE2DMY(AttorneyDate, 1)));
                        ExcelReportBuilderManager.AddDataToSection('AttMonth', FORMAT(AttorneyDate, 0, '<Month Text>'));
                        ExcelReportBuilderManager.AddDataToSection('AttYear', FORMAT(AttorneyDate, 0, '<Year>'));
                    END;
                    ExcelReportBuilderManager.AddDataToSection('AttNo', AttorneyNo);
                    ExcelReportBuilderManager.AddDataToSection('AttIssuedBy', locRepMgt.GetEmpName(AttorneyIssuedBy));
                end;

            }
            trigger OnAfterGetRecord()
            var
                vendorBankAcc: Record "Vendor Bank Account";
            begin
                FASetup.GET;
                FA1Helper.CheckPostedSignature(
                  StoredBy, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", StoredBy."Employee Type"::StoredBy);
                FA1Helper.CheckPostedSignature(
                  ReceivedBy, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", ReceivedBy."Employee Type"::ReceivedBy);
                FA1Helper.CheckPostedSignature(
                  Chairman, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", Chairman."Employee Type"::Chairman);
                FA1Helper.CheckPostedSignature(
                  Member1, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", Member1."Employee Type"::Member1);
                FA1Helper.CheckPostedSignature(
                  Member2, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", Member2."Employee Type"::Member2);
                FA1Helper.CheckPostedSignature(
                  Member3, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", Member3."Employee Type"::Member3);
                FA1Helper.CheckPostedSignature(
                  PassedBy, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", ReceivedBy."Employee Type"::PassedBy);
                FA1Helper.CheckPostedSignature(
                  Responsible, DATABASE::"Posted FA Doc. Header", "Document Type", "No.", ReceivedBy."Employee Type"::Responsible);

                ExcelReportBuilderManager.SetSheet('стр1');

                CompanyInfo.GET;
                ExcelReportBuilderManager.AddSection('REPORTHEADER');
                ExcelReportBuilderManager.AddDataToSection('acquireCompanyName', LocRepMgt.GetCompanyName);
                ExcelReportBuilderManager.AddDataToSection('acquireCompanyAddress', LocRepMgt.GetCompanyAddress);
                ExcelReportBuilderManager.AddDataToSection('acquireBank', LocRepMgt.GetCompanyBank);
                ExcelReportBuilderManager.AddDataToSection('acquireChiefName', locRepMgt.GetEmpName(CompanyInfo."Director No."));
                ExcelReportBuilderManager.AddDataToSection('acquireChiefPost', locRepMgt.GetEmpPosition(CompanyInfo."Director No."));
                ExcelReportBuilderManager.AddDataToSection('acquirecodeOKPO', CompanyInfo."OKPO Code");


                IF Vendor.GET(VendorNo) THEN BEGIN
                    ExcelReportBuilderManager.AddDataToSection('deliverCompanyName', DELCHR(Vendor.Name + ' ' + Vendor."Name 2", '<>'));
                    ExcelReportBuilderManager.AddDataToSection('deliverCompanyAddress', DELCHR(Vendor.Address + ' ' + Vendor."Address 2", '<>') + locRepMgt.GetVendPhoneFax(VendorNo));

                    IF VendorBankAcc.GET(VendorNo, Vendor."Default Bank Code") THEN
                        ExcelReportBuilderManager.AddDataToSection('deliverBank',
                        VendorBankAcc."Bank Branch No." + ',' +
                        VendorBankAcc."Bank Account No." + ',' +
                        VendorBankAcc."Bank Corresp. Account No.");
                    ExcelReportBuilderManager.AddDataToSection('deliverDepartmentName', DepartmentName);
                    ExcelReportBuilderManager.AddDataToSection('VendorOKPO', Vendor."OKPO Code");
                END;

                ExcelReportBuilderManager.AddDataToSection('deliverChiefPost', CompDirectorPos);
                ExcelReportBuilderManager.AddDataToSection('deliverChiefName', CompDirectorName);

                ExcelReportBuilderManager.AddDataToSection('ControlAccount', DepreciationCode);
                ExcelReportBuilderManager.AddDataToSection('Reason', TransferStatementReason);
                ExcelReportBuilderManager.AddDataToSection('TransferPurpose', TransferPurpose);

                IF "FA Location Code" <> '' THEN BEGIN
                    FALocation.GET("FA Location Code");
                    ExcelReportBuilderManager.AddDataToSection('acquireDepartmentName', FALocation.Name);
                END;

                ExcelReportBuilderManager.AddDataToSection('DateToBusinessAccounting', FORMAT("Posting Date"));
                ExcelReportBuilderManager.AddDataToSection('ReasonDocNo', "Reason Document No.");
                ExcelReportBuilderManager.AddDataToSection('ReasonDocDate', FORMAT("Reason Document Date"));
                ExcelReportBuilderManager.AddDataToSection('ActNumber', "No.");
                ExcelReportBuilderManager.AddDataToSection('ActDate', FORMAT("Posting Date"));

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
                    Caption = 'Options';
                    group(General)
                    {
                        caption = 'General';


                        field(DepreciationGroup; DepreciationGroup)
                        {
                            caption = 'Depreciation Group';
                            TableRelation = "Depreciation Group";
                            ApplicationArea = FixedAssets;
                            ShowMandatory = true;
                        }
                        field(DepreciationCode; DepreciationCode)
                        {
                            caption = 'Depreciation Code';
                            tablerelation = "Depreciation Code";
                            ApplicationArea = FixedAssets;
                            ShowMandatory = true;
                        }
                        field(VendorNo; VendorNo)
                        {
                            Caption = 'Transferor No.';
                            tablerelation = vendor;
                            ApplicationArea = FixedAssets;
                            ShowMandatory = true;
                        }
                    }
                    group(Organization)
                    {
                        caption = 'Organization';


                        field(CompDirectorPos; CompDirectorPos)
                        {
                            Caption = 'Position';
                            ApplicationArea = FixedAssets;
                        }
                        field(CompDirectorName; CompDirectorName)
                        {
                            Caption = 'Name';
                            ApplicationArea = FixedAssets;
                        }
                        field(DepartmentName; DepartmentName)
                        {
                            Caption = 'Department Name';
                            ApplicationArea = FixedAssets;
                        }
                        field(TransferStatementReason; TransferStatementReason)
                        {
                            Caption = 'Transfer Statement Reason';
                            ApplicationArea = FixedAssets;
                        }
                        field(TransferPurpose; TransferPurpose)
                        {
                            Caption = 'Transfer Purpose';
                            ApplicationArea = FixedAssets;
                        }
                    }
                    group(Attrorney)
                    {
                        caption = 'Attorney';


                        field(AttorneyDate; AttorneyDate)
                        {
                            Caption = 'Attorney Date';
                            ApplicationArea = FixedAssets;
                        }
                        field(AttorneyNo; AttorneyNo)
                        {
                            Caption = 'Attorney No';
                            ApplicationArea = FixedAssets;
                        }
                        field(AttorneyIssuedBy; AttorneyIssuedBy)
                        {
                            Caption = 'Issued By';
                            TableRelation = Employee;
                            ApplicationArea = FixedAssets;
                        }
                    }

                }
            }
        }
    }
    trigger OnInitReport()
    var
        Employee: record Employee;
    begin

        CompanyInfo.GET;
        IF Employee.GET(CompanyInfo."Director No.") THEN
            DirectorPosition := Employee.GetJobTitleName;
        FASetup.GET;
    end;

    trigger OnPreReport()
    begin
        FASetup.GET;
        FASetup.TESTFIELD(FASetup."FA-1b Template Code");
        ExcelReportBuilderManager.InitTemplate(FASetup."FA-1b Template Code");
    end;

    trigger OnPostReport()
    begin
        IF FileName <> '' THEN
            ExcelReportBuilderManager.ExportDataToClientFile(FileName)
        ELSE
            ExcelReportBuilderManager.ExportData;
    end;

    var

        FASetup: Record "FA Setup";
        CompanyInfo: Record "Company Information";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        FALocation: Record "FA Location";
        FA: Record "Fixed Asset";
        PostedFAComment: Record "Posted FA Comment";
        ReceivedBy: Record "Posted Document Signature";
        PassedBy: Record "Posted Document Signature";
        StoredBy: Record "Posted Document Signature";
        Chairman: Record "Posted Document Signature";
        Member1: Record "Posted Document Signature";
        Member2: Record "Posted Document Signature";
        Responsible: Record "Posted Document Signature";

        LocMgt: Codeunit "Localisation Management";
        DocSignMgt: Codeunit "Doc. Signature Management";

        FA1Helper: Codeunit "FA-1 Report Helper";

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

        DirectorPosition: Text[50];
        FileName: Text;
        PercentPerYear: Decimal;
        InitialReleaseDate: Date;
        IsHeaderPrinted: Boolean;
        PurchInvHeader: Record "Purch. Inv. Header";
        Vendor: Record Vendor;
        LocRepMgt: Codeunit "Local Report Management";
        ExcelReportBuilderManager: Codeunit "Excel Report Builder Manager";
        nLine: Integer;
        Member3: Record "Posted Document Signature";
        ItemFAPreciousMetal: Record "Item/FA Precious Metal";
        Text_001: label 'Подлежит вводу в эксплуатацию с %1';
        CompDirectorPos: Text[250];
        CompDirectorName: Text[250];
        TransferStatementReason: Text[250];
        TransferPurpose: Text[250];
        AttorneyDate: Date;
        AttorneyNo: Text[50];
        AttorneyIssuedBy: Code[20];
        DepreciationGroup: Code[10];
        DepreciationCode: Code[20];
        VendorNo: Code[10];

        DepartmentName: Text[250];
        manufacturerSet: Boolean;
        OldAcquisitPriceTotal: Decimal;
        NewAcquisitionPriceTotal: Decimal;

    procedure appendString(var string: text[250]; strToAppend: text[250]);
    begin

        IF STRLEN(String) = 0 THEN
            String := StrToAppend
        ELSE
            String := String + '; ' + StrToAppend;

    end;
}
