pageextension 80539 "MyDim Value Comb Ext" extends "MyDim Value Combinations"
{
    layout
    {
        addafter(ShowColumnName)
        {
            field(ColFilter; ColFilter)
            {
                Caption = 'Column Filter';
                //Visible = true;
                ApplicationArea = All;
                trigger OnLookup(var Text: Text): Boolean
                var
                    IsoMgt: Codeunit "Isolated Storage Management GE";
                    TmpStr: Text;
                    SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
                    DimensionValueList: Page "Dimension Value List";
                    DimensionValue: Record "Dimension Value";
                    lShowNames: Boolean;
                    lCol: Code[20];
                    lRow: Code[20];
                begin

                    if IsoMgt.getBool('ShowCaptionFromPage', ShowNames, true) then
                        ShowNames := ShowNames;

                    if IsoMgt.getString('RowFromPage', TmpStr, true) then begin
                        Evaluate(lRow, TmpStr);
                        Row := lRow;
                    end;
                    if IsoMgt.getString('ColFromPage', TmpStr, true) then begin
                        Evaluate(lCol, TmpStr);
                        Col := lCol;
                    end;
                    Clear(DimensionValueList);
                    if Col <> '' then begin
                        DimensionValue.Reset();
                        DimensionValue.SetRange(DimensionValue."Dimension Code", Col);

                        DimensionValueList.SetTableView(DimensionValue);
                        DimensionValueList.LookupMode := TRUE;

                        if DimensionValueList.RunModal() = Action::LookupOK then begin
                            ColFilter := DimensionValueList.GetSelectionFilter;
                            IsoMgt.init();
                            IsoMgt.setString('DimValColumnFilter', ColFilter);

                        end;
                        Load(Row, Col, ShowNames);
                        MATRIX_GenerateColumnCaptions(SetWanted::Initial);
                        UpdateMatrixSubform();
                    end;
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addlast(processing)
        {
            /*action( Tetbutton)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Message(MatrixRecord.Code);
                end;
            }*/

        }

    }

    var
        //MatrixRecord: Record "Dimension Value";
        Row: Code[20];
        Col: Code[20];
        ShowNames: Boolean;
        ColFilter: Code[100];
}