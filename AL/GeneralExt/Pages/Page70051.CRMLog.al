page 70051 "CRM Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CRM Log";
    SourceTableView = sorting("Datetime") order(descending);
    Caption = 'CRM Log';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }
                field("Datetime"; Rec.Datetime)
                {
                    ApplicationArea = All;

                }

                field("Object Id"; Rec."Object Id")
                {
                    ApplicationArea = All;

                }

                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;

                }


                field("Action"; Rec."Action")
                {
                    ApplicationArea = All;

                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;

                }

                field("Details Text 1"; Rec."Details Text 1")
                {
                    ApplicationArea = All;

                }

                field("Details Text 2"; Rec."Details Text 2")
                {
                    ApplicationArea = All;

                }

            }
        }
    }

    actions
    {
        area(processing)
        {
            action(DownloadObjectXml)
            {
                ApplicationArea = All;
                Caption = 'Download Object Xml';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.ExportObjectXml(true);
                end;
            }
        }
    }

}
