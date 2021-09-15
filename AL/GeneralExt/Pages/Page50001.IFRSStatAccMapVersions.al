page 50001 "IFRS Stat. Acc. Map. Versions"
{
    //ApplicationArea = Basic, Suite;
    Caption = 'IFRS Stat. Acc. Map. Versions';
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "IFRS Stat. Acc. Map. Vers.";
    //UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
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
            group("Mapping Version")
            {
                Caption = 'Mapping Version';
                Image = Versions;
                action(VersionLines)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Version Lines';
                    Image = AllLines;

                    trigger OnAction()
                    var
                        MapVersLines: Page "IFRS Stat. Acc. Map. Vers.Line";
                    begin
                        MapVersLines.SetParam("IFRS Stat. Acc. Mapping Code", Code);
                        MapVersLines.Run();
                    end;
                }
            }
        }
    }
}