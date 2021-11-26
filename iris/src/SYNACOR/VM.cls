/// Synacor VM
Class SYNACOR.VM Extends %RegisteredObject
{

Property Memory As SYNACOR.Memory;

Property Registry As SYNACOR.Memory;

Property Cursor As %Integer;

Property Running As %Boolean;

Property Debug As %Boolean;

Property DebugLines As %Integer;

/// Load the VM (read the memory dump to memory)
Method Load() As %Status
{
    Set sc = $$$OK
    set ..Memory = ##class(SYNACOR.Memory).%New()
    set ..Registry = ##class(SYNACOR.Memory).%New()
    set ..Cursor = 0
    set ..Running = 0
    #DIM filename As %String = "/shared/challenge.bin"  
    Set stream=##class(%Stream.FileBinary).%New()
    Set sc=stream.LinkToFile(filename)
    set position = 0
    While 'stream.AtEnd {
        set char1 = stream.Read(1)
        set char2 = stream.Read(1)
        set value = ##class(SYNACOR.Value).Parse(char1,char2)
        do ..Memory.Set(position,value)
        set position = position + 1
    } 
    Return sc
}

Method Run(debug As %Boolean = 0)
{
    set ..Debug = debug
    set ..Running = 1
    while ..Running {
        do ..Debug(0,"")
        set current = ..GetValue(..Cursor)
        if (current.Value = 0) { do ..Halt() }
        elseif (current.Value = 1) { do ..Set() }
        elseif (current.Value = 6) { do ..Jmp() }
        elseif (current.Value = 7) { do ..Jt() }
        elseif (current.Value = 8) { do ..Jf() }
        elseif (current.Value = 19) { do ..Out() }
        else { do ..Noop() }
        //add
    }
}

/// opcode 0 -> Halt = stop execution
Method Halt()
{
    do ..Debug(1,"Halt")
    set ..Running = 0
}

/// opcode 1 -> set
Method Set()
{
    set ..Cursor = ..Cursor + 1
    do ..Debug(1,"Set")
    set addr = ..Memory.Get(..Cursor)
    set ..Cursor = ..Cursor + 1
    do ..Debug(1,"Set")
    set value = ..Memory.Get(..Cursor)
    if addr.Value < 32768 {
        do ..Memory.SetInt(addr.Value,value.Value)
    }
    else {
        do ..Registry.SetInt(addr.Value-32768,value.Value)
    }
    set ..Cursor = ..Cursor + 1
}

/// opcode 6 -> jump
Method Jmp()
{
    set ..Cursor = ..Cursor + 1
    do ..Debug(1,"Jmp")
    set value = ..GetValue(..Cursor)
    set ..Cursor = value.Value
}

/// opcode 7 -> Jump if true
Method Jt()
{
    set ..Cursor = ..Cursor + 1
    do ..Debug(1,"Jt")
    set value = ..GetValue(..Cursor)
    if value.Value { d ..Jmp() }
    else { set ..Cursor = ..Cursor + 1 }
}

/// opcode 8 -> Jump if false
Method Jf()
{
    set ..Cursor = ..Cursor + 1
    do ..Debug(1,"Jf")
    set value = ..GetValue(..Cursor)
    if 'value.Value { d ..Jmp() }
    else { set ..Cursor = ..Cursor + 1 }
}

/// opcode 19 -> Write to console
Method Out()
{
    set ..Cursor = ..Cursor + 1
    do ..Debug(1,"Out")
    set value = ..GetValue(..Cursor)
    write $CHAR(value.Value)
    set ..Cursor = ..Cursor + 1
}

/// opcode 21 -> No opperation
Method Noop()
{
    do ..Debug(1,"Noop")
    set ..Cursor = ..Cursor + 1
}

/// Debugging
Method Debug(level As %Integer, command As %String) As %Status
{
    if ..Debug {
        if ..DebugLines = 10 { 
            read xx
            set ..DebugLines = 0
        }
        write !
        for i=1:1:level { write *9 }
        set value = ..GetValue(..Cursor,.loc)
        write ..Cursor," : ",command," - ",value.Value," (",loc,")",*9
        set ..DebugLines = ..DebugLines + 1
    }
}

/// Get The value -> raw value or value in registry
Method GetValue(index As %Integer, ByRef debug As %String) As SYNACOR.Value
{
    set debug = "V"
    set value = ..Memory.Get(index)
    if value.Value < 32768 { return value }
    set debug = "R ("_(value.Value-32768)_")"
    return ..Registry.Get(value.Value-32768)
}

}
