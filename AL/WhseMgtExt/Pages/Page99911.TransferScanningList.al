page 99911 "Transfer Scanning List"
{

    Caption = 'Transfer Scanning List';
    PageType = List;
    SourceTable = "Transfer Header";
    SourceTableView = WHERE(Status = FILTER(Released));
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Document No';
                    Caption = 'Document No.';
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        ScanningPage: Page Scanning;
        DocFilter: Code[250];
        ScanHelper: Codeunit "Scanning Helper";

    trigger OnClosePage()
    var
        len: Integer;
    begin
        CurrPage.SETSELECTIONFILTER(Rec);
        FINDSET;
        REPEAT
            DocFilter += "No." + '|';
        UNTIL NEXT = 0;
        Len := STRLEN(DocFilter);
        DocFilter := COPYSTR(DocFilter, 1, Len - 1);
        ScanHelper.PrepareScanningBuffer(DocFilter, 2);
        ScanningPage.SetParam(DocFilter, 2);
        ScanningPage.RUN;
    end;
}
