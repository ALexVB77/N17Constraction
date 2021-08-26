page 99400 "Klaz Klaz"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Test rec";
    Caption = 'Klaz Klaz', Locked = true;

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

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;

                }

            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(ExportJsonScheme)
            {
                ApplicationArea = All;
                Image = Export;
                Caption = 'ExportJsonScheme', Locked = true;

                trigger OnAction();
                var
                    cu: codeunit "CRM Object Xml to Json";
                begin
                    cu.ExportScheme();
                end;
            }
        }
    }
}
