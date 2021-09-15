page 50004 "IFRS Accounting Periods"
{
    AdditionalSearchTerms = 'ifrs fiscal year,ifrs fiscal period';
    ApplicationArea = Basic, Suite;
    Caption = 'IFRS Accounting Periods';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "IFRS Accounting Period";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period Closed"; "Period Closed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Modified Date Time"; "Last Modified Date Time")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Modified User ID"; "Last Modified User ID")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Create Year")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Create Year';
                Ellipsis = true;
                Enabled = false;
                Image = CreateYear;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Report "Create Fiscal Year";
            }
        }
    }
}

