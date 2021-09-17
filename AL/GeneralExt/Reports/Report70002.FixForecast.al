report 70002 "Fix Forecast"
{
    ProcessingOnly = true;


    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Options';
                    field(ProjectCode; ProjectCode)
                    {
                        Caption = 'Project Code';
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(VersionCode; VersionCode)
                    {
                        Caption = 'Forecast version';
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(Description; Description)
                    {
                        Caption = 'Description';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                }
            }
        }
    }


    trigger OnPreReport()
    var
        Window: dialog;
        dd: integer;
        i: integer;
    begin
        IF Description = '' THEN
            ERROR(TEXT0001);

        ForecastVersion.INIT;
        ForecastVersion."Project Code" := ProjectCode;
        ForecastVersion."Version Code" := VersionCode;
        ForecastVersion.Description := Description;
        ForecastVersion."Create User" := USERID;
        ForecastVersion."Create Date" := TODAY;
        ForecastVersion."Version Date" := TODAY;
        ForecastVersion.INSERT(TRUE);

        ProjectsCostControlEntry.SETRANGE("Project Code", ProjectCode);
        ProjectsCostControlEntry.SETFILTER("Analysis Type", '%1|%2', ProjectsCostControlEntry."Analysis Type"::Forecast
                                                                  , ProjectsCostControlEntry."Analysis Type"::AllocForecast);

        IF ProjectsCostControlEntry.FINDSET THEN BEGIN
            Window.OPEN('Сохранение данных ...\' +
                               '@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
            dd := ProjectsCostControlEntry.COUNT;
            REPEAT
                ProjectsCostControlEntry1.INIT;
                ProjectsCostControlEntry1.TRANSFERFIELDS(ProjectsCostControlEntry);
                ProjectsCostControlEntry1."Version Code" := VersionCode;
                ProjectsCostControlEntry1."Analysis Type" := ProjectsCostControlEntry1."Analysis Type"::PrevForecast;

                ProjectsCostControlEntry1.INSERT(TRUE);
                i := i + 1;
                Window.UPDATE(1, ROUND(i / dd * 10000, 1));
            UNTIL ProjectsCostControlEntry.NEXT = 0;
            Window.CLOSE;
        END;
    end;

    var
        ProjectCode: code[20];
        VersionCode: code[20];
        Description: text[250];
        // grPrjStr: record "Projects Structure";
        gForecastVersion: Record "Forecast Version";
        grDevelopmentSetup: record "Development Setup";
        TEXT0001: Label 'Description is mandatory!';
        ProjectsCostControlEntry: record "Projects Cost Control Entry";
        ProjectsCostControlEntry1: record "Projects Cost Control Entry";
        ForecastVersion: record "Forecast Version";

    procedure SetProject(pProjectCode: code[20])
    begin
        ProjectCode := pProjectCode;
        VersionCode := GetNextVersion;
    end;

    procedure GetNextVersion() Ret: code[20]
    begin
        gForecastVersion.Reset();
        gForecastVersion.SetRange("Project Code", ProjectCode);
        IF gForecastVersion.FindLast() THEN BEGIN
            grDevelopmentSetup.GET;
            grDevelopmentSetup.TESTFIELD("Pref Forecast Code");
            Ret := grDevelopmentSetup."Pref Forecast Code" + FORMAT(gForecastVersion.Int + 1);
        END;
    end;
}