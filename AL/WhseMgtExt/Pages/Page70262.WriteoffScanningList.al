page 70262 "Writeoff Scanning List"
{

    Caption = 'Writeoff Scanning List';
    PageType = List;
    SourceTable = "Item Document Header";
    SourceTableView = WHERE(Status = FILTER(Released), "Document Type" = FILTER(Shipment));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Document No.';
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
        ScanHelper.PrepareScanningBuffer(DocFilter, 4);
        ScanningPage.SetParam(DocFilter, 4);
        ScanningPage.RUN;
    end;

}
