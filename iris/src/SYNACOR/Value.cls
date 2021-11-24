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
    set val.RawValue = part2_part1
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

Method SetValue(part1 As %String, part2 As %String)
{
    for i=1:1:16 { set $BIT(bitValue,i) = 0 }
    set bPart1 = ..Int2Bit(part1)
    for i=1:1:8 { set $BIT(bitValue,i) = $EXTRACT(bPart1,i)}
    set bPart2 = ..Int2Bit(part2)
    for i=1:1:8 { set $BIT(bitValue,i+8) = $EXTRACT(bPart2,i)}
    set ..BitValue = bitValue
}

}
