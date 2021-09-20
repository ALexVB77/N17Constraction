page 70253 UOMList
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
                    Caption = 'Item No.';
                    ApplicationArea = All;
                }
                field(Code; Rec.Code)
                {
                    ToolTip = 'Code';
                    Caption = ' Unit of Measure Code';
                    ApplicationArea = All;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ToolTip = 'Qty. of Base Unit of Measure';
                    Caption = 'Qty. of Base Unit of Measure';
                    ApplicationArea = All;
                }
                field(Length; Rec.Length)
                {
                    ToolTip = 'Length';
                    Caption = 'Length';
                    ApplicationArea = All;
                }
                field(Width; Rec.Width)
                {
                    ToolTip = 'Width';
                    Caption = 'Width';
                    ApplicationArea = All;
                }
                field(Weight; Rec.Weight)
                {
                    ToolTip = 'Weight';
                    Caption = 'Weight';
                    ApplicationArea = All;
                }
                field(Cubage; Rec.Cubage)
                {
                    ToolTip = 'Cubage';
                    Caption = 'Cubage';
                    ApplicationArea = All;
                }
                field(Height; Rec.Height)
                {
                    ToolTip = 'Height';
                    Caption = 'Height';
                    ApplicationArea = All;
                }
            }
        }
    }

}
