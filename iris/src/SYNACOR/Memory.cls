/// Class to hold the memory of a VM
Class SYNACOR.Memory Extends %RegisteredObject
{

Property Values As array Of SYNACOR.Value;

Method Set(index As %Integer, value As SYNACOR.Value)
{
    do ..Values.SetAt(value,index)
}

Method Get(index As %Integer) As SYNACOR.Value
{
    return ..Values.GetAt(index)
}

}
