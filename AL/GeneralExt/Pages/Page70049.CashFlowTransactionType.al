page 70049 "Cash Flow Transaction Type"
{
    Caption = 'Cash Flow Transaction Type';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Cash Flow Transaction Type";
    SourceTableView = sorting(Priority) order(Ascending);

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }
}