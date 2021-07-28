pageextension 85741 "Transfer Order Subform (Ext)" extends "Transfer Order Subform"
{
    layout
    {
        // NC 51410 > EP
        modify("Shortcut Dimension 1 Code")
        {
            Visible = DimVisible1;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Visible = DimVisible2;
        }
        modify("ShortcutDimCode[3]")
        {
            Visible = DimVisible3;
        }
        modify("ShortcutDimCode[4]")
        {
            Visible = DimVisible4;
        }
        modify("ShortcutDimCode[5]")
        {
            Visible = DimVisible5;
        }
        modify("ShortcutDimCode[6]")
        {
            Visible = DimVisible6;
        }
        modify("ShortcutDimCode[7]")
        {
            Visible = DimVisible7;
        }
        modify("ShortcutDimCode[8]")
        {
            Visible = DimVisible8;
        }
        // NC 51410 < EP
    }
}