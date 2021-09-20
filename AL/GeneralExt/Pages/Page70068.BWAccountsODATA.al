page 70068 "BW Accounts (ODATA)"
{
    PageType = API;
    Caption = 'bwAccounts', Locked = true;
    //APIPublisher = 'publisherName';
    //APIGroup = 'groupName';
    //APIVersion = 'VersionList';
    EntityName = 'bwAccounts';
    EntitySetName = 'bwAccounts';
    SourceTable = "BW Account";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("no"; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No', Locked = true;

                }
                field("name"; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name', Locked = true;

                }

            }
        }
    }
}
