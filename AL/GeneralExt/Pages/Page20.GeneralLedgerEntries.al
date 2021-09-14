pageextension 80020 "General Ledger Entries (Ext)" extends "General Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("DenDoc Dim Value"; GetDenDocDim())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'DenDoc Dim Value';
            }

            field("Utilities Dim. Value Code"; GetUtilitiesDim())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Utilities Dim. Value';

            }
            field("Credit-Memo Reason"; GetCrMemoReason())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Credit-Memo Reason';
            }
            field("Cust. Ext. Agr. No."; "Cust. Ext. Agr. No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("IFRS Transfer Status"; "IFRS Transfer Status")
            {
                ApplicationArea = Basic, Suite;
                StyleExpr = TransferStatusStyle;
                Visible = false;
            }
            field("IFRS Account No."; "IFRS Account No.")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            field("IFRS Period"; "IFRS Period")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TransferStatusStyle := GetTransferStatusStyle();
    end;

    var
        [InDataSet]
        TransferStatusStyle: text;

    local procedure GetDenDocDim(): Code[20]
    var
        DimSet: Record "Dimension Set Entry";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if DimSet.Get(rec."Dimension Set ID", GLSetup."Shortcut Dimension 8 Code") then
            exit(DimSet."Dimension Value Code");
        exit('');

    end;

    local procedure GetUtilitiesDim(): Code[20]
    var
        DimSet: Record "Dimension Set Entry";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if DimSet.Get(rec."Dimension Set ID", GLSetup."Utilities Dimension Code") then
            exit(DimSet."Dimension Value Code");
        exit('');
    end;

    procedure GetCrMemoReason(): Text[230]
    var
        PCMH: Record "Purch. Cr. Memo Hdr.";
        SCMH: Record "Sales Cr.Memo Header";
    begin

        // SWC1100 DD 28.09.17 >>
        IF PCMH.GET("Document No.") THEN
            EXIT(PCMH."Credit-Memo Reason")
        ELSE
            IF SCMH.GET("Document No.") THEN
                EXIT(SCMH."Credit-Memo Reason");
        // SWC1100 DD 28.09.17 <<

    end;

    local procedure GetTransferStatusStyle(): text;
    begin
        case "IFRS Transfer Status" of
            "IFRS Transfer Status"::New:
                exit('Standard');
            "IFRS Transfer Status"::"Non-Transmit":
                exit('Subordinate');
            "IFRS Transfer Status"::Ready:
                exit('StandardAccent');
            "IFRS Transfer Status"::"No Rule":
                exit('Attention');
        end;
    end;

}