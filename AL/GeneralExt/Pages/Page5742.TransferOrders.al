pageextension 85742 "Transfer Orders (Ext)" extends "Transfer Orders"
{
    trigger OnOpenPage()
    var
        TransferHeader: Record "Transfer Header";
    begin
        // NC 51410 > EP
        // Список передач материалов в переработку ("Giv. Type"::"To Contractor")
        // отображается в отдельном page "Giv. Transfer Orders"
        TransferHeader.SetRange("Giv. Type", TransferHeader."Giv. Type"::Internal);
        CurrPage.SetTableView(TransferHeader);
        // NC 51410 < EP
    end;
}