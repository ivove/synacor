/// Class to hold the memory of a VM
Class SYNACOR.Memory Extends %RegisteredObject
{

Property Values As array Of SYNACOR.Value;

Method Set(index As %Integer, value As SYNACOR.Value)
{
    do ..Values.SetAt(value,index)
}

Method SetInt(index As %Integer, value As %Numeric)
{
    set memVal = ##class(SYNACOR.Value).%New()
    do memVal.SetIntValue(value)
    do ..Set(index,memVal)
}

Method Get(index As %Integer) As SYNACOR.Value
{
    set value = ..Values.GetAt(index)
    if (value = $$$NULLOREF) {
        set value = ##class(SYNACOR.Value).%New()
        do value.SetIntValue(0)
    }
    return value
}

}
