pageextension 80663 "Approval User Setup (Ext)" extends "Approval User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Status App"; Rec."Status App")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Status App Act"; Rec."Status App Act")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Absents"; Rec."Absents")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Administrator IW"; Rec."Administrator IW")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Administrator PRJ"; Rec."Administrator PRJ")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        addafter("&Approval User Setup Test")
        {
            action("Register Absence")
            {
                ApplicationArea = All;
                Caption = 'Register Absence';
                Image = AbsenceCalendar;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AbsentList: Record "User Setup";
                    PayOrderMgt: Codeunit "Payment Order Management";
                begin
                    CurrPage.SetSelectionFilter(AbsentList);
                    PayOrderMgt.RegisterUserAbsence(AbsentList);
                end;
            }
            action("Unregister Absence")
            {
                ApplicationArea = All;
                Caption = 'Unregister Absence';
                Image = CancelAllLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AbsentList: Record "User Setup";
                    PayOrderMgt: Codeunit "Payment Order Management";
                begin
                    CurrPage.SetSelectionFilter(AbsentList);
                    PayOrderMgt.RegisterUserPresence(AbsentList);
                end;
            }
        }
    }
}