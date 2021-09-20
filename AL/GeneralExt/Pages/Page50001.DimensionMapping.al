page 50001 "Dimension Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Dimension Mapping";
    Caption = 'Dimension Mapping';

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = All;
                }
                field("New Dimension Value Code"; Rec."New Dimension Value Code")
                {
                    ApplicationArea = All;
                }
                field("Old Dimension Value Code"; Rec."Old Dimension Value Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
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
            action(ImportDimensionMapping)
            {
                ApplicationArea = All;
                Caption = 'Import Dimension Mapping';
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