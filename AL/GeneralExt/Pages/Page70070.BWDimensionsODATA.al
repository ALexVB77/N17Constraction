page 70070 "BW Dimensions (ODATA)"
{
    PageType = API;
    Caption = 'bwDimensions', Locked = true;
    //APIPublisher = 'publisherName';
    //APIGroup = 'groupName';
    //APIVersion = 'VersionList';
    EntityName = 'bwDimensions';
    EntitySetName = 'bwDimensions';
    SourceTable = "BW Dimension";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(type; Rec.Type)
                {
                    ApplicationArea = All;
                    Caption = 'Type', Locked = true;
                }

                field(code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Code', Locked = true;

                }
                field(name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name', Locked = true;

                }
                field(blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    Caption = 'Blocked', Locked = true;

                }
            }
        }
    }
}
