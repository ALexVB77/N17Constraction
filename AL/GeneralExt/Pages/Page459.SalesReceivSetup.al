pageextension 80459 "Sales & Receiv. Setup (Ext)" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(General)
        {
            field("CRM Worker Code"; Rec."CRM Worker Code")
            {
                ApplicationArea = Basic, Suite;
            }
        }

        addafter("Symbol for PD Doc.")
        {
            field("Prepay. Inv. G/L Acc. No. (ac)"; "Prepay. Inv. G/L Acc. No. (ac)")
            {
                ApplicationArea = All;
            }
        }
        addlast(Dimensions)
        {
            field("Cost Place Dimension"; Rec."Cost Place Dimension")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Taxable Period Dimension"; Rec."Taxable Period Dimension")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Tax Acc. View Dimension"; Rec."Tax Acc. View Dimension")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Tax Acc. Object Dimension"; Rec."Tax Acc. Object Dimension")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Inform Cust. Payment"; Rec."Inform Cust. Payment")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addlast(Templates)
        {
            field("Order Prof-Inv. Template Code"; Rec."Posted Prof-Inv. Template Code")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

}
