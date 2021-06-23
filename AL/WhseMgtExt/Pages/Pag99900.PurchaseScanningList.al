page 99900 "Purchase Scanning List"
{

    Caption = 'Purchase Scanning List';
    PageType = List;
    SourceTable = "Purchase Header";
    SourceTableView = WHERE(Status = FILTER(Released));
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = All;
                }
            }
        }

    }
    trigger OnClosePage()
    begin

        CurrPage.SetSelectionFilter(Rec);
        FINDSET;
        repeat
            DocFilter += "No." + '|';
        until next = 0;
        Len := StrLen(DocFilter);
        DocFilter := CopyStr(DocFilter, 1, Len - 1);
        ScanHelper.PrepareScanningBuffer(DocFilter, 1);
        ScanningPage.SetParam(DocFilter, 1);
        ScanningPage.RUN;
    end;

    var
        ScanningPage: Page Scanning;
        Len: integer;
        ScanHelper: Codeunit "Scanning Helper";
        DocFilter: Text;


}
