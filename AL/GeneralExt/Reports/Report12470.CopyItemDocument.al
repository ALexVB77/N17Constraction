// NC 54882 AB: сделал проставление параметров как надо и добавил прямое перемещение
report 82470 "Copy Item Document (Ext)"
{
    Caption = 'Copy Item Document';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        // SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DocType; DocType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document Type';
                        OptionCaption = 'Receipt,Shipment,Posted Receipt,Posted Shipment,,,Posted Purchase Invoice,Posted Transfer Receipt,Posted Purchase Receipt,Posted Direct Transfer';
                        ToolTip = 'Specifies the type of the related document.';

                        trigger OnValidate()
                        begin
                            DocNo := '';
                            ValidateDocNo;
                        end;
                    }
                    field(DocNo; DocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of the related document.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupDocNo;
                        end;

                        trigger OnValidate()
                        begin
                            ValidateDocNo;
                        end;
                    }
                    field(IncludeHeader; IncludeHeader)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Header';
                        ToolTip = 'Specifies if you want to copy information from the document header you are copying.';
                        // NC 51415 > EP, 54882 AB
                        Enabled = IncludeHeaderEnabled;
                        // NC 51415 < EP, 54882 AB

                        trigger OnValidate()
                        begin
                            ValidateIncludeHeader;
                        end;
                    }
                    field(RecalculateLines; RecalculateLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Recalculate Lines';
                        ToolTip = 'Specifies that lines are recalculate and inserted on the document you are creating. The batch job retains the item numbers and item quantities but recalculates the amounts on the lines based on the customer information on the new document header.';
                        // NC 51415 > EP, 54882 AB
                        Enabled = RecalculateLinesEnabled;
                        // NC 51415 < EP, 54882 AB

                        trigger OnValidate()
                        begin
                            // NC 54882 AB >>
                            // RecalculateLines := true;
                            // NC 54882 AB <<
                        end;
                    }
                    field(AutoFillAppliesFields; AutoFillAppliesFields)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Specify appl. entries';
                        // NC 51415 > EP
                        Enabled = AutoFillAppliesFieldsEnabled;
                        // NC 51415 < EP
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if DocNo <> '' then begin
                case DocType of
                    DocType::Receipt:
                        if FromItemDocHeader.Get(FromItemDocHeader."Document Type"::Receipt, DocNo) then
                            ;
                    DocType::Shipment:
                        if FromItemDocHeader.Get(FromItemDocHeader."Document Type"::Shipment, DocNo) then
                            ;
                    DocType::"Posted Receipt":
                        if FromItemRcptHeader.Get(DocNo) then
                            FromItemDocHeader.TransferFields(FromItemRcptHeader);
                    DocType::"Posted Shipment":
                        if FromItemShptHeader.Get(DocNo) then
                            FromItemDocHeader.TransferFields(FromItemShptHeader);
                    // NC 54882 AB >>
                    DocType::PostPurchInvoice:
                        if FromPurchInvHeader.Get(DocNo) then
                            ;
                    DocType::PostTransferRcpt:
                        if FromTransferRcptHdr.Get(DocNo) then
                            ;
                    DocType::PostPurchReceipt:
                        if FromPurchRcptHeader.Get(DocNo) then
                            ;
                    DocType::PostDirTransfer:
                        if FromDirTransHeader.Get(DocNo) then
                            ;
                // NC 54882 AB <<
                end;
                if FromItemDocHeader."No." = '' then
                    DocNo := '';
            end;
            ValidateDocNo;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        // NC 54882 AB >>
        if ProcessAddDocTypes then
            CurrReport.Break();
        // NC 54882 AB <<

        CopyItemDocMgt.SetProperties(IncludeHeader, RecalculateLines, false, false, AutoFillAppliesFields);
        CopyItemDocMgt.CopyItemDoc(DocType, DocNo, ItemDocHeader)
    end;

    var
        ItemDocHeader: Record "Item Document Header";
        FromItemDocHeader: Record "Item Document Header";
        FromItemRcptHeader: Record "Item Receipt Header";
        FromItemShptHeader: Record "Item Shipment Header";
        CopyItemDocMgt: Codeunit "Copy Item Document Mgt.";
        DocType: Option Receipt,Shipment,"Posted Receipt","Posted Shipment",,,"PostPurchInvoice","PostTransferRcpt","PostPurchReceipt","PostDirTransfer";
        DocNo: Code[20];
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;
        AutoFillAppliesFields: Boolean;
        LastLineNo: Integer;

        // NC 51415 EP, 54882 AB:
        ItemDocLine: Record "Item Document Line";
        FromPurchInvHeader: Record "Purch. Inv. Header";
        FromPurchInvLine: Record "Purch. Inv. Line";
        FromTransferRcptHdr: Record "Transfer Receipt Header";
        FromTransferRcptLine: Record "Transfer Receipt Line";
        FromPurchRcptHeader: Record "Purch. Rcpt. Header";
        FromPurchRcptLine: Record "Purch. Rcpt. Line";
        FromDirTransHeader: Record "Direct Transfer Header";
        FromDirTransLine: Record "Direct Transfer Line";

        IncludeHeaderEnabled, RecalculateLinesEnabled, AutoFillAppliesFieldsEnabled : boolean;

    [Scope('OnPrem')]
    procedure SetItemDocHeader(var NewItemDocHeader: Record "Item Document Header")
    begin
        ItemDocHeader := NewItemDocHeader;
    end;

    local procedure ValidateDocNo()
    begin
        if DocNo = '' then
            FromItemDocHeader.Init
        else
            if FromItemDocHeader."No." = '' then begin
                FromItemDocHeader.Init();
                case DocType of
                    DocType::Receipt, DocType::Shipment:
                        FromItemDocHeader.Get(DocType, DocNo);
                    DocType::"Posted Receipt":
                        begin
                            FromItemRcptHeader.Get(DocNo);
                            FromItemDocHeader.TransferFields(FromItemRcptHeader);
                        end;
                    DocType::"Posted Shipment":
                        begin
                            FromItemShptHeader.Get(DocNo);
                            FromItemDocHeader.TransferFields(FromItemShptHeader);
                        end;
                    // NC 54882 AB >>
                    DocType::PostPurchInvoice:
                        FromPurchInvHeader.Get(DocNo);
                    DocType::PostTransferRcpt:
                        FromTransferRcptHdr.Get(DocNo);
                    DocType::PostPurchReceipt:
                        FromPurchRcptHeader.Get(DocNo);
                    DocType::PostDirTransfer:
                        FromDirTransHeader.Get(DocNo);
                // NC 54882 AB <<
                end;
            end;
        FromItemDocHeader."No." := '';

        IncludeHeader := true;

        // NC 51415 > EP, 54882 AB
        IncludeHeader := DocType <= DocType::"Posted Shipment";
        IncludeHeaderEnabled := DocType <= DocType::"Posted Shipment";
        // NC 51415 < EP, 54882 AB

        ValidateIncludeHeader;
    end;

    local procedure LookupDocNo()
    begin
        case DocType of
            DocType::Receipt,
            DocType::Shipment:
                begin
                    FromItemDocHeader.FilterGroup := 2;
                    FromItemDocHeader.SetRange("Document Type", DocType);
                    if ItemDocHeader."Document Type" = DocType then
                        FromItemDocHeader.SetFilter("No.", '<>%1', ItemDocHeader."No.");
                    FromItemDocHeader.FilterGroup := 0;
                    FromItemDocHeader."Document Type" := DocType;
                    FromItemDocHeader."No." := DocNo;
                    if DocType = DocType::Receipt then begin
                        if PAGE.RunModal(PAGE::"Item Receipts", FromItemDocHeader, FromItemDocHeader."No.") = ACTION::LookupOK then
                            DocNo := FromItemDocHeader."No.";
                    end else begin
                        if PAGE.RunModal(PAGE::"Item Shipments", FromItemDocHeader, FromItemDocHeader."No.") = ACTION::LookupOK then
                            DocNo := FromItemDocHeader."No.";
                    end;
                end;
            DocType::"Posted Receipt":
                begin
                    FromItemRcptHeader."No." := DocNo;
                    if PAGE.RunModal(0, FromItemRcptHeader) = ACTION::LookupOK then
                        DocNo := FromItemRcptHeader."No.";
                end;
            DocType::"Posted Shipment":
                begin
                    FromItemShptHeader."No." := DocNo;
                    if PAGE.RunModal(0, FromItemShptHeader) = ACTION::LookupOK then
                        DocNo := FromItemShptHeader."No.";
                end;

            // NC 51415 > EP, 54882 AB
            DocType::PostPurchInvoice:
                BEGIN
                    FromPurchInvHeader."No." := DocNo;
                    IF Page.RUNMODAL(0, FromPurchInvHeader) = ACTION::LookupOK THEN
                        DocNo := FromPurchInvHeader."No.";
                END;
            DocType::PostTransferRcpt:
                BEGIN
                    FromTransferRcptHdr."No." := DocNo;
                    IF Page.RUNMODAL(0, FromTransferRcptHdr) = ACTION::LookupOK THEN
                        DocNo := FromTransferRcptHdr."No.";
                END;
            DocType::PostPurchReceipt:
                BEGIN
                    FromPurchRcptHeader."No." := DocNo;
                    IF Page.RUNMODAL(0, FromPurchRcptHeader) = ACTION::LookupOK THEN
                        DocNo := FromPurchRcptHeader."No.";
                END;
            DocType::PostDirTransfer:
                BEGIN
                    FromDirTransHeader."No." := DocNo;
                    IF Page.RUNMODAL(0, FromDirTransHeader) = ACTION::LookupOK THEN
                        DocNo := FromDirTransHeader."No.";
                END;
        // NC 51415 > EP, 54882 AB
        end;
        ValidateDocNo;
    end;

    local procedure ValidateIncludeHeader()
    begin
        RecalculateLines :=
          not IncludeHeader;

        // NC 51415 > EP, 54882 AB
        RecalculateLinesEnabled := true;
        AutoFillAppliesFieldsEnabled := true;
        if DocType > DocType::"Posted Shipment" then begin
            RecalculateLines := false;
            RecalculateLinesEnabled := false;
            AutoFillAppliesFieldsEnabled := false;
        end else
            if (ItemDocHeader."Document Type" = ItemDocHeader."Document Type"::Shipment) or
               (DocType in [DocType::Shipment, DocType::"Posted Shipment"])
            then begin
                RecalculateLines := true;
                RecalculateLinesEnabled := false;
            end;
        // NC 51415 < EP, 54882 AB
    end;

    local procedure ProcessAddDocTypes(): Boolean
    begin
        // NC 51415 > EP, 54882 AB
        case DocType of
            DocType::PostTransferRcpt:
                begin
                    if FromTransferRcptHdr."Transfer-to Code" <> '' then
                        ItemDocHeader.VALIDATE("Location Code", FromTransferRcptHdr."Transfer-to Code");
                    ItemDocHeader.VALIDATE("Shortcut Dimension 1 Code", FromTransferRcptHdr."Shortcut Dimension 1 Code");
                    ItemDocHeader.VALIDATE("Shortcut Dimension 2 Code", FromTransferRcptHdr."Shortcut Dimension 2 Code");
                    ItemDocHeader.MODIFY(TRUE);

                    LastLineNo := 0;
                    ItemDocLine.RESET;
                    ItemDocLine.SETRANGE("Document Type", ItemDocHeader."Document Type");
                    ItemDocLine.SETRANGE("Document No.", ItemDocHeader."No.");
                    IF ItemDocLine.FINDLAST THEN
                        LastLineNo := ItemDocLine."Line No.";

                    FromTransferRcptLine.RESET;
                    FromTransferRcptLine.SETRANGE("Document No.", FromTransferRcptHdr."No.");
                    IF FromTransferRcptLine.FINDSET THEN
                        REPEAT
                            LastLineNo += 10000;

                            ItemDocLine.INIT;
                            ItemDocLine."Document Type" := ItemDocHeader."Document Type";
                            ItemDocLine."Document No." := ItemDocHeader."No.";
                            ItemDocLine."Line No." := LastLineNo;
                            ItemDocLine.INSERT(TRUE);

                            ItemDocLine.VALIDATE("Item No.", FromTransferRcptLine."Item No.");
                            ItemDocLine.VALIDATE("Location Code", FromTransferRcptLine."Transfer-to Code");
                            ItemDocLine.VALIDATE("Shortcut Dimension 1 Code", FromTransferRcptLine."Shortcut Dimension 1 Code");
                            ItemDocLine.VALIDATE("Shortcut Dimension 2 Code", FromTransferRcptLine."Shortcut Dimension 2 Code");
                            ItemDocLine.VALIDATE(Quantity, FromTransferRcptLine.Quantity);
                            ItemDocLine.VALIDATE("Unit of Measure Code", FromTransferRcptLine."Unit of Measure Code");
                            ItemDocLine.VALIDATE(Description, FromTransferRcptLine.Description);
                            ItemDocLine.MODIFY(TRUE);

                            CopyDims(ItemDocLine, FromTransferRcptLine."Dimension Set ID");
                        UNTIL FromTransferRcptLine.NEXT = 0;
                end;
            DocType::PostPurchReceipt:
                begin
                    ItemDocHeader."Posting Date" := FromPurchRcptHeader."Posting Date";
                    ItemDocHeader."Document Date" := FromPurchRcptHeader."Posting Date";

                    if FromPurchRcptHeader."Location Code" <> '' then
                        ItemDocHeader.Validate("Location Code", FromPurchRcptHeader."Location Code");
                    ItemDocHeader.VALIDATE("Shortcut Dimension 1 Code", FromPurchRcptHeader."Shortcut Dimension 1 Code");
                    ItemDocHeader.VALIDATE("Shortcut Dimension 2 Code", FromPurchRcptHeader."Shortcut Dimension 2 Code");
                    ItemDocHeader.MODIFY(TRUE);

                    LastLineNo := 0;
                    ItemDocLine.RESET;
                    ItemDocLine.SETRANGE("Document Type", ItemDocHeader."Document Type");
                    ItemDocLine.SETRANGE("Document No.", ItemDocHeader."No.");
                    IF ItemDocLine.FINDLAST THEN
                        LastLineNo := ItemDocLine."Line No.";

                    FromPurchRcptLine.RESET;
                    FromPurchRcptLine.SETRANGE("Document No.", FromPurchRcptHeader."No.");
                    IF FromPurchRcptLine.FINDSET THEN
                        REPEAT
                            LastLineNo += 10000;

                            ItemDocLine.INIT;
                            ItemDocLine."Document Type" := ItemDocHeader."Document Type";
                            ItemDocLine."Document No." := ItemDocHeader."No.";
                            ItemDocLine."Line No." := LastLineNo;
                            ItemDocLine.INSERT(TRUE);

                            ItemDocLine.VALIDATE("Item No.", FromPurchRcptLine."No.");
                            ItemDocLine.VALIDATE("Location Code", FromPurchRcptLine."Location Code");
                            ItemDocLine.VALIDATE("Shortcut Dimension 1 Code", FromPurchRcptLine."Shortcut Dimension 1 Code");
                            ItemDocLine.VALIDATE("Shortcut Dimension 2 Code", FromPurchRcptLine."Shortcut Dimension 2 Code");
                            ItemDocLine.VALIDATE(Quantity, FromPurchRcptLine.Quantity);
                            ItemDocLine.VALIDATE("Unit of Measure Code", FromPurchRcptLine."Unit of Measure Code");
                            ItemDocLine.VALIDATE(Description, FromPurchRcptLine.Description);

                            ItemDocLine.VALIDATE("Unit Amount", FromPurchRcptLine."Direct Unit Cost");
                            ItemDocLine.VALIDATE("Unit Cost", FromPurchRcptLine."Direct Unit Cost");
                            ItemDocLine.VALIDATE("Applies-from Entry", FromPurchRcptLine."Item Rcpt. Entry No.");
                            ItemDocLine.MODIFY(TRUE);

                            CopyDims(ItemDocLine, FromPurchRcptLine."Dimension Set ID");
                        UNTIL FromPurchRcptLine.NEXT = 0;
                end;
            DocType::PostPurchInvoice:
                begin
                    ItemDocHeader."Location Code" := FromPurchInvHeader."Location Code";
                    ItemDocHeader."Posting Date" := FromPurchInvHeader."Posting Date";
                    ItemDocHeader."Document Date" := FromPurchInvHeader."Posting Date";
                    ItemDocHeader.VALIDATE("Shortcut Dimension 1 Code", FromPurchInvHeader."Shortcut Dimension 1 Code");
                    ItemDocHeader.MODIFY;

                    ItemDocLine.RESET;
                    ItemDocLine.SETRANGE("Document Type", ItemDocHeader."Document Type");
                    ItemDocLine.SETRANGE("Document No.", ItemDocHeader."No.");
                    IF NOT (ItemDocLine.FINDLAST) THEN
                        ItemDocLine."Line No." := 0;
                    LastLineNo := ItemDocLine."Line No.";

                    FromPurchInvLine.RESET;
                    FromPurchInvLine.SETRANGE("Document No.", FromPurchInvHeader."No.");
                    FromPurchInvLine.SETRANGE(Type, FromPurchInvLine.Type::Item);
                    IF FromPurchInvLine.FINDSET THEN
                        REPEAT
                            ItemDocLine.INIT;
                            ItemDocLine."Document Type" := ItemDocHeader."Document Type";
                            ItemDocLine."Document No." := ItemDocHeader."No.";
                            LastLineNo += 10000;
                            ItemDocLine."Line No." := LastLineNo;
                            ItemDocLine.VALIDATE("Item No.", FromPurchInvLine."No.");
                            ItemDocLine.INSERT(TRUE);
                            ItemDocLine.VALIDATE("Location Code", FromPurchInvLine."Location Code");
                            ItemDocLine.VALIDATE(Quantity, FromPurchInvLine.Quantity);

                            //?
                            /*ValueEntry.RESET;
                            ValueEntry.SETRANGE("Document No.", FromPurchInvLine."Document No.");
                            ValueEntry.SETRANGE("Document Line No.", FromPurchInvLine."Line No.");
                            ValueEntry.SETRANGE("Posting Date", FromPurchInvHeader."Posting Date");
                            ValueEntry.FINDFIRST;
                            ItemDocLine."Applies-to Entry" := ValueEntry."Item Ledger Entry No.";*/
                            //?

                            ItemDocLine.VALIDATE("Shortcut Dimension 1 Code", FromPurchInvLine."Shortcut Dimension 1 Code");
                            ItemDocLine.VALIDATE("Shortcut Dimension 2 Code", FromPurchInvLine."Shortcut Dimension 2 Code");
                            ItemDocLine.VALIDATE("Unit of Measure Code", FromPurchInvLine."Unit of Measure Code");
                            ItemDocLine.VALIDATE("Unit Amount", FromPurchInvLine."Direct Unit Cost");
                            ItemDocLine.VALIDATE("Unit Cost", FromPurchInvLine."Direct Unit Cost");
                            ItemDocLine.Description := FromPurchInvLine.Description;
                            ItemDocLine.MODIFY;

                            CopyDims(ItemDocLine, FromPurchInvLine."Dimension Set ID");
                        UNTIL FromPurchInvLine.NEXT = 0;

                end;
            DocType::PostDirTransfer:
                begin
                    if FromDirTransHeader."Transfer-to Code" <> '' then
                        ItemDocHeader.VALIDATE("Location Code", FromDirTransHeader."Transfer-to Code");
                    ItemDocHeader.VALIDATE("Shortcut Dimension 1 Code", FromDirTransHeader."Shortcut Dimension 1 Code");
                    ItemDocHeader.VALIDATE("Shortcut Dimension 2 Code", FromDirTransHeader."Shortcut Dimension 2 Code");
                    ItemDocHeader.MODIFY(TRUE);

                    LastLineNo := 0;
                    ItemDocLine.RESET;
                    ItemDocLine.SETRANGE("Document Type", ItemDocHeader."Document Type");
                    ItemDocLine.SETRANGE("Document No.", ItemDocHeader."No.");
                    IF ItemDocLine.FINDLAST THEN
                        LastLineNo := ItemDocLine."Line No.";

                    FromDirTransLine.RESET;
                    FromDirTransLine.SETRANGE("Document No.", FromDirTransHeader."No.");
                    IF FromDirTransLine.FINDSET THEN
                        REPEAT
                            LastLineNo += 10000;

                            ItemDocLine.INIT;
                            ItemDocLine."Document Type" := ItemDocHeader."Document Type";
                            ItemDocLine."Document No." := ItemDocHeader."No.";
                            ItemDocLine."Line No." := LastLineNo;
                            ItemDocLine.INSERT(TRUE);

                            ItemDocLine.VALIDATE("Item No.", FromDirTransLine."Item No.");
                            ItemDocLine.VALIDATE("Location Code", FromDirTransLine."Transfer-to Code");
                            ItemDocLine.VALIDATE("Shortcut Dimension 1 Code", FromDirTransLine."Shortcut Dimension 1 Code");
                            ItemDocLine.VALIDATE("Shortcut Dimension 2 Code", FromDirTransLine."Shortcut Dimension 2 Code");
                            ItemDocLine.VALIDATE(Quantity, FromDirTransLine.Quantity);
                            ItemDocLine.VALIDATE("Unit of Measure Code", FromDirTransLine."Unit of Measure Code");
                            ItemDocLine.VALIDATE(Description, FromDirTransLine.Description);
                            ItemDocLine.MODIFY(TRUE);

                            CopyDims(ItemDocLine, FromDirTransLine."Dimension Set ID");
                        UNTIL FromDirTransLine.NEXT = 0;
                end;
            else
                exit(false);
        end;
        exit(true);
        // NC 51415 < EP, 54882 AB
    end;

    local procedure CopyDims(var idl: Record "Item Document Line"; srcDimSetId: integer)
    var
        dimSetIds: array[10] of Integer;
        dimMgt: Codeunit DimensionManagement;
    begin
        clear(dimSetIds);
        dimSetIds[1] := idl."Dimension Set ID";
        dimSetIds[2] := srcDimSetId;
        idl."Dimension Set ID" := dimMgt.GetCombinedDimensionSetID(dimSetIds, idl."Shortcut Dimension 1 Code", idl."Shortcut Dimension 2 Code");
        idl.modify(true);
    end;
}

