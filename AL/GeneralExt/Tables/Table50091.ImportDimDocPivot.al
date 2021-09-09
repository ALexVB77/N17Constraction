// Миграция данных
table 50091 "ImportDimEntryPivot"
{
    fields
    {
        field(1; TableID; Integer)
        { }
        field(2; DocType; Integer)
        { }
        field(3; DocNo; Code[20])
        { }
        field(4; Dim1ValueCode; Code[20])
        { }
        field(5; Dim2ValueCode; Code[20])
        { }
        field(6; Dim3ValueCode; Code[20])
        { }
        field(7; Dim4ValueCode; Code[20])
        { }
        field(8; Dim5ValueCode; Code[20])
        { }
        field(9; Dim6ValueCode; Code[20])
        { }
        field(10; Dim7ValueCode; Code[20])
        { }
        field(11; Dim8ValueCode; Code[20])
        { }
        field(12; Dim9ValueCode; Code[20])
        { }
        field(13; Dim10ValueCode; Code[20])
        { }
        field(20; SQLDimSetID; Integer)
        { }
        field(21; NAVDimSetID; Integer)
        { }
    }
    keys
    {
        key(Key1; TableID, DocType, DocNo)
        {
            Clustered = true;
        }
        key(Key2; NAVDimSetID)
        { }
    }
}