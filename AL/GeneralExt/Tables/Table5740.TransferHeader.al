tableextension 85740 "Transfer Header (Ext)" extends "Transfer Header"
{
    // Подписки в cu 50006 
    fields
    {

        modify("In-Transit Code")
        {
            trigger OnAfterValidate()
            var
                Location: Record Location;
            begin
                // NC 51143 > EP
                // Перенес модификацию из OnValidate().
                /* Комментарий:
                    В оригинале кастомный код лежит в середине триггера - после вызова TestStatusOpen() и до UpdateTransLines().
                    Однако в UpdateTransLines() заполняемое поле "Gen. Bus. Posting Group" никак не используется
                    (к нему обращаются только в функциях учета документа),
                    поэтому можно спокойно перенести кастом в OnAfterValidate() - от этого ничего не сломается.
                */

                //NC 22512 > DP
                if Location.Get("In-Transit Code") then
                    Rec.Validate("Gen. Bus. Posting Group", Location."Def. Gen. Bus. Posting Group")
                else
                    Rec.Validate("Gen. Bus. Posting Group", '');
                //NC 22512 < DP

                // NC 51143 < EP
            end;
        }
        field(50000; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer No.';
            TableRelation = "Customer";
        }
        field(50001; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(50002; "New Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            CaptionClass = '1,2,1,New ';
            trigger OnValidate()

            begin
                NewSaveDocDim(1, "New Shortcut Dimension 1 Code");   //NCC002 CITRU\ROMB 10.01.12  inserted
                UpdateTransLines(Rec, FIELDNO("New Shortcut Dimension 1 Code")); // NC 51144 GG

            end;
        }
        field(50003; "New Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'New Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            CaptionClass = '1,2,2,New ';
            trigger OnValidate()

            begin
                NewSaveDocDim(2, "New Shortcut Dimension 2 Code");   //NCC002 CITRU\ROMB 10.01.12  inserted
                UpdateTransLines(Rec, FIELDNO("New Shortcut Dimension 2 Code")); // NC 51144 GG
            end;
        }

        field(50010; "Vendor No."; Code[50])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin

                // SWC816 AK 200416 >>
                VALIDATE("Agreement No.", '');
                UpdateTransLines(Rec, FIELDNO("Vendor No."));
                // SWC816 AK 200416 <<

            end;
        }
        field(50011; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            TableRelation = "Vendor Agreement"."No." WHERE("Vendor No." = FIELD("Vendor No."));
            DataClassification = CustomerContent;
        }

        field(50012; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Editable = false;
        }
        field(50020; "Gen. Bus. Posting Group"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }

        field(50481; "New Dimension Set Id"; Integer)
        {
            Caption = 'New Dimension Set Id';
            TableRelation = "Dimension Set Entry";
            Editable = false;
        }
        field(50482; "Giv. Type"; Enum "Transfer Header Giv. Type")
        {
            Caption = 'Giv. Type';
            Editable = false;
            DataClassification = CustomerContent;
            Description = 'NC 51410 EP';
        }
    }

    var
        hasInventorySetup: Boolean;
        invtSetup: Record "Inventory Setup";

    procedure GetInventoryLines()
    var
        myInt: Integer;
        Text60001: Label 'For following ILE Remaining Qty is greater than Open Qty =  Remaining Qty - Tracked Qty - Reserved Qty. Only lines with open Quantities are transferred to Order.';
        Text60002: Label 'ILE No. %1, Remaining Qty %2, Open Qty %3';
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemLedgEntryPage: Page "Item Ledger Entries";
        NewTransLine: Record "Transfer Line";
        LastLineUsed: Integer;
        ltTempInvBuffer: Record "Inventory Buffer" temporary;
        PurchRcptHdr: Record "Purch. Rcpt. Header";
        ValueEntry: Record "Value Entry";
        PurchHdr: Record "Purchase Header";
        PurchInvHdr: Record "Purch. Inv. Header";
        ldQty: Decimal;
        ErrorMessage: text[1024];
        Location: Record Location;
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
        trackingSpecification: Record "Tracking Specification";
        resEntry: Record "Reservation Entry";
        transDir: enum "Transfer Direction";
    begin

        //NC 22512 > DP
        GetInventorySetup;

        ErrorMessage := '';

        TESTFIELD("Transfer-from Code");
        TESTFIELD("Transfer-to Code");
        TESTFIELD("Posting Date");
        TESTFIELD(Status, Status::Open);
        TESTFIELD("In-Transit Code");
        ltTempInvBuffer.RESET;
        ltTempInvBuffer.DELETEALL;
        ItemLedgEntry.RESET;
        ItemLedgEntry.SETCURRENTKEY("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        ItemLedgEntry.FILTERGROUP(2);
        ItemLedgEntry.SETRANGE("Location Code", "Transfer-from Code");
        ItemLedgEntry.SETRANGE(Open, TRUE);
        ItemLedgEntry.SETRANGE(Positive, TRUE);
        ItemLedgEntry.FILTERGROUP(0);
        ItemLedgEntry.SETFILTER("Remaining Quantity", '<>0');
        CLEAR(ItemLedgEntryPage);
        ItemLedgEntryPage.SETTABLEVIEW(ItemLedgEntry);
        ItemLedgEntryPage.LOOKUPMODE(TRUE);
        IF ItemLedgEntryPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
            ItemLedgEntryPage.ReturnSelectionFilter(ItemLedgEntry);
            NewTransLine.RESET;
            NewTransLine.SETRANGE("Document No.", "No.");
            IF NewTransLine.FINDLAST THEN
                LastLineUsed := NewTransLine."Line No."
            ELSE BEGIN
                LastLineUsed := 0;
            END;
            IF ItemLedgEntry.FINDSET THEN
                REPEAT
                    ltTempInvBuffer.RESET;
                    ltTempInvBuffer.DELETEALL;
                    BEGIN
                        LastLineUsed := LastLineUsed + 10000;
                        NewTransLine.INIT;
                        NewTransLine."Document No." := "No.";
                        NewTransLine."Line No." := LastLineUsed;
                        NewTransLine.INSERT(TRUE);
                        NewTransLine.VALIDATE("Item No.", ItemLedgEntry."Item No.");

                        BEGIN
                            ItemLedgEntry.CALCFIELDS("Reserved Quantity");
                            ldQty := ItemLedgEntry."Remaining Quantity" - ItemLedgEntry."Reserved Quantity";

                            IF ldQty <> ItemLedgEntry."Remaining Quantity" THEN
                                IF ErrorMessage = '' THEN
                                    ErrorMessage := STRSUBSTNO(Text60002, ItemLedgEntry."Entry No.", ItemLedgEntry."Remaining Quantity", ldQty)
                                ELSE
                                    ErrorMessage += '\' + STRSUBSTNO(Text60002, ItemLedgEntry."Entry No.", ItemLedgEntry."Remaining Quantity", ldQty);

                            IF ldQty > 0 THEN
                                NewTransLine.VALIDATE(Quantity, ldQty);
                        END;
                        IF NewTransLine.Quantity > 0 THEN BEGIN
                            NewTransLine.VALIDATE("Qty. to Ship", NewTransLine.Quantity);

                            NewTransLine.MODIFY;  // must be here because of modify with trigger later in code
                            NewTransLine.SetILE(0);

                            IF (ItemLedgEntry."Lot No." <> '') THEN
                                NewTransLine.SetILE(ItemLedgEntry."Entry No.");

                            NewTransLine.VALIDATE("Transfer-To Bin Code", CheckLocBinCombiantion(NewTransLine."Transfer-to Code",
                                                                                                NewTransLine."Transfer-from Bin Code"));

                            IF Location.GET("Transfer-to Code") AND Location."Bin Mandatory" AND ("Vendor No." <> '') THEN
                                NewTransLine.VALIDATE("Transfer-To Bin Code", "Vendor No.");

                            NewTransLine."Shortcut Dimension 1 Code" := ItemLedgEntry."Global Dimension 1 Code";
                            NewTransLine."Shortcut Dimension 2 Code" := ItemLedgEntry."Global Dimension 2 Code";

                            NewTransLine."New Shortcut Dimension 1 Code" := ItemLedgEntry."Global Dimension 1 Code";
                            NewTransLine."New Shortcut Dimension 2 Code" := ItemLedgEntry."Global Dimension 2 Code";

                            NewTransLine."Dimension Set ID" := ItemLedgEntry."Dimension Set ID";

                            NewTransLine.MODIFY(TRUE);

                            //NC 41281 > DP
                            clear(resEntry);
                            trackingSpecification.InitTrackingSpecification(32, 0, '', '', 0, ItemLedgEntry."Entry No.", ItemLedgEntry."Variant Code", ItemLedgEntry."Location Code", ItemLedgEntry."Qty. per Unit of Measure");
                            TransferLineReserve.CreateReservationSetFrom(trackingSpecification);
                            TransferLineReserve.CreateReservation(NewTransLine, NewTransLine.Description, NewTransLine."Shipment Date",
                                                                  NewTransLine.Quantity, NewTransLine."Quantity (Base)", resEntry, transDir::Outbound);
                            //NC 41281 < DP
                        END ELSE
                            NewTransLine.DELETE(TRUE);
                    END;
                UNTIL ItemLedgEntry.NEXT = 0;

            IF ErrorMessage <> '' THEN
                MESSAGE(Text60001 + '\' + ErrorMessage);

        END;
        //NC 22512 < DP

    end;

    local procedure GetInventorySetup()
    begin
        if not HasInventorySetup then begin
            InvtSetup.Get();
            HasInventorySetup := true;
        end;
    end;

    local procedure CheckLocBinCombiantion(pcLocation: Code[20]; pcBin: Code[20]): Code[20]
    var
        lrBin: Record Bin;
    begin

        //NC 22512 > DP
        IF lrBin.GET(pcLocation, pcBin) THEN EXIT(lrBin.Code) ELSE EXIT('');
        //NC 22512 < DP
    end;

    procedure NewSaveDocDim(GlobalDimNumber: integer; GlobalDimValueCode: Code[20])
    var
        dimMgt: codeunit DimensionManagement;
    begin
        DimMgt.ValidateShortcutDimValues(GlobalDimNumber, GlobalDimValueCode, "New Dimension Set ID");

    end;
}