report 50270 "Change Vendor Agreement"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Description = 'NC 51432 PA';
    Caption = 'Change Vendor Agreement';
    ProcessingOnly = true;

    dataset
    {
        dataitem(VendorAgreement; "Vendor Agreement")
        {
            DataItemTableView = sorting("Vendor No.", "No.") where("No." = filter(<> ''));

            trigger OnPreDataItem()
            begin
                VendorAgrRAS.ChangeCompany(CompName);
                ExcellBuffer.DeleteAll();
                if TestRegim then begin
                    RowNo := 0;
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                if not TestRegim then begin
                    VendorAgr.SetRange("No.", "No.");
                    if VendorAgr.Count = 1 then begin
                        VendorAgrRAS.SetRange("No.", "No.");
                        if VendorAgrRAS.FindFirst() then begin
                            if "Vendor No." <> VendorAgrRAS."Vendor No." then begin
                                if VendorAgrRename.Get("Vendor No.", "No.") then begin
                                    VendorAgrRename.Rename(VendorAgrRAS."Vendor No.", "No.");
                                    VendorAgrRename.Modify();
                                end;
                            end;
                        end;
                    end;
                end else begin
                    VendorAgr.SetRange("No.", "No.");
                    if VendorAgr.Count = 1 then begin
                        VendorAgrRAS.SetRange("No.", "No.");
                        if VendorAgrRAS.FindFirst then begin
                            if "Vendor No." <> VendorAgrRAS."Vendor No." then begin
                                RowNo += 1;
                                EnterCell(RowNo, 1, Format("No."), false, ExcellBuffer."Cell Type"::Text, true);
                            end;
                        end;
                    end else begin
                        VendorAgrTmp.SetRange("No.", "No.");
                        if VendorAgrTmp.IsEmpty then begin
                            RowNo += 1;
                            EnterCell(RowNo, 1, Format("No."), false, ExcellBuffer."Cell Type"::Text, true);
                            EnterCell(RowNo, 2, Text002, false, ExcellBuffer."Cell Type"::Text, true);
                            VendorAgrTmp.Init;
                            VendorAgrTmp.TransferFields(VendorAgreement);
                            VendorAgrTmp.Insert();
                        end;
                    end;
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    ShowCaption = false;
                    field(CompanyRAS; CompName)
                    {
                        ApplicationArea = All;
                        Caption = 'Company RAS';
                        TableRelation = Company;
                    }
                    field(TestRegim; TestRegim)
                    {
                        ApplicationArea = All;
                        Caption = 'Test mode';
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    begin
        ServerFileName := FileManagement.ServerTempFileName(Text001);
        ExcellBuffer.CreateBookAndOpenExcel(ServerFileName, Format(Today), '', Format(CompanyName), Format(UserId));
    end;

    var
        CompName: Text[30];
        TestRegim: Boolean;
        ServerFileName: Text;
        FileManagement: Codeunit "File Management";
        VendorAgrRAS: Record "Vendor Agreement";
        VendorAgr: Record "Vendor Agreement";
        VendorAgrRename: Record "Vendor Agreement";
        VendorAgrTmp: Record "Vendor Agreement" temporary;
        ExcellBuffer: Record "Excel Buffer Mod" temporary;
        RowNo: Integer;
        Text001: Label '.xlsx';
        Text002: Label 'Several lines with a agreement';

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text; Bold: Boolean; CellType: Integer; IsBorder: Boolean)
    begin
        ExcellBuffer.Init();
        ExcellBuffer.Validate("Row No.", RowNo);
        ExcellBuffer.Validate("Column No.", ColumnNo);
        ExcellBuffer."Cell Value as Text" := CellValue;
        ExcellBuffer.Formula := '';
        ExcellBuffer.Bold := Bold;
        ExcellBuffer."Cell Type" := CellType;
        if IsBorder then
            ExcellBuffer.SetBorder(true, true, true, true, false, "Border Style"::Thin);
        ExcellBuffer.Insert();
    end;
}