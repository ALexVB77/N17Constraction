pageextension 85050 "Contact Card (Ext)" extends "Contact Card"
{
    layout
    {
        addlast(ContactDetails)
        {
            group(PassportData)
            {
                Caption = 'Passport Data';
                field("Passport No."; Rec."Passport No.")
                {
                    ApplicationArea = All;
                }

                field("Passport Series"; Rec."Passport Series")
                {
                    ApplicationArea = All;
                }

                field("Delivery of passport"; Rec."Delivery of passport")
                {
                    ApplicationArea = All;
                }

                field(Registration; Rec.Registration)
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}
