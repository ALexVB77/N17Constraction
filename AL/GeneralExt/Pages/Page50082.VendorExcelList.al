page 50082 "Vendor Excel List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Vendor Excel List';
    // CardPageID = "Purchase Order";
    DataCaptionFields = "Vendor No.";
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Vendor Excel Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vend VAT Reg No."; "Vend VAT Reg No.")
                {
                    ApplicationArea = All;
                }
                field(Date; Date)
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Agreement No."; "Agreement No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }


}