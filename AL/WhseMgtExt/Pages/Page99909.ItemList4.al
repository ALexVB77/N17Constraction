page 99909 ItemList4
{

    Caption = 'Item List';
    PageType = List;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Item No';
                    Caption = 'Item No.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Item Description';
                    Caption = 'Item Description';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ToolTip = 'Unit of Measure Code';
                    Caption = 'Unit of Measure Code';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

}
