pageextension 80460 "Purchases & Payab. Setup (Ext)" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("M-4 Template Code")
        {
            field("Vendor Agreement Template Code"; Rec."Vendor Agreement Template Code")
            {
                ApplicationArea = All;
            }
            field("Check Vend. Agr. Template Code"; Rec."Check Vend. Agr. Template Code")
            {
                ApplicationArea = All;
            }
            field("Aged Accounts Payable Template Code"; Rec."Aged Acc. Payable Tmplt Code")
            {
                ApplicationArea = All;
            }
        }
        addlast("Number Series")
        {
            field("Payment Request Nos."; Rec."Payment Request Nos.")
            {
                ApplicationArea = All;
            }
            field("Act Order Nos."; Rec."Act Order Nos.")
            {
                ApplicationArea = All;
            }
        }
        addlast("content")
        {
            group("Payment requests")
            {
                Caption = 'Payment requests';
                field("Base Vendor No."; Rec."Base Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Base Resp. Employee No."; "Base Resp. Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = "Responsible Employees";
                }
                field("Default Estimator"; Rec."Default Estimator")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Master Approver (Development)"; "Master Approver (Development)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Master Approver (Production)"; "Master Approver (Production)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Master Approver (Department)"; "Master Approver (Department)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Delay Period"; Rec."Payment Delay Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cost Place Dimension"; Rec."Cost Place Dimension")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cost Code Dimension"; Rec."Cost Code Dimension")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Address Dimension"; "Address Dimension")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Zero VAT Prod. Posting Group"; Rec."Zero VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Default Payment Assignment"; Rec."Default Payment Assignment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Calendar Tmpl"; Rec."Payment Calendar Tmpl")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Calendar Batch"; Rec."Payment Calendar Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Frame Agreement Group"; "Frame Agreement Group")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Skip Check CF in Doc. Lines"; "Skip Check CF in Doc. Lines")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Prices Incl. VAT in Req. Doc."; "Prices Incl. VAT in Req. Doc.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}