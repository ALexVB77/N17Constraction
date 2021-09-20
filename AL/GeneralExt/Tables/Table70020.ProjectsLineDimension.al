table 70020 "Projects Line Dimension"
{
    Caption = 'Projects Line Dimension';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Project No."; Code[20])
        {
            Caption = 'Job No.';
            Editable = false;
            NotBlank = true;
            TableRelation = "Building project";
        }
        field(2; "Project Line No."; Integer)
        {
            Caption = 'Job Task No.';
            NotBlank = true;
        }
        field(3; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            TableRelation = Dimension.Code;

            trigger OnValidate();
            begin
                if NOT DimMgt.CheckDim("Dimension Code") then
                    ERROR(DimMgt.GetDimErr);
                "Dimension Value Code" := '';
            end;
        }
        field(4; "Dimension Value Code"; Code[20])
        {
            Caption = 'Dimension Value Code';
            TableRelation = "Dimension Value".Code where("Dimension Code" = field("Dimension Code"));
        }
        field(5; "Project Version No."; Code[10])
        {
            Caption = 'Project Version No.';
        }
        field(6; "Detailed Line No."; Integer)
        {
            Caption = 'Detailed Line No.';
        }
        field(20; Type; Enum "Analysis Type")
        {
            Caption = 'Analysis Type';
        }
        // field(60088; "Original Company"; Code[2])
        // {
        //     Caption = 'Original Company';
        // }
    }

    keys
    {
        key(Key1; "Project No.", Type, "Project Version No.", "Project Line No.", "Detailed Line No.", "Dimension Code")
        {
            Clustered = true;
        }
    }
    trigger OnDelete();
    begin
        UpdateDimFields('');
    end;

    trigger OnInsert();
    begin
        UpdateDimFields("Dimension Value Code")
    end;

    trigger OnModify();
    begin
        UpdateDimFields("Dimension Value Code")
    end;

    var
        DimMgt: Codeunit DimensionManagement;

    local procedure UpdateDimFields(NewDimValue: Code[20]);
    var
        Modified: Boolean;
        GLBudgetName: Record "G/L Budget Name";
        GLBudgetEntry: Record "G/L Budget Entry";
        lrPrjStrLine: Record "Projects Structure Lines";
        lrPrjStr: Record "Projects Structure";
    begin
        if "Dimension Code" = '' then
            exit;

        if "Detailed Line No." = 0 then begin
            lrPrjStrLine.SETRANGE("Project Code", "Project No.");
            lrPrjStrLine.SETRANGE(Version, "Project Version No.");
            lrPrjStrLine.SETRANGE("Line No.", "Project Line No.");
            if lrPrjStrLine.FIND('-') then begin
                if lrPrjStr.GET("Project No.") then begin
                    case "Dimension Code" of
                        lrPrjStr."Shortcut Dimension 1 Code":
                            begin
                                lrPrjStrLine."Project Dimension 1 Code" := NewDimValue;
                                Modified := TRUE;
                            end;
                        lrPrjStr."Shortcut Dimension 2 Code":
                            begin
                                lrPrjStrLine."Project Dimension 2 Code" := NewDimValue;
                                Modified := TRUE;
                            end;
                        lrPrjStr."Shortcut Dimension 3 Code":
                            begin
                                lrPrjStrLine."Project Dimension 3 Code" := NewDimValue;
                                Modified := TRUE;
                            end;
                        lrPrjStr."Shortcut Dimension 4 Code":
                            begin
                                lrPrjStrLine."Project Dimension 4 Code" := NewDimValue;
                                Modified := TRUE;
                            end;
                        lrPrjStr."Shortcut Dimension 5 Code":
                            begin
                                lrPrjStrLine."Project Dimension 5 Code" := NewDimValue;
                                Modified := TRUE;
                            end;
                        lrPrjStr."Shortcut Dimension 6 Code":
                            begin
                                lrPrjStrLine."Project Dimension 6 Code" := NewDimValue;
                                Modified := TRUE;
                            end;
                        lrPrjStr."Shortcut Dimension 7 Code":
                            begin
                                lrPrjStrLine."Project Dimension 7 Code" := NewDimValue;
                                Modified := TRUE;
                            end;
                        lrPrjStr."Shortcut Dimension 8 Code":
                            begin
                                lrPrjStrLine."Project Dimension 8 Code" := NewDimValue;
                                Modified := TRUE;
                            end;
                    end;
                    if Modified then begin
                        lrPrjStrLine.Modify;
                    end;
                end;
            end;
        end;
    end;
}

