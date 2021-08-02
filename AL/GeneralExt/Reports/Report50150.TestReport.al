report 50150 "Test Report"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/Layouts/TestReport.rdlc';

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            column(Name1; Number)
            {

            }
        }
    }
    var
        myInt: Integer;
}