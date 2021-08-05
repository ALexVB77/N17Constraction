page 99906 ItemList2
{

    Caption = 'Item List';
    PageType = List;
    SourceTable = "Transfer Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Document No.';
                    Caption = 'Document No.';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Item No.';
                    Caption = 'Item No.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Description';
                    Caption = 'Description';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Quantity';
                    Caption = 'Quantity';
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Unit of Measure';
                    Caption = 'Unit of Measure';
                    ApplicationArea = All;
                }
            }
        }
    }

}
