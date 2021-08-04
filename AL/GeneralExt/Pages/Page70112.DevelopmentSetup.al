page 70112 "Development Setup"
{
    SourceTable = "Development Setup";
    PageType = Card;
    Caption = 'Development Settings';
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Project Dimension Code"; Rec."Project Dimension Code")
                {
                    ApplicationArea = All;

                }

                field("Pref Vesion Code"; Rec."Pref Vesion Code")
                {
                    ApplicationArea = All;

                }

                // field("Project Turn Dimension Code"; Rec."Project Turn Dimension Code")
                // {
                //     ApplicationArea = All;

                // }   

                // field("Sales Agreement Role"; Rec."Sales Agreement Role")
                // {
                //     ApplicationArea = All;

                // }   

                field("Pref Forecast Code"; Rec."Pref Forecast Code")
                {
                    ApplicationArea = All;

                }

                // field("Change Agreement CF Role"; Rec."Change Agreement CF Role")
                // {
                //     ApplicationArea = All;

                // }   

                // field("Forecast Approver Role"; Rec."Forecast Approver Role")
                // {
                //     ApplicationArea = All;

                // }   

                // field("Forecast Import Role"; Rec."Forecast Import Role")
                // {
                //     ApplicationArea = All;

                // }   

                // field("Main IFRS Company"; Rec."Main IFRS Company")
                // {
                //     ApplicationArea = All;

                // }   

                // field("Create Vend Agr Details"; Rec."Create Vend Agr Details")
                // {
                //     ShowCaption = false;
                //     ApplicationArea = All;

                // }   



            }
        }
    }


    // actions
    // {
    //     area(navigation)
    //     {
    //         group("Command Buttons")
    //         {
    //             action("Recalc Committed")
    //             {
    //                 Caption = 'Recalc Committed';
    //                 trigger OnAction()
    //                 begin
    //                     ERPC.ReFillCommitment;
    //                     MESSAGE('Done');
    //                 end;


    //             }   


    //         }
    //     }
    // }




    // var 
    //     ERPC: codeunit "ERPC Funtions";



}