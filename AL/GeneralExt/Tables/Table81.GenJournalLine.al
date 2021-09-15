tableextension 80081 "Gen. Journal Line (Ext)" extends "Gen. Journal Line"
{
    fields
    {
        field(50020; "Notify Customer"; boolean)
        {
            Caption = 'Notify Customer';
        }
        field(50030; Gift; Boolean)
        {
            Caption = 'Gift';
        }
        field(70020; "IW Document No."; Code[20])
        {
            Description = 'NC 50112 AB';
            Caption = 'IW Document No.';
        }
    }

    var
        IFRSMgt: Codeunit "IFRS Management";

    procedure FillIFRSData(var GlobalGLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        IFRSMgt.FillIFRSData(GlobalGLEntry, GenJournalLine);
    end;

    procedure CheckIFRSTransactionConsistent(var GLReg: Record "G/L Register"; var GenJnlLine: Record "Gen. Journal Line"; GlobalGLEntry: Record "G/L Entry")
    begin
        IFRSMgt.CheckIFRSTransactionConsistent(GLReg, GenJnlLine, GlobalGLEntry);
    end;
}
