// Миграция данных
query 50049 ImportDocumentDimension
{
    elements
    {
        dataitem(ImportDimDocPivot; ImportDimDocPivot)
        {
            column(TableID; TableID)
            {
            }
            column(SQLDimSetID; SQLDimSetID)
            {
            }
            column(RecCount)
            {
                Method = Count;
            }
        }

    }
}