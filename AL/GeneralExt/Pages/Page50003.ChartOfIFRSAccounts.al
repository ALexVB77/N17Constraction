page 50003 "Chart of IFRS Accounts"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Chart of IFRS Accounts';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "IFRS Account";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = NoEmphasize;
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = NameEmphasize;
                    Width = 60;
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Totaling; Totaling)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Default Cost Place"; "Default Cost Place")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Default Cost Code"; "Default Cost Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NameIndent := Indentation;
        NoEmphasize := "Account Type" <> "Account Type"::Posting;
        NameEmphasize := "Account Type" <> "Account Type"::Posting;
    end;

    var
        [InDataSet]
        NameIndent: Integer;
        [InDataSet]
        NoEmphasize, NameEmphasize : Boolean;
}