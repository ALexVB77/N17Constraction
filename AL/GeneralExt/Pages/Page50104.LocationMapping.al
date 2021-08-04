page 50104 "Location Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Location Mapping";
    Caption = 'Location Mapping';

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("New Location Code"; Rec."New Location Code")
                {
                    ApplicationArea = All;
                }
                field("Old Location Code"; Rec."Old Location Code")
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
            action(ImportLocationMapping)
            {
                ApplicationArea = All;
                Caption = 'Import Location Mapping';
                Image = ImportExcel;

                trigger OnAction()
                var
                    DataMigration: Report "Data Migration From Excel";
                begin
                    DataMigration.RunModal();
                end;
            }
        }
    }
}