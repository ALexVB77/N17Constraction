page 70050 "CRM Integration Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CRM Integration Setup";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Primary Key"; Rec."Primary Key")
                {
                    ApplicationArea = All;

                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;

                }

                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;

                }

                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;

                }

            }
        }
        area(Factboxes)
        {

        }
    }

}
