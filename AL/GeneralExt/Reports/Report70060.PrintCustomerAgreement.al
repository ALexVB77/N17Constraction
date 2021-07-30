report 70060 "Print Customer Agreement"
{
    //UsageCategory = Administration;
    //ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Agr; "Customer Agreement")
        {
            DataItemTableView = SORTING("Customer No.", "No.") ORDER(Ascending);
            dataitem(PrintTemplate; Integer)

            {
                DataItemTableView = sorting(Number);

            }
        }
    }



    var
        myInt: Integer;
}