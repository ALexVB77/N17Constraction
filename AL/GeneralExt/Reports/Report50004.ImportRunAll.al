report 50004 "Import - RunAll"
{
    ProcessingOnly = true;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(ImportDocDim; ImportDocDim)
                {
                    Caption = 'Import Document Dimension (Step 2)';
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        StartAt := CurrentDateTime;

        if ImportDocDim then
            ImportMgt.ImportDocumentDimension();

        Message('%1: from %2 to %3', CompanyName, StartAt, CurrentDateTime);
    end;

    var
        ImportMgt: Codeunit ImportManagement;
        ImportDocDim: Boolean;
        StartAt: DateTime;

}