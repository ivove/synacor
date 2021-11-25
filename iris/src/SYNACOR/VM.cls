/// Synacor VM
Class SYNACOR.VM Extends %RegisteredObject
{

Property Memory As SYNACOR.Memory;

Property Cursor As %Integer;

Property Running As %Boolean;

/// Load the VM (read the memory dump to memory)
Method Load() As %Status
{
    Set sc = $$$OK
    set ..Memory = ##class(SYNACOR.Memory).%New()
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

Method Run()
{
    set ..Running = 1
    while ..Running {
        set current = ..Memory.Get(..Cursor)
        if (current.Value = 0) { do ..Halt() }
        elseif (current.Value = 19) { do ..Out() }
        else { do ..Noop() }
    }
}

/// opcode 0
Method Halt()
{
    set ..Running = 0
}

/// opcode 19
Method Out()
{
    set ..Cursor = ..Cursor + 1
    set value = ..Memory.Get(..Cursor)
    write $CHAR(value.Value)
    set ..Cursor = ..Cursor + 1
}

/// opcode 21
Method Noop()
{
    set ..Cursor = ..Cursor + 1
}

}
