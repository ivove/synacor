/// Class to hold the memory of a VM
Class SYNACOR.Memory Extends %RegisteredObject
{

Property Values As array Of SYNACOR.Value;

Method Set(index As %Integer, value As SYNACOR.Value)
{
    Do ..Values.SetAt(value,index)
}

Method SetInt(index As %Integer, value As %Numeric)
{
    Set memVal = ##class(SYNACOR.Value).%New()
    Do memVal.SetIntValue(value)
    Do ..Set(index,memVal)
}

Method Get(index As %Integer) As SYNACOR.Value
{
    Set value = ..Values.GetAt(index)
    If (value = $$$NULLOREF) {
        Set value = ##class(SYNACOR.Value).%New()
        Do value.SetIntValue(0)
    }
    Return value
}

}
