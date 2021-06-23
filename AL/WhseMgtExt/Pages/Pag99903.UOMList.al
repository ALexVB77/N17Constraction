page 99903 UOMList
{

    Caption = 'UOMList';
    PageType = List;
    SourceTable = "Item Unit of Measure";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Item No.';
                    ApplicationArea = All;
                }
                field(Code; Rec.Code)
                {
                    ToolTip = 'Code';
                    ApplicationArea = All;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ToolTip = 'Qty. of Base Unit of Measure';
                    ApplicationArea = All;
                }
                field(Length; Rec.Length)
                {
                    ToolTip = 'Length';
                    ApplicationArea = All;
                }
                field(Width; Rec.Width)
                {
                    ToolTip = 'Width';
                    ApplicationArea = All;
                }
                field(Weight; Rec.Weight)
                {
                    ToolTip = 'Weight';
                    ApplicationArea = All;
                }
                field(Cubage; Rec.Cubage)
                {
                    ToolTip = 'Cubage';
                    ApplicationArea = All;
                }
                field(Height; Rec.Height)
                {
                    ToolTip = 'Height';
                    ApplicationArea = All;
                }
            }
        }
    }

}
