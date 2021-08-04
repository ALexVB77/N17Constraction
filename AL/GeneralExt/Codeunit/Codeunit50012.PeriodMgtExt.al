codeunit 50012 "Period Management Ext"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;
        Text001: Label 'The previous column set could not be found.';
        Text002: Label 'The period could not be found.';
        Text003: Label 'There are no Calendar entries within the filter.';
        PText000: Label '<Week>.<Year4>', Locked = true;
        PText001: Label '<Month Text,3> <Year4>', Locked = true;
        PText002: Label '<Quarter>/<Year4>', Locked = true;
        PText003: Label '<Year4>', Locked = true;
        SetOption: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;

    procedure GeneratePeriodMatrixData(SetWanted: Option; MaximumSetLength: Integer; UseNameForCaption: Boolean; PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Year3; DateFilter: Text; var RecordPosition: Text; var CaptionSet: array[32] of Text[80]; var CaptionRange: Text; var CurrSetLength: Integer; var PeriodRecords: array[32] of Record Date temporary)
    var
        Calendar: Record Date;
        Steps: Integer;
    begin
        Clear(CaptionSet);
        CaptionRange := '';
        CurrSetLength := 0;
        Clear(PeriodRecords);
        Clear(Calendar);


        Calendar.SetFilter("Period Start", GetFullPeriodDateFilter(PeriodType, DateFilter));

        if not FindDate('-', Calendar, PeriodType, false) then begin
            RecordPosition := '';
            Error(Text003);
        end;

        case SetWanted of
            SetOption::Initial:
                begin
                    if (PeriodType = PeriodType::"Accounting Period") or (DateFilter <> '') then begin
                        FindDate('-', Calendar, PeriodType, true);
                    end else
                        Calendar."Period Start" := 0D;
                    FindDate('=><', Calendar, PeriodType, true);
                end;
            SetOption::Previous:
                begin
                    Calendar.SetPosition(RecordPosition);
                    FindDate('=', Calendar, PeriodType, true);
                    Steps := NextDate(-MaximumSetLength, Calendar, PeriodType);
                    if PeriodType <> PeriodType::Year3 then begin
                        if not (Steps in [-MaximumSetLength, 0]) then
                            Error(Text001);
                    end else begin
                        if not (Steps in [-MaximumSetLength * 3, 0]) then
                            Error(Text001);
                    end;
                end;
            SetOption::PreviousColumn:
                begin
                    Calendar.SetPosition(RecordPosition);
                    FindDate('=', Calendar, PeriodType, true);
                    Steps := NextDate(-1, Calendar, PeriodType);
                    if not (Steps in [-1, 0]) then
                        Error(Text001);
                end;
            SetOption::NextColumn:
                begin
                    Calendar.SetPosition(RecordPosition);
                    FindDate('=', Calendar, PeriodType, true);
                    if not (NextDate(1, Calendar, PeriodType) = 1) then begin
                        Calendar.SetPosition(RecordPosition);
                        FindDate('=', Calendar, PeriodType, true);
                    end;
                end;
            SetOption::Same:
                begin
                    Calendar.SetPosition(RecordPosition);
                    FindDate('=', Calendar, PeriodType, true)
                end;
            SetOption::Next:
                begin
                    Calendar.SetPosition(RecordPosition);
                    FindDate('=', Calendar, PeriodType, true);
                    if PeriodType <> PeriodType::Year3 then begin
                        if not (NextDate(MaximumSetLength, Calendar, PeriodType) = MaximumSetLength) then begin
                            Calendar.SetPosition(RecordPosition);
                            FindDate('=', Calendar, PeriodType, true);
                        end;
                    end else begin
                        if not (NextDate(MaximumSetLength, Calendar, PeriodType) = MaximumSetLength * 3) then begin
                            Calendar.SetPosition(RecordPosition);
                            FindDate('=', Calendar, PeriodType, true);
                        end;
                    end;
                end;
        end;

        RecordPosition := Calendar.GetPosition;

        repeat
            GeneratePeriodAndCaption(CaptionSet, PeriodRecords, CurrSetLength, Calendar, UseNameForCaption, PeriodType);
        until (CurrSetLength = MaximumSetLength) or (NextDate(1, Calendar, PeriodType) = 0);

        if CurrSetLength = 1 then
            CaptionRange := CaptionSet[1]
        else
            CaptionRange := CaptionSet[1] + '..' + CaptionSet[CurrSetLength];

        // AdjustPeriodWithDateFilter(DateFilter, PeriodRecords[1]."Period Start",
        //   PeriodRecords[CurrSetLength]."Period End");
    end;

    local procedure GeneratePeriodAndCaption(var CaptionSet: array[32] of Text[80]; var PeriodRecords: array[32] of Record Date temporary; var CurrSetLength: Integer; var Calendar: Record Date; UseNameForCaption: Boolean; PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period")
    begin
        CurrSetLength := CurrSetLength + 1;
        if UseNameForCaption then
            CaptionSet[CurrSetLength] := Format(Calendar."Period Name")
        else
            CaptionSet[CurrSetLength] := CreatePeriodFormat(PeriodType, Calendar."Period Start");
        PeriodRecords[CurrSetLength].Copy(Calendar);
    end;

    local procedure FindDate(SearchString: Text[3]; var Calendar: Record Date; PeriodType: Option; ErrorWhenNotFound: Boolean): Boolean
    var
        Found: Boolean;
    begin
        Found := PFindDate(SearchString, Calendar, PeriodType);
        if ErrorWhenNotFound and not Found then
            Error(Text002);
        exit(Found);
    end;

    local procedure AdjustPeriodWithDateFilter(DateFilter: Text; var PeriodStartDate: Date; var PeriodEndDate: Date)
    var
        Period: Record Date;
    begin
        if DateFilter <> '' then begin
            Period.SetFilter("Period End", DateFilter);
            if Period.GetRangeMax("Period End") < PeriodEndDate then
                PeriodEndDate := Period.GetRangeMax("Period End");
            Period.Reset();
            Period.SetFilter("Period Start", DateFilter);
            if Period.GetRangeMin("Period Start") > PeriodStartDate then
                PeriodStartDate := Period.GetRangeMin("Period Start");
        end;
    end;

    procedure PFindDate(SearchString: Text[3]; var Calendar: Record Date; PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Year3): Boolean
    var
        Found: Boolean;
    begin
        if PeriodType = PeriodType::Year3 then begin
            Calendar.SetRange("Period Type", Calendar."Period Type"::Year);
            Calendar."Period Type" := Calendar."Period Type"::Year;
        end else begin
            Calendar.SetRange("Period Type", PeriodType);
            Calendar."Period Type" := PeriodType;
        end;
        if Calendar."Period Start" = 0D then
            Calendar."Period Start" := WorkDate;
        if SearchString in ['', '=><'] then
            SearchString := '=<>';

        Found := Calendar.Find(SearchString);
        if Found then
            Calendar."Period End" := NormalDate(Calendar."Period End");
        if Found and (PeriodType = PeriodType::Year3) then
            Calendar."Period End" := CalcDate('<+2Y>', Calendar."Period Start");
        exit(Found);
    end;

    procedure NextDate(NextStep: Integer; var Calendar: Record Date; PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Year3): Integer
    begin
        if PeriodType = PeriodType::Year3 then begin
            Calendar.SetRange("Period Type", Calendar."Period Type"::Year);
            Calendar."Period Type" := Calendar."Period Type"::Year;
            NextStep := NextStep * 3;
        end else begin
            Calendar.SetRange("Period Type", PeriodType);
            Calendar."Period Type" := PeriodType;
        end;
        NextStep := Calendar.Next(NextStep);
        if NextStep <> 0 then
            Calendar."Period End" := NormalDate(Calendar."Period End");
        if (NextStep <> 0) and (PeriodType = PeriodType::Year3) then
            Calendar."Period End" := CalcDate('<+3Y>', Calendar."Period Start");
        exit(NextStep);
    end;

    procedure CreatePeriodFormat(PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Year3; Date: Date): Text[50]
    begin
        case PeriodType of
            PeriodType::Day:
                exit(Format(Date));
            PeriodType::Week:
                begin
                    if Date2DWY(Date, 2) = 1 then
                        Date := Date + 7 - Date2DWY(Date, 1);
                    exit(Format(Date, 0, PText000));
                end;
            PeriodType::Month:
                exit(Format(Date, 0, PText001));
            PeriodType::Quarter:
                exit(Format(Date, 0, PText002));
            PeriodType::Year:
                exit(Format(Date, 0, PText003));
            PeriodType::"Accounting Period":
                exit(Format(Date));
            PeriodType::Year3:
                exit(Format(Date, 0, PText003) + ' - ' + Format(calcdate('<+2Y>', Date), 0, PText003))
        end;
    end;

    procedure GetFullPeriodDateFilter(PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Year3; DateFilter: Text): Text
    var
        Period: Record Date;
        StartDate: Date;
        EndDate: Date;
    begin
        if DateFilter = '' then
            exit(DateFilter);

        Period.SetFilter("Period Start", DateFilter);
        StartDate := Period.GetRangeMin("Period Start");
        EndDate := Period.GetRangeMax("Period Start");
        case PeriodType of
            PeriodType::Week,
            PeriodType::Month,
            PeriodType::Quarter,
            PeriodType::Year,
            PeriodType::Year3:
                begin
                    Period.SetRange("Period Type", PeriodType);
                    if PeriodType = PeriodType::Year3 then
                        Period.SetRange("Period Type", Period."Period Type"::Year);
                    Period.SetFilter("Period Start", '<=%1', StartDate);
                    Period.FindLast;
                    StartDate := Period."Period Start";
                    Period.SetRange("Period Start");
                    Period.SetFilter("Period End", '>%1', EndDate);
                    Period.FindFirst;
                    EndDate := NormalDate(Period."Period End");
                end;
        end;
        Period.SetRange("Period Start", StartDate, EndDate);
        exit(Period.GetFilter("Period Start"));
    end;
}