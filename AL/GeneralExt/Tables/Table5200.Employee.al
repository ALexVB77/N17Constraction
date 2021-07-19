tableextension 85200 "Employee (Ext)" extends Employee
{
    fields
    {
        field(50006; "Full Name Genitive"; Text[120])
        {
            Caption = 'Full Name Genitive';
            Description = 'NC 51417 PA';
        }
        field(50007; "Job Title Genitive"; Text[100])
        {
            Caption = 'Job Title Genitive';
            Description = 'NC 51417 PA';
        }
    }
}