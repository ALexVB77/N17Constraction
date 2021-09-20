page 70002 "IFRS Stat. Acc. Map. Vers.Line"
{
    AutoSplitKey = true;
    Caption = 'IFRS Stat. Acc. Map. Vers. Lines';
    DelayedInsert = true;
    PageType = Worksheet;
    PopulateAllFields = true;
    SaveValues = true;
    SourceTable = "IFRS Stat. Acc. Map. Vers.Line";

    layout
    {
        area(content)
        {
            group(Control120)
            {
                ShowCaption = false;
                field(CurrentMappingCode; CurrentMappingCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Mapping Code';
                    Editable = false;
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AccMapping: Record "IFRS Statutory Account Mapping";
                    begin
                        if Page.RunModal(0, AccMapping) = Action::LookupOK then begin
                            CurrentMappingCode := AccMapping.Code;
                            SetPageFilters();
                            CurrPage.Update(false);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        AccMapping: Record "IFRS Statutory Account Mapping";
                    begin
                        if CurrentMappingCode <> '' then
                            AccMapping.Get(CurrentMappingCode);
                        SetPageFilters();
                        CurrPage.Update(false);
                    end;
                }
                field(CurrentVersionCode; CurrentVersionCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Version Code';
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AccMapVers: Record "IFRS Stat. Acc. Map. Vers.";
                    begin
                        if CurrentMappingCode = '' then
                            exit(false);
                        AccMapVers.FilterGroup(2);
                        AccMapVers.SetRange("IFRS Stat. Acc. Mapping Code", CurrentMappingCode);
                        AccMapVers.FilterGroup(0);
                        if Page.RunModal(0, AccMapVers) = Action::LookupOK then begin
                            CurrentVersionCode := AccMapVers.Code;
                            SetPageFilters();
                            CurrPage.Update(false);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        AccMapVers: Record "IFRS Stat. Acc. Map. Vers.";
                    begin
                        if CurrentMappingCode <> '' then
                            AccMapVers.Get(CurrentMappingCode, CurrentVersionCode);
                        SetPageFilters();
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control1)
            {
                Editable = ListEditable;
                ShowCaption = false;
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Stat. Acc. Account No."; "Stat. Acc. Account No.")
                {
                    ApplicationArea = All;
                }
                field("Stat. Acc. Account Name"; "Stat. Acc. Account Name")
                {
                    ApplicationArea = All;
                }
                field("Cost Place Code"; "Cost Place Code")
                {
                    ApplicationArea = All;
                    CaptionClass = GetDimCaptionClass(0, false);
                }
                field(CostPlaceName; GetDimensionName(0, "Cost Place Code"))
                {
                    ApplicationArea = All;
                    CaptionClass = GetDimCaptionClass(0, true);
                }
                field("Cost Code Code"; "Cost Code Code")
                {
                    ApplicationArea = All;
                    CaptionClass = GetDimCaptionClass(1, false);
                }
                field(CostCodeName; GetDimensionName(1, "Cost Code Code"))
                {
                    ApplicationArea = All;
                    CaptionClass = GetDimCaptionClass(1, true);
                }
                field("IFRS Account No."; "IFRS Account No.")
                {
                    ApplicationArea = All;
                }
                field("IFRS Account Name"; "IFRS Account Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetPageFilters;
    end;

    //trigger OnNewRecord(BelowxRec: Boolean)
    //begin
    //    "IFRS Stat. Acc. Mapping Code" := CurrentMappingCode;
    //    "Version Code" := CurrentVersionCode;       
    //end;

    var
        CurrentMappingCode, CurrentVersionCode : code[20];
        ListEditable: Boolean;

    local procedure SetPageFilters()
    var
        IFRSMapVersion: Record "IFRS Stat. Acc. Map. Vers.";
    begin
        FilterGroup(2);
        if IFRSMapVersion.Get(CurrentMappingCode, CurrentVersionCode) then
            SetRange("Version ID", IFRSMapVersion."Version ID")
        else
            SetRange("Version ID", '');
        FilterGroup(0);
        if FindFirst() then;

        ListEditable := (CurrentMappingCode <> '') and (CurrentVersionCode <> '');
    end;

    procedure SetParam(MappingCode: code[20]; VersionCode: Code[20])
    begin
        CurrentMappingCode := MappingCode;
        CurrentVersionCode := VersionCode;
    end;
}