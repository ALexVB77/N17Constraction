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
                field(Barcode; Rec.Barcode)
                {
                    ToolTip = 'Barcode';
                    Caption = 'Barcode';
                    ApplicationArea = All;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Document Line No.';
                    Caption = 'Document Line No.';
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Document No.';
                    Caption = 'Document No.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Entry No.';
                    Caption = 'Entry No.';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Entry Type';
                    Caption = 'Entry Type';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Item No.';
                    Caption = 'Item No.';
                    ApplicationArea = All;
                }
                field(ManualInsQty; Rec.ManualInsQty)
                {
                    ToolTip = 'Manual Insert';
                    Caption = 'Manual Insert';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Quantity';
                    Caption = 'Quantity';
                    ApplicationArea = All;
                }
                field("Quantity(Base)"; Rec."Quantity(Base)")
                {
                    ToolTip = 'quantity(Base)';
                    Caption = 'Quantity(Base)';
                    ApplicationArea = All;
                }
                field(RealScan; Rec.RealScan)
                {
                    ToolTip = 'Real Scanning';
                    Caption = 'Real Scanning';
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Unit of Measure';
                    Caption = 'Unit of Measure';
                    ApplicationArea = All;
                }
                field(UserID; Rec.UserID)
                {
                    ToolTip = 'User ID';
                    Caption = 'User ID';
                    ApplicationArea = All;
                }
            }
        }
    }

}
