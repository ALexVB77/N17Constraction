page 70008 "Calc. Operand Subform"
{
    PageType = listpart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Calc. Gen Journal Operand";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Name; "Entry No.")
                {
                    ApplicationArea = All;

                }
            }
        }
    }



    var
        myInt: Integer;
}