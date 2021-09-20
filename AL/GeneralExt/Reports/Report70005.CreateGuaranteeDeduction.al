report 70005 "Create Guarantee Deduction"
{
    UsageCategory = None;
    Caption = 'Create Guarantee Deduction';
    ProcessingOnly = true;

    dataset
    {
        dataitem(VLE; "Vendor Ledger Entry")
        {
            DataItemTableView = SORTING("Entry No.")
                                WHERE("Document Type" = const(Invoice), "Remaining Amt. (LCY)" = filter(<> 0));
            trigger OnPreDataItem()
            begin
                IF VLENo = 0 THEN
                    ERROR(Text005);

                IF GUPostingGrCode = '' THEN
                    ERROR(Text001);

                IF Template = '' THEN
                    ERROR(Text003);

                IF Batch = '' THEN
                    ERROR(Text004);

                IF DocNo = '' THEN
                    ERROR(Text007);

                VLE.SETRANGE("Entry No.", VLENo);
            end;

            trigger OnAfterGetRecord()
            begin
                GenJournalLine.SETRANGE("Journal Template Name", Template);
                GenJournalLine.SETRANGE("Journal Batch Name", Batch);

                //GenJnlBatch.GET(Template, Batch);
                IF GenJournalLine.FINDLAST THEN BEGIN
                    LineNo := GenJournalLine."Line No.";
                    //IF DocNo = '' THEN
                    //  DocNo := INCSTR(GenJournalLine."Document No.");
                END ELSE BEGIN
                    LineNo := 0;
                    //IF DocNo = '' THEN BEGIN
                    //  GenJnlBatch.TESTFIELD("No. Series");
                    //  DocNo := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", WORKDATE, FALSE);
                    //END;
                END;

                //DocNo := VLE."Document No." + '_GU';

                CALCFIELDS("Remaining Amt. (LCY)");
                Vend.GET(VLE."Vendor No.");

                LineNo += 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := Template;
                GenJournalLine."Journal Batch Name" := Batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocNo;
                GenJournalLine.VALIDATE("Posting Date", "Posting Date");
                GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Vendor);
                GenJournalLine.VALIDATE("Account No.", "Vendor No.");
                GenJournalLine.VALIDATE("Source Type", GenJournalLine."Source Type"::Vendor);
                GenJournalLine.VALIDATE("Source No.", "Vendor No.");
                GenJournalLine.VALIDATE("Agreement No.", "Agreement No.");
                GenJournalLine.VALIDATE(Amount, -"Remaining Amt. (LCY)");
                GenJournalLine."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := "Dimension Set ID";
                GenJournalLine.Description :=
                COPYSTR(STRSUBSTNO(Text002, Vend.Name), 1, MAXSTRLEN(GenJournalLine.Description));
                GenJournalLine.INSERT(TRUE);

                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := Template;
                GenJournalLine."Journal Batch Name" := Batch;
                GenJournalLine."Line No." := LineNo + 10000;
                GenJournalLine."Document No." := DocNo;
                GenJournalLine.VALIDATE("Posting Date", "Posting Date");
                GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Vendor);
                GenJournalLine.VALIDATE("Account No.", "Vendor No.");
                GenJournalLine.VALIDATE("Source Type", GenJournalLine."Source Type"::Vendor);
                GenJournalLine.VALIDATE("Source No.", "Vendor No.");
                GenJournalLine.VALIDATE("Agreement No.", "Agreement No.");
                GenJournalLine.VALIDATE("Posting Group", GUPostingGrCode);
                GenJournalLine.VALIDATE(Amount, "Remaining Amt. (LCY)");
                GenJournalLine."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := "Dimension Set ID";
                GenJournalLine.Description :=
                COPYSTR(STRSUBSTNO(Text002, Vend.Name), 1, MAXSTRLEN(GenJournalLine.Description));
                GenJournalLine.INSERT(TRUE);

                //COMMIT;
                MESSAGE(Text006,
                    GenJournalLine.FIELDCAPTION("Journal Template Name"),
                    GenJournalLine."Journal Template Name",
                    GenJournalLine.FIELDCAPTION("Journal Batch Name"),
                    GenJournalLine."Journal Batch Name");

            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(Template; Template)
                    {
                        ApplicationArea = All;
                        Caption = 'Template Code';
                        TableRelation = "Gen. Journal Template";
                    }
                    field(Batch; Batch)
                    {
                        ApplicationArea = All;
                        Caption = 'Batch Code';
                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            GenJnlBatch.SetRange("Journal Template Name", Template);
                            if (page.RunModal(0, GenJnlBatch) = Action::LookupOK) then
                                Batch := GenJnlBatch.Name;
                        end;
                    }
                    field(GUPostingGrCode; GUPostingGrCode)
                    {
                        ApplicationArea = All;
                        Caption = 'GD - Posting Group Code';
                        TableRelation = "Vendor Posting Group";
                    }
                    field(DocNo; DocNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Operation GD Document Number';
                    }

                }
            }
        }
        trigger OnOpenPage()
        begin
            IF VLENo = 0 THEN
                ERROR(Text005);

            VLE.GET(VLENo);
            DocNo := VLE."Document No." + '_GU';
        end;
    }
    procedure SetVLE(NewVLENo: Integer)
    begin
        VLENo := NewVLENo;
    end;

    var
        Template: Code[10];
        Batch: Code[10];
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
        DocNo: Code[20];
        VLENo: Integer;
        GUPostingGrCode: Code[20];
        Vend: Record Vendor;
        Text001: Label 'Posting group is not specified';
        Text002: Label '%1/GD_execute job';
        Text003: Label 'Template code is not specified';
        Text004: Label 'Batch code is not specified';
        Text005: Label 'Must be executed from Vendor Ledger Entries';
        Text006: Label 'Created Gen. Journal Lines for GD. %1 %2, %3 %4.';
        Text007: Label 'Document number for GD operation is not specified.';
}