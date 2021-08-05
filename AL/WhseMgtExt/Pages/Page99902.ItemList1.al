page 99902 ItemList1
{

    Caption = 'Item List';
    PageType = List;
    SourceTable = "Purchase Line";

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
                field("No."; Rec."No.")
                {
                    ToolTip = 'Item No.';
                    Caption = 'Item No';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Description';
                    CAption = 'Description';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Quantity';
                    CAption = 'Quantity';
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Unit of Measure';
                    CAption = 'Unit of Measure';
                    ApplicationArea = All;
                }
            }
        }
    }

}
