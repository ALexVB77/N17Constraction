// Миграция данных
table 70001 "ImportDimPivot"
{
    fields
    {
        field(1; TableID; Integer)
        { }
        field(3; Dim1Code; Code[20])
        { }
        field(4; Dim2Code; Code[20])
        { }
        field(5; Dim3Code; Code[20])
        { }
        field(6; Dim4Code; Code[20])
        { }
        field(7; Dim5Code; Code[20])
        { }
        field(8; Dim6Code; Code[20])
        { }
        field(9; Dim7Code; Code[20])
        { }
        field(10; Dim8Code; Code[20])
        { }
        field(11; Dim9Code; Code[20])
        { }
        field(12; Dim10Code; Code[20])
        { }
    }

    keys
    {
        key(Key1; TableID)
        {
            Clustered = true;
        }
    }
}

