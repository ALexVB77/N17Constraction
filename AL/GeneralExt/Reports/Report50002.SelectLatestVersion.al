report 50002 "Select Latest Version"
{
    Caption = 'Select Latest Version';
    ProcessingOnly = true;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    UseRequestPage = false;

    trigger OnPreReport()

    begin
        SelectLatestVersion();
        Message('Latest version selected');
    end;

}