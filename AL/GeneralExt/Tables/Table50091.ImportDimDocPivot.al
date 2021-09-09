// Миграция данных
table 50091 "ImportDimDocPivot"
{
    fields
    {
        field(1; TableID; Integer)
        { }
        field(2; DocType; Integer)
        { }
        field(3; DocNo; Code[20])
        { }
        field(4; DocLineNo; Integer)
        { }
        field(5; Dim1ValueCode; Code[20])
        { }
        field(6; Dim2ValueCode; Code[20])
        { }
        field(7; Dim3ValueCode; Code[20])
        { }
        field(8; Dim4ValueCode; Code[20])
        { }
        field(9; Dim5ValueCode; Code[20])
        { }
        field(10; Dim6ValueCode; Code[20])
        { }
        field(11; Dim7ValueCode; Code[20])
        { }
        field(12; Dim8ValueCode; Code[20])
        { }
        field(13; Dim9ValueCode; Code[20])
        { }
        field(14; Dim10ValueCode; Code[20])
        { }
        field(20; SQLDimSetID; Integer)
        { }
        field(21; NAVDimSetID; Integer)
        { }
    }
    keys
    {
        key(Key1; TableID, DocType, DocNo, DocLineNo)
        {
            Clustered = true;
        }
        key(Key2; NAVDimSetID)
        { }
    }
}