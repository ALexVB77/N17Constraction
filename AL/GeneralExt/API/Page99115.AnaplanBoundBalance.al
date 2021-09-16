page 99115 "Anaplan Bound Balance"
{
    Caption = 'Anaplan Bound Balance';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Anaplan Entity";


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;

                }

                field(verificationNumber; Rec."Verification Number")
                {

                }

                field(verificationType; Rec."Verification Type")
                {

                }

                field(dateTimeUploading; Rec."Date Time Uploading")
                {

                }

                field(erpProject; Rec."ERP Project")
                {

                }

                field(legalEntity; Rec."Legal Entity")
                {

                }

                field(account; Rec.Account)
                {

                }

                field(activity; Rec.Activity)
                {

                }

                field(accountingPeriod; Rec."Accounting Period")
                {

                }


                field(postingDate; Rec."Posting Date")
                {

                }

                field(baseAmount; Rec."Base Amount")
                {

                }

                field(baseAmountSign; Rec."Base Amount Sign")
                {

                }

                field(currencyCode; Rec."Currency Code")
                {

                }

                field(agreementNo; Rec."Agreement No.")
                {

                }

                field(externalAgreement; Rec."External Agreement No.")
                {

                }

                field(supplier; Rec."Supplier No.")
                {

                }

                field(supplierName; Rec."Supplier Name")
                {

                }

            }
        }
    }


    actions
    {
        area(Processing)
        {
            action(ImportTestDataSet)
            {

                Caption = 'Impot test dataset', Locked = true;
                ApplicationArea = All;

                trigger OnAction();
                var
                    CSVBuffer: Record "CSV Buffer" temporary;
                    AnaplanEntity: Record "Anaplan Entity";
                    FileName, BaseFolder, ObjID, SrvFilename : Text;
                    InStream1: InStream;
                    OutStream1: OutStream;
                    MaxRowNo, R, C : Integer;
                    FM: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    Wnd: Dialog;
                begin
                    /*
                    BaseFolder := 'c:\Temp\AnaplanTestDataSet\';
                    If not UploadIntoStream('Select SCV File', BaseFolder, '(*.csv)|*.csv', FileName, InStream1) then
                        exit;

                    Wnd.Open('Import file: #1################ \id: #2################');
                    AnaplanEntity.Reset();
                    AnaplanEntity.DeleteAll();

                    CSVBuffer.LoadDataFromStream(InStream1, ';');
                    MaxRowNo := CSVBuffer.GetNumberOfLines();
                    for R := 1 to MaxRowNo Do begin
                        FileName := CSVBuffer.GetValue(R, 1);
                        ObjID := CopyStr(FileName, 1, StrLen(FileName) - 4);
                        Wnd.Update(1, FileName);
                        Wnd.Update(2, ObjID);
                        if file.Exists(BaseFolder + FileName) then begin
                            C += 1;
                            ObjCache.Init();
                            ObjCache.ID := ObjID;
                            ObjCache."Source Code".Import(BaseFolder + FileName);
                            ObjCache.Insert()
                        end;
                    end;
                    Wnd.Close();
                    ObjCache.FindLast();
                    ObjCache.CalcFields("Source Code");
                    if ObjCache."Source Code".HasValue then
                        Message('OK')
                    else
                        Error('Empty');
                    Message('Imported: %1 of %2', C, MaxRowNo);
                    */
                end;


            }
        }
    }
}
