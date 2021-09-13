page 50000 "IFRS Statutory Account Mapping"
{
    ApplicationArea = Basic, Suite;
    Caption = 'IFRS Statutory Account Mappings';
    PageType = List;
    SourceTable = "IFRS Statutory Account Mapping";
    UsageCategory = Lists;

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
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Accounts Mapping")
            {
                Caption = 'Accounts Mapping';
                Image = MapAccounts;
                action(Versions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Versions';
                    Image = Versions;
                    RunObject = Page "IFRS Stat. Acc. Map. Versions";
                    RunPageLink = "IFRS Stat. Acc. Mapping Code" = field(Code);
                }
            }
        }
    }
}
