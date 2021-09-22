codeunit 70027 "RequestExt Subscribers Mgt."
{

    // Table 38 "Purchase Header" (Tablextension 70600 "Purchase Header (Req)")

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Problem Document', false, false)]
    local procedure OnAfterValidateProblemDocument(Rec: Record "Purchase Header"; xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        Rec.UpdateCF();
    end;

    // Table 39 "Purchase Line" (Tablextension 70608 "Purchase Line (Req)")

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Not VAT', false, false)]
    local procedure OnBeforeValidateNotVAT(Rec: Record "Purchase Line"; xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        IF xRec."Not VAT" <> Rec."Not VAT" THEN
            Rec.CheckProductionPrjDataModify(xRec."Dimension Set ID");
    end;
}