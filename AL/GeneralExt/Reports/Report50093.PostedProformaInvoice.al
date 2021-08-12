report 50093 "Posted Proforma Invoice"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = Word;
    WordLayout = './Reports/Layouts/PostedProformaInvoice.docx';

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            // column(ColumnName; SourceFieldName)
            // {

            // }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {
                    //     ApplicationArea = All;

                    // }
                }
            }
        }

        // actions
        // {
        //     area(processing)
        //     {
        //         action(ActionName)
        //         {
        //             ApplicationArea = All;

        //         }
        //     }
        // }
    }

    var
        myInt: Integer;
}