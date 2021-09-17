page 70260 ChooseMatDel
{

    Caption = 'Selection of materials for the BC document';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(TransferOrder; TransferOrder)
                {
                    ApplicationArea = All;
                    ToolTip = 'Transfer Order';
                    Caption = 'Transfer Order';
                    trigger OnValidate()
                    begin
                        IF TransferOrder = TRUE THEN BEGIN
                            MaterialOrder := FALSE;
                            Writeoff := FALSE;
                        END;
                    end;
                }
                field(MaterialOrder; MaterialOrder)
                {
                    ApplicationArea = All;
                    ToolTip = ' Material Order';
                    Caption = 'Transfer of materials for recycling';
                    trigger OnValidate()
                    begin
                        IF MaterialOrder = TRUE THEN BEGIN
                            TransferOrder := FALSE;
                            Writeoff := FALSE;
                        END;
                    end;
                }
                field(Writeoff; Writeoff)
                {
                    ApplicationArea = All;
                    ToolTip = 'Write- off materials';
                    Caption = 'Write- off materials';
                    trigger OnValidate()
                    begin
                        IF Writeoff = TRUE THEN BEGIN
                            TransferOrder := FALSE;
                            MaterialOrder := FALSE;
                        END;
                    end;
                }
            }
        }
    }
    var
        TransferScanPage: Page "Transfer Scanning List";
        TransferOrder: Boolean;
        MaterialOrder: Boolean;
        Writeoff: Boolean;
        WriteoffScanPage: Page "Writeoff Scanning List";

    trigger OnClosePage()
    begin
        IF TransferOrder THEN
            TransferScanPage.RUNMODAL;
        IF Writeoff THEN
            WriteoffScanPage.RUNMODAL;
        IF MaterialOrder THEN
            TransferScanPage.RUNMODAL;
    end;
}
