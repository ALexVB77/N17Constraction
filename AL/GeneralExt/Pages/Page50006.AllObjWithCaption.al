page 50006 "AllObjWithCaption"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'AllObjWithCaption';
    Editable = false;
    PageType = List;
    SourceTable = AllObjWithCaption;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                }
                field("Object Caption"; "Object Caption")
                {
                    ApplicationArea = All;
                }
                field("Object Subtype"; "Object Subtype")
                {
                    ApplicationArea = All;
                }
                field("App Package ID"; "App Package ID")
                {
                    ApplicationArea = All;
                }
                field("App Runtime Package ID"; "App Runtime Package ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
