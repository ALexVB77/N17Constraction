tableextension 80098 "General Ledger Setup (Ext)" extends "General Ledger Setup"
{
    fields
    {
        field(50005; "IFRS Stat. Acc. Map. Code"; Code[20])
        {
            Caption = 'IFRS Stat. Acc. Map. Code';
            Description = 'NC 51554 AB';
            TableRelation = "IFRS Statutory Account Mapping";
        }
        field(50006; "IFRS Stat. Acc. Map. Vers.Code"; Code[20])
        {
            Caption = 'IFRS Stat. Acc. Map. Vers.Code';
            Description = 'NC 51554 AB';
            TableRelation = "IFRS Stat. Acc. Map. Vers."."Code" WHERE("IFRS Stat. Acc. Mapping Code" = FIELD("IFRS Stat. Acc. Map. Code"));
        }
        field(50007; "Check IFRS Trans. Consistent"; Boolean)
        {
            Caption = 'Check IFRS Trans. Consistent';
            Description = 'NC 51554 AB';
        }
        field(50008; "IFRS Transfer Period"; DateFormula)
        {
            Caption = 'IFRS Transfer Period';
            Description = 'NC 51554 AB';
        }
        field(50030; "Allow Diff in Check"; Decimal)
        {
            Caption = 'Allow Diff in Check';
            Description = 'NC 50085 PA';
        }
        field(75002; "Cost Type Dimension Code"; Code[20])
        {
            Caption = 'Cost Type Dimension Code';
            Description = 'NC 50085 PA';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                "Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
            end;
        }
        field(76000; "Project Dimension Code"; Code[20])
        {
            Caption = 'Project Dim. Code';
            TableRelation = Dimension;
        }

    }
}