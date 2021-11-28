/// Class to hold a value
Class SYNACOR.Value Extends %RegisteredObject
{

Property RawValue As %String;

Property Value As %Numeric;

Property BitValue As %String;

/// Parse a value
ClassMethod Parse(part1 As %String, part2 As %String) As SYNACOR.Value
{
    Set val = ##class(SYNACOR.Value).%New()
    Do val.SetValue(part1,part2)
    Return val
}

/// convert int to bitstring
ClassMethod Int2Bit(value As %Numeric, length As %Integer = 8) As %String
{
    Set result = ""
    Set factor = $FACTOR(value)
    For i=1:1:length { Set result = result_$BIT(factor,i) }
    Return result
}

ClassMethod Bit2Int(value As %String) As %Numeric
{
    Set result = 0
    For i=1:1:$BITCOUNT(value) { Set result = result + ($BIT(value,i)*(2**(i-1))) }
    Return result
}

Method SetValue(part1 As %String, part2 As %String)
{
    Set ..RawValue = part2_part1
    Set bitValue = ""
    For i=1:1:16 { Set $BIT(bitValue,i) = 0 }
    Set bPart1 = ..Int2Bit($ASCII(part1))
    For i=1:1:8 { Set $BIT(bitValue,i) = $EXTRACT(bPart1,i)}
    Set bPart2 = ..Int2Bit($ASCII(part2))
    For i=1:1:8 { Set $BIT(bitValue,i+8) = $EXTRACT(bPart2,i)}
    Set ..BitValue = bitValue
    Set ..Value = ..Bit2Int(bitValue)
}

Method SetIntValue(value As %Numeric)
{
    Set ..Value = value
    Set ..BitValue = $FACTOR(value)
}

Method SetBitValue(value As %String)
{
    Set ..BitValue = value
    Set ..Value = ..Bit2Int(value)
}

}
