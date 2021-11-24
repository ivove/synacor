/// Synacor VM
Class SYNACOR.VM Extends %RegisteredObject
{

Property Memory As SYNACOR.Memory;

Property Cursor As %Integer;

/// Load the VM (read the memory dump to memory)
Method Load() As %Status
{
    Set sc = $$$OK
    set ..Memory = ##class(SYNACOR.Memory).%New()
    set ..Cursor = 0
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
    set running = 1
    while running {
        set current = ..Memory.Get(..Cursor)
        if (current.Value = 0) { set running = 0 }
        else { set ..Cursor = ..Cursor + 1 }
    }
}

}
