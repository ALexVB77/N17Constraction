report 70008 "Find Error 70095"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;

    trigger OnPreReport()
    var
        ProjectsCostCtrlEntry: Record "Projects Cost Control Entry";
        ProjectsCostCtrlEntry2: Record "Projects Cost Control Entry";
        CodeMonkeyTranslation: Codeunit "Code Monkey Translation";
    begin

        ProjectsCostCtrlEntry.SetFilter("Analysis Type", '%1|%2', ProjectsCostCtrlEntry."Analysis Type"::Adv, ProjectsCostCtrlEntry."Analysis Type"::Actuals);
        ProjectsCostCtrlEntry.SetFilter("Create Date", '%1..', 20170628D);
        ProjectsCostCtrlEntry2.SetFilter("Analysis Type", '%1|%2', ProjectsCostCtrlEntry2."Analysis Type"::Adv, ProjectsCostCtrlEntry2."Analysis Type"::Actuals);
        ProjectsCostCtrlEntry2.SetFilter("Create Date", '%1..', 20170628D);
        if ProjectsCostCtrlEntry.FindSet() then
            repeat
                ProjectsCostCtrlEntry2.SetRange("Project Code", ProjectsCostCtrlEntry."Project Code");
                ProjectsCostCtrlEntry2.SetRange("Version Code", ProjectsCostCtrlEntry."Version Code");
                ProjectsCostCtrlEntry2.SetRange("Line No.", ProjectsCostCtrlEntry."Line No.");
                ProjectsCostCtrlEntry2.SetRange(Date, ProjectsCostCtrlEntry.Date);
                ProjectsCostCtrlEntry2.SetRange("Create User", ProjectsCostCtrlEntry."Create User");
                ProjectsCostCtrlEntry2.SetRange("Create Date", ProjectsCostCtrlEntry."Create Date");
                ProjectsCostCtrlEntry2.SetRange("Project Turn Code", ProjectsCostCtrlEntry."Project Turn Code");
                ProjectsCostCtrlEntry2.SetRange("Contragent No.", ProjectsCostCtrlEntry."Contragent No.");
                ProjectsCostCtrlEntry2.SetRange("Agreement No.", ProjectsCostCtrlEntry."Agreement No.");
                ProjectsCostCtrlEntry2.SetRange("Without VAT", ProjectsCostCtrlEntry."Without VAT");
                ProjectsCostCtrlEntry2.SetRange("Shortcut Dimension 1 Code", ProjectsCostCtrlEntry."Shortcut Dimension 1 Code");
                ProjectsCostCtrlEntry2.SetRange("Shortcut Dimension 2 Code", ProjectsCostCtrlEntry."Shortcut Dimension 2 Code");
                ProjectsCostCtrlEntry2.SetRange("Doc No.", ProjectsCostCtrlEntry."Doc No.");
                ProjectsCostCtrlEntry2.SetRange("Doc Type", ProjectsCostCtrlEntry."Doc Type");
                if ProjectsCostCtrlEntry2.Count >= 2 then begin
                    if ProjectsCostCtrlEntry."Without VAT" <> ProjectsCostCtrlEntry."Original Ammount" then
                        ProjectsCostCtrlEntry.Mark(true);
                    if ProjectsCostCtrlEntry2."Without VAT" <> ProjectsCostCtrlEntry2."Original Ammount" then
                        ProjectsCostCtrlEntry2.Mark(true);
                end;
            until ProjectsCostCtrlEntry.NEXT = 0;

        ProjectsCostCtrlEntry.MarkedOnly(true);
        Page.RunModal(0, ProjectsCostCtrlEntry);
    end;
}