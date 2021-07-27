page 70269 "Barcode Act Document"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Barcode Act Document';
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = NavigatePage;
    RefreshOnActivate = true;
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            group(Genaral)
            {
                Caption = 'General';
                field(DocNo; DocNo)
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowDoc)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Document';
                Enabled = DocNo <> '';
                Image = Document;

                trigger OnAction()
                begin
                    ShowDocument();
                end;
            }
            action(ReceivedAcc)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Received by Accounting';
                Enabled = DocNo <> '';
                Image = SendConfirmation;

                trigger OnAction()
                begin
                    SetReceivedAcc();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        PurchSetup: Record "Purchases & Payables Setup";
        NoSerMgt: Codeunit NoSeriesManagement;
        LocMgt: Codeunit "Localisation Management";
        NextNo: code[20];
        DPartCode: Code[20];
    begin
        PurchSetup.Get();
        PurchSetup.TestField("Act Order Nos.");
        NextNo := NoSerMgt.TryGetNextNo(PurchSetup."Act Order Nos.", WorkDate());
        DPartCode := LocMgt.DigitalPartCode(NextNo);
        DocPrefix := CopyStr(NextNo, 1, StrPos(NextNo, DPartCode) - 1);
    end;

    var
        DocNo: Code[20];
        DocPrefix: Code[20];

    local procedure FindPurchAct(var PurchHeader: Record "Purchase Header"): Boolean
    var
        Text001: Label 'Document %1 not found!';
        Text002: Label 'Incorrect Document No.!';
    begin
        IF (DocNo <> '') AND ((STRLEN(DocNo) = 6) OR (STRLEN(DocNo) = 9) OR (STRLEN(DocNo) = 13)) THEN BEGIN
            PurchHeader.RESET;
            PurchHeader.SETFILTER("Act Type", '<>%1', PurchHeader."Act Type"::" ");
            PurchHeader.SETRANGE("Document Type", PurchHeader."Document Type"::Order);
            IF STRLEN(DocNo) = 13 THEN
                PurchHeader.SETRANGE("No.", DocPrefix + COPYSTR(DocNo, 7, 6));
            IF STRLEN(DocNo) = 9 THEN
                PurchHeader.SETRANGE("No.", DocNo);
            IF STRLEN(DocNo) = 6 THEN
                PurchHeader.SETRANGE("No.", DocPrefix + DocNo);
            if PurchHeader.FindFirst() then
                exit(true)
            ELSE BEGIN
                IF STRLEN(DocNo) = 9 THEN
                    MESSAGE(Text001, DocNo);
                IF STRLEN(DocNo) = 13 THEN
                    MESSAGE(Text001, DocPrefix + COPYSTR(DocNo, 7, 6));
                IF STRLEN(DocNo) = 6 THEN
                    MESSAGE(Text001, DocPrefix + DocNo);
            END;
        END else
            message(Text002);
    end;

    local procedure ShowDocument()
    var
        PurchHeader: Record "Purchase Header";
    begin
        if FindPurchAct(PurchHeader) then
            PAGE.RUNMODAL(PAGE::"Purchase Order Act", PurchHeader);
    end;

    local procedure SetReceivedAcc()
    var
        PurchHeader: Record "Purchase Header";
        Text003: Label 'The document has been transferred to the accounting department.';
    begin
        if FindPurchAct(PurchHeader) then begin
            PurchHeader."Receive Account" := true;
            Message(Text003);
        end;
    end;

}