/// Class to hold a value
Class SYNACOR.Value Extends %RegisteredObject
{

Property RawValue As %String;

Property Value As %Numeric;

Property BitValue As %String;

/// Parse a value
ClassMethod Parse(part1 As %String, part2 As %String) As SYNACOR.Value
{
    set val = ##class(SYNACOR.Value).%New()
    do val.SetValue(part1,part2)
    return val
}

/// convert int to bitstring
ClassMethod Int2Bit(value As %Numeric, length As %Integer = 8) As %String
{
    Set result = ""
    set factor = $FACTOR(value)
    for i=1:1:length { set result = result_$BIT(factor,i) }
    Return result
}

ClassMethod Bit2Int(value As %String) As %Numeric
{
    set result = 0
    for i=1:1:$BITCOUNT(value) { set result = result + ($BIT(value,i)*(2**(i-1))) }
    return result
}

Method SetValue(part1 As %String, part2 As %String)
{
    set ..RawValue = part2_part1
    for i=1:1:16 { set $BIT(bitValue,i) = 0 }
    set bPart1 = ..Int2Bit($ASCII(part1))
    for i=1:1:8 { set $BIT(bitValue,i) = $EXTRACT(bPart1,i)}
    set bPart2 = ..Int2Bit($ASCII(part2))
    for i=1:1:8 { set $BIT(bitValue,i+8) = $EXTRACT(bPart2,i)}
    set ..BitValue = bitValue
    set ..Value = ..Bit2Int(bitValue)
}

}
