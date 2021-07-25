page 99885 "BW Translation Entry (ODATA)"
{
    PageType = API;
    Caption = 'bwTranslations', Locked = true;
    //APIPublisher = 'publisherName';
    //APIGroup = 'groupName';
    //APIVersion = 'VersionList';
    DelayedInsert = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    EntityName = 'bwTranslations';
    EntitySetName = 'bwTranslations';
    SourceTable = "BW Translation Entry";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(entryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.', Locked = true;

                }

                field(description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description', Locked = true;

                }

                field(postingDate; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date', Locked = true;

                }


                field(period; Rec.Period)
                {
                    ApplicationArea = All;
                    Caption = 'Period', Locked = true;

                }

                field(documentDate; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'Document Date', Locked = true;

                }

                field(glAccountNo; Rec."G/L Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account No.', Locked = true;

                }

                field(bwAccountNo; Rec."BW Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'BW Account No.', Locked = true;

                }

                field(sourceNo; Rec."Source No.")
                {
                    ApplicationArea = All;
                    Caption = 'Source No.', Locked = true;

                }

                field(costCode; Rec."Cost Code")
                {
                    ApplicationArea = All;
                    Caption = 'Cost Code', Locked = true;

                }

                field(costPlace; Rec."Cost Place")
                {
                    ApplicationArea = All;
                    Caption = 'Cost Place', Locked = true;

                }

                field(amount; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Amount (LCY)', Locked = true;

                }

                field(currencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Caption = 'Currency Code', Locked = true;

                }


            }
        }
    }
}
