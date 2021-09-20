page 70071 "BW Translation Entry"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BW Translation Entry";
    Caption = 'BW Translation Entry';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                }

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;

                }


                field(Period; Rec.Period)
                {
                    ApplicationArea = All;

                }

                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;

                }

                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;

                }

                field("BW Account No."; Rec."BW Account No.")
                {
                    ApplicationArea = All;

                }

                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;

                }

                field("Cost Code"; Rec."Cost Code")
                {
                    ApplicationArea = All;

                }

                field("Cost Place"; Rec."Cost Place")
                {
                    ApplicationArea = All;

                }

                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;

                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;

                }


            }
        }
    }

}
