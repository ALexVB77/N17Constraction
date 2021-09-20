page 70005 "IFRSEntriesForTransfer"
{
    ApplicationArea = Basic, Suite;
    Editable = false;
    SourceTable = "G/L Entry";
    SourceTableView = sorting("IFRS Transfer Status", "IFRS Transfer Date") where("IFRS Transfer Status" = const(Ready));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(EntryNo; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(PostingDate; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Period; "IFRS Period")
                {
                    ApplicationArea = All;
                }
                field(DocumentDate; "Document Date")
                {
                    ApplicationArea = All;
                }
                field(GLAccountNo; "G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field(BBWAccountNo; "IFRS Account No.")
                {
                    ApplicationArea = All;
                }
                field(SourceNo; "Source No.")
                {
                    ApplicationArea = All;
                }
                field(CostCode; CostCode)
                {
                    ApplicationArea = All;
                }
                field(CostPlace; CostPlace)
                {
                    ApplicationArea = All;
                }
                field(Currency; 'RUR')
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInit()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if Format(GLSetup."IFRS Transfer Period") <> '' then
            SetFilter("IFRS Transfer Date", '%1..', CalcDate(GLSetup."IFRS Transfer Period"));
        PurchSetup.Get();
    end;

    trigger OnAfterGetRecord()
    var
        DimSetEntry: Record "Dimension Set Entry";
    begin
        CostCode := '';
        CostPlace := '';
        if "Dimension Set ID" <> 0 then begin
            if PurchSetup."Cost Code Dimension" <> '' then
                if DimSetEntry.Get("Dimension Set ID", PurchSetup."Cost Code Dimension") then
                    CostCode := DimSetEntry."Dimension Value Code";
            if PurchSetup."Cost Place Dimension" <> '' then
                if DimSetEntry.Get("Dimension Set ID", PurchSetup."Cost Place Dimension") then
                    CostPlace := DimSetEntry."Dimension Value Code";
        end;
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        CostCode, CostPlace : code[20];
}