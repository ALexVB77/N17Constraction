page 70027 "Investment Agreements"
{
    Editable = false;
    SourceTable = "Customer Agreement";
    PopulateAllFields = true;
    SourceTableView = SORTING("Customer No.", "No.") WHERE("Agreement Type" = FILTER("Investment Agreement" | "Reserving Agreement"));
    PageType = List;
    CardPageId = "Investment Agreement Card";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Investment Agreements';

    layout
    {
        area(content)
        {
            repeater(Repeater12370003)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;

                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                }

                field("Agreement Date"; Rec."Agreement Date")
                {
                    ApplicationArea = All;

                }

                field("Agreement Type"; Rec."Agreement Type")
                {
                    ApplicationArea = All;

                }



            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("A&greement")
            {
                Caption = 'A&greement';
                action("Ledger E&ntries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ledger E&ntries';
                    Image = GL;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = FIELD("Customer No."),
                                  "Agreement No." = FIELD("No.");
                    RunPageView = SORTING("Customer No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Customer Agreement"),
                                  "No." = FIELD("No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(14902),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                separator(Action1210023)
                {
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Customer Statistics";
                    RunPageLink = "No." = FIELD("Customer No."),
                                  "Agreement Filter" = FIELD("No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("Entry Statistics")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Entry Statistics';
                    Image = EntryStatistics;
                    RunObject = Page "Customer Entry Statistics";
                    RunPageLink = "No." = FIELD("Customer No."),
                                  "Agreement Filter" = FIELD("No.");
                }
                action("S&ales")
                {
                    ApplicationArea = Suite;
                    Caption = 'S&ales';
                    Image = Sales;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Customer Sales";
                    RunPageLink = "No." = FIELD("Customer No."),
                                  "Agreement Filter" = FIELD("No.");
                }
            }
            group(Action1210028)
            {
                Caption = 'S&ales';
                Image = Sales;
                action(Orders)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Orders';
                    Image = Document;
                    RunObject = Page "Sales Order List";
                    RunPageLink = "Sell-to Customer No." = FIELD("Customer No."),
                                  "Agreement No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", "Sell-to Customer No.", "No.");
                    ToolTip = 'View any related sales orders. ';
                }
            }
        }
    }

}

