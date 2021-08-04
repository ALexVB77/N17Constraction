report 99997 "Import Item Remains"
{
    Caption = 'Import Item Remains';
    ProcessingOnly = true;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;

    dataset
    {

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
                    field(ijTemplate; ijTemplate)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Template';
                        TableRelation = "Item Journal Template";

                    }
                    field(ijBatch; ijBatch)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Batch';
                        TableRelation = "Item Journal Batch";
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ijb: Record "Item Journal Batch";
                        begin
                            ijb.reset();
                            ijb.SetRange("Journal Template Name", ijTemplate);
                            if (page.runmodal(0, ijb) = Action::LookupOK) then begin
                                ijBatch := ijb.Name;
                            end;
                        end;

                    }
                    field(docNo; docNo)
                    {
                        ApplicationArea = all;
                        Caption = 'Document No.';
                    }
                    field(postDate; postDate)
                    {
                        ApplicationArea = all;
                        Caption = 'Posting date';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            postDate := Today;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            FileMgt: Codeunit "File Management";
        begin
            if CloseAction = ACTION::OK then begin
                if ServerFileName = '' then
                    ServerFileName := FileMgt.UploadFile('Import Excel File', ExcelFileExtensionTok);
                if ServerFileName = '' then
                    exit(false);
            end;
        end;
    }

    trigger OnPreReport()

    begin
        if SheetName = '' then
            SheetName := ExcelBuf.SelectSheetsName(ServerFileName);




        ExcelBuf.OpenBook(ServerFileName, SheetName);
        ExcelBuf.SetReadDateTimeInUtcDate(true);
        ExcelBuf.ReadSheet;
        ExcelBuf.SetReadDateTimeInUtcDate(false);

        AnalyzeData;

    end;

    var
        ijTemplate: code[10];
        ijBatch: code[10];
        docNo: code[20];
        postDate: date;
        ExcelBuf: Record "Excel Buffer" temporary;
        Window: Dialog;
        ServerFileName: Text;
        SheetName: Text[250];
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;

    local procedure AnalyzeData()
    var
        r: integer;
        maxR: integer;
        ijl: record "Item Journal Line";
        lineNo: integer;
        d: Decimal;
        dimMgt: Codeunit "Dimension Management (Ext)";
    begin
        Window.Open('@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        Window.Update(1, 0);
        ExcelBuf.findlast();
        maxR := ExcelBuf."Row No.";
        lineNo := 10000;

        ijl.reset();
        ijl.SetRange("Journal Template Name", ijTemplate);
        ijl.SetRange("Journal Batch Name", ijBatch);
        if (ijl.Findlast()) then lineNo += ijl."Line No.";

        for r := 2 to maxR do begin
            window.Update(1, Round(r / maxR * 10000, 1));
            ijl.init();
            ijl."Journal Template Name" := ijTemplate;
            ijl."Journal Batch Name" := ijBatch;
            ijl."Line No." := lineNo;

            ijl.insert(true);

            ijl.Validate("Posting Date", postDate);
            ijl.validate("Document No.", docNo);
            ijl.Validate("Entry Type", ijl."Entry Type"::Purchase);

            ExcelBuf.get(r, 1);
            ijl.validate("Item No.", ExcelBuf."Cell Value as Text");

            if (ExcelBuf.get(r, 2)) then begin
                ijl.validate("Unit of Measure Code", ExcelBuf."Cell Value as Text");
            end;

            if (ExcelBuf.get(r, 3)) then begin
                ijl.validate("Location Code", ExcelBuf."Cell Value as Text");
            end;

            if (ExcelBuf.get(r, 4)) then begin
                ijl.validate("Shortcut Dimension 1 Code", ExcelBuf."Cell Value as Text");
            end;

            if (ExcelBuf.get(r, 5)) then begin
                ijl.validate("Shortcut Dimension 2 Code", copystr(ExcelBuf."Cell Value as Text", 2));
            end;

            if (ExcelBuf.get(r, 6)) then begin
                dimMgt.valDimValue('НП', ExcelBuf."Cell Value as Text", ijl."Dimension Set ID");
            end;

            if (ExcelBuf.get(r, 7)) then begin
                dimMgt.valDimValue('НУ-ВИД', ExcelBuf."Cell Value as Text", ijl."Dimension Set ID");
            end;

            if (ExcelBuf.get(r, 8)) then begin
                dimMgt.valDimValue('НУ-ОБЪЕКТ', ExcelBuf."Cell Value as Text", ijl."Dimension Set ID");
            end;

            if (ExcelBuf.get(r, 9)) then begin
                if (Evaluate(d, ExcelBuf."Cell Value as Text")) then begin
                    ijl.validate("Unit Cost", d);
                end;
            end;
            if (ExcelBuf.get(r, 10)) then begin
                if (Evaluate(d, ExcelBuf."Cell Value as Text")) then begin
                    ijl.validate(Quantity, d);
                end;
            end;
            lineNo += 10000;
            ijl.Modify(true);
        end;



        Window.Close;

    end;


}

