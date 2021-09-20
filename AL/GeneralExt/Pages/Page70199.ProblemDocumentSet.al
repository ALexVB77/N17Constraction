Page 70199 "Problem Document Set"
{
    Caption = 'Problem Document Set';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Purchase Header";
    SourceTableView = WHERE("Document Type" = FILTER(Order));
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                group(Problem)
                {
                    Caption = 'Problem';
                    field("Problem Document"; Rec."Problem Document")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            ProblemDescriptionEditable := Rec."Problem Document";
                            if not Rec."Problem Document" then begin
                                Rec.SetAddTypeCommentText(AddCommentType::Problem, '');
                                ProblemDescription := '';
                            end;
                        end;
                    }
                    field("Problem Type"; "Problem Type")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Problem Description"; ProblemDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Problem Description';
                        Editable = ProblemDescriptionEditable;

                        trigger OnValidate()
                        begin
                            Rec.SetAddTypeCommentText(AddCommentType::Problem, ProblemDescription);
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ProblemDescription := Rec.GetAddTypeCommentText(AddCommentType::Problem);
        ProblemDescriptionEditable := Rec."Problem Document";
    end;

    var
        ProblemDescription: text;
        AddCommentType: Enum "Purchase Comment Add. Type";
        ProblemDescriptionEditable: Boolean;

}