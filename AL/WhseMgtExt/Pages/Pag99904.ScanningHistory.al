page 99904 ScanningHistory
{

    Caption = 'ScanningHistory';
    PageType = List;
    SourceTable = "Item Scanning Entry";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Active; Rec.Active)
                {
                    ToolTip = 'Active';
                    ApplicationArea = All;
                }
                field(Barcode; Rec.Barcode)
                {
                    ToolTip = 'Barcode';
                    ApplicationArea = All;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Document Line No.';
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Document No.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Entry No.';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Entry Type';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Item No.';
                    ApplicationArea = All;
                }
                field(ManualInsQty; Rec.ManualInsQty)
                {
                    ToolTip = 'Manual Insert';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Quantity';
                    ApplicationArea = All;
                }
                field("Quantity(Base)"; Rec."Quantity(Base)")
                {
                    ToolTip = 'quantity(Base)';
                    ApplicationArea = All;
                }
                field(RealScan; Rec.RealScan)
                {
                    ToolTip = 'Real Scanning';
                    ApplicationArea = All;
                }
                field(SplitWithEntry; Rec.SplitWithEntry)
                {
                    ToolTip = 'Split With Entry';
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Unit of Measure';
                    ApplicationArea = All;
                }
                field(UserID; Rec.UserID)
                {
                    ToolTip = 'User ID';
                    ApplicationArea = All;
                }
            }
        }
    }

}
