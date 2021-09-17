page 70031 "Projects Version"
{
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Project Version";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(Repeater12370003)
            {
                field("Project Code"; Rec."Project Code")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Version Code"; Rec."Version Code")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field("Version Date"; Rec."Version Date")
                {
                    Editable = false;
                    ApplicationArea = All;

                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                }

                field("First Version"; Rec."First Version")
                {
                    Visible = false;
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field("Archive Version"; Rec."Archive Version")
                {
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field("Fixed Version"; Rec."Fixed Version")
                {
                    Editable = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }



            }
        }
    }


    // actions
    // {
    //     area(navigation)
    //     {
    //         group(Control12370011)
    //         {
    //             action(Control12370012)
    //             {
    //                 Caption = 'Просмотр';
    //                 trigger OnAction()
    //                 var 
    //                     lfProjectStructureAnalisys: page "Project Structure Analisys";
    //                 begin
    //                     lfProjectStructureAnalisys.SetParam("Project Code","Analysis Type","Version Code");
    //                     lfProjectStructureAnalisys.RUN;
    //                 end;


    //             }   
    //             action(Control12370018)
    //             {
    //                 Caption = 'Create';
    //                 trigger OnAction()
    //                 begin
    //                     CLEAR(gfCreateProjectVersion);
    //                     grPrjStr.SETRANGE(Code,"Project Code");
    //                     grPrjStr.SETRANGE(Type,"Analysis Type");
    //                     IF grPrjStr.FIND('-') THEN
    //                     BEGIN
    //                       gfCreateProjectVersion.SETTABLEVIEW(grPrjStr);
    //                       gfCreateProjectVersion.SETRECORD(grPrjStr);
    //                       gfCreateProjectVersion.RUNMODAL;

    //                     END;
    //                 end;
    //             }

    //             action(Control12370019)
    //             {
    //                 Visible = No;
    //                 Caption = 'Копировать';
    //                 trigger OnAction()
    //                 begin
    //                     CLEAR(gfCreateProjectVersion);
    //                     grPrjStr.SETRANGE(Code,"Project Code");
    //                     grPrjStr.SETRANGE(Type,"Analysis Type");
    //                     IF grPrjStr.FIND('-') THEN
    //                     BEGIN
    //                       gfCreateProjectVersion.SetActionType(1,"Version Code",Description);
    //                       gfCreateProjectVersion.SETTABLEVIEW(grPrjStr);
    //                       gfCreateProjectVersion.SETRECORD(grPrjStr);
    //                       gfCreateProjectVersion.RUNMODAL;

    //                     END;
    //                 end;
    //             }   

    //             action(Control12370020)
    //             {
    //                 Visible = No;
    //                 Caption = 'Удалить';
    //                 trigger OnAction()
    //                 begin
    //                     IF CONFIRM(STRSUBSTNO(TEXT0001,"Version Code","Project Code")) THEN
    //                     BEGIN
    //                       IF "Fixed Version" THEN
    //                       BEGIN
    //                         MESSAGE(TEXT0002);
    //                         EXIT;
    //                       END;

    //                       grProjectVersion.SETRANGE("Project Code","Project Code");
    //                       IF grProjectVersion.COUNT = 1 THEN
    //                       BEGIN
    //                         MESSAGE(TEXT0003);
    //                         EXIT;
    //                       END;

    //                       lrProjectsBudgetEntry.SETRANGE("Project Code","Project Code");
    //                       lrProjectsBudgetEntry.SETRANGE("Analysis Type","Analysis Type");
    //                       lrProjectsBudgetEntry.SETRANGE("Version Code","Version Code");
    //                       IF lrProjectsBudgetEntry.FIND('-') THEN lrProjectsBudgetEntry.DELETEALL(TRUE);

    //                       lrProjectsStructureLines.SETRANGE("Project Code","Project Code");
    //                       lrProjectsStructureLines.SETRANGE(Type,"Analysis Type");
    //                       lrProjectsStructureLines.SETRANGE(Version,"Version Code");
    //                       IF lrProjectsStructureLines.FIND('-') THEN lrProjectsStructureLines.DELETEALL(TRUE);

    //                       Rec.DELETE;
    //                     END;
    //                 end;
    //             }   
    //         }
    //     }
    // }




    var
        grPrjStr: record "Projects Structure";
        // gfCreateProjectVersion: page "Create Project Version";
        // TEXT0001: Label 'Удалить версию %1 проекта %2?';
        // TEXT0002: Label 'Нельзя удалить фиксированную версию!';
        grProjectVersion: record "Project Version";
        // TEXT0003: Label 'Нельзя удалить все версии!';
        lrPrjStr1: record "Projects Structure";
        lrProjectsBudgetEntry: record "Projects Budget Entry";
        lrProjectVersion: record "Project Version";
        lrProjectsStructureLines: record "Projects Structure Lines";



}

