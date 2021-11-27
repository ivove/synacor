/// Stack
Class SYNACOR.Stack Extends %RegisteredObject
{

/// content
Property Content As array Of SYNACOR.Value;

/// count
Property Count As %Numeric;

/// Pop
Method Pop() As SYNACOR.Value
{
    Set ..Count = ..Count - 1
    Set value = ..Content.GetAt(+..Count)
    Return value
}

Method Push(value As SYNACOR.Value)
{
    Do ..Content.SetAt(value,+..Count)
    Set ..Count = ..Count + 1
}

}
