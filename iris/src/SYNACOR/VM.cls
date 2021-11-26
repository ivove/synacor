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
    Set ..Memory = ##class(SYNACOR.Memory).%New()
    Set ..Registry = ##class(SYNACOR.Memory).%New()
    Set ..Cursor = 0
    Set ..Running = 0
    #DIM filename As %String = "/shared/challenge.bin"  
    Set stream=##class(%Stream.FileBinary).%New()
    Set sc=stream.LinkToFile(filename)
    Set position = 0
    While 'stream.AtEnd {
        Set char1 = stream.Read(1)
        Set char2 = stream.Read(1)
        Set value = ##class(SYNACOR.Value).Parse(char1,char2)
        Do ..Memory.Set(position,value)
        Set position = position + 1
    } 
    Return sc
}

Method Run(debug As %Boolean = 0)
{
    Set ..Debug = debug
    Set ..Running = 1
    While ..Running {
        Do ..Debug(0,"")
        Set current = ..GetValue(..Cursor)
        If (current.Value = 0) { Do ..Halt() }
        ElseIf (current.Value = 1) { Do ..Set() }
        ElseIf (current.Value = 6) { Do ..Jmp() }
        ElseIf (current.Value = 7) { Do ..Jt() }
        ElseIf (current.Value = 8) { Do ..Jf() }
        ElseIf (current.Value = 9) { Do ..Add() }
        ElseIf (current.Value = 19) { Do ..Out() }
        Else { Do ..Noop() }
        //add
    }
}

/// opcode 0 -> Halt = stop execution
Method Halt()
{
    Do ..Debug(1,"Halt")
    Set ..Running = 0
}

/// opcode 1 -> set
Method Set()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Set")
    Set addr = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Set")
    Set value = ..Memory.Get(..Cursor)
    Do ..MemSet(addr.Value,value.Value)
    Set ..Cursor = ..Cursor + 1
}

/// opcode 6 -> jump
Method Jmp()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Jmp")
    Set value = ..GetValue(..Cursor)
    Set ..Cursor = value.Value
}

/// opcode 7 -> Jump if true
Method Jt()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Jt")
    Set value = ..GetValue(..Cursor)
    If value.Value { Do ..Jmp() }
    Else { Set ..Cursor = ..Cursor + 1 }
}

/// opcode 8 -> Jump if false
Method Jf()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Jf")
    Set value = ..GetValue(..Cursor)
    If 'value.Value { Do ..Jmp() }
    Else { Set ..Cursor = ..Cursor + 1 }
}

/// Opcode 9 -> add values and set
Method Add()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Add")
    Set addr = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Add")
    Set value1 = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Add")
    Set value2 = ..Memory.Get(..Cursor)
    Set sum = (value1.Value + value2.Value) # 32768
    Do ..MemSet(addr.Value,sum)
    Set ..Cursor = ..Cursor + 1
}

/// opcode 19 -> Write to console
Method Out()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Out")
    Set value = ..GetValue(..Cursor)
    Write $CHAR(value.Value)
    Set ..Cursor = ..Cursor + 1
}

/// opcode 21 -> No opperation
Method Noop()
{
    Do ..Debug(1,"Noop")
    Set ..Cursor = ..Cursor + 1
}

/// Debugging
Method Debug(level As %Integer, command As %String) As %Status
{
    If ..Debug {
        If ..DebugLines = 10 { 
            Read xx
            Set ..DebugLines = 0
        }
        Write !
        For i=1:1:level { Write *9 }
        Set value = ..GetValue(..Cursor,.loc)
        Write ..Cursor," : ",command," - ",value.Value," (",loc,")",*9
        Set ..DebugLines = ..DebugLines + 1
    }
}

/// Get The value -> raw value or value in registry
Method GetValue(index As %Integer, ByRef debug As %String) As SYNACOR.Value
{
    Set debug = "V"
    Set value = ..Memory.Get(index)
    If value.Value < 32768 { Return value }
    Set debug = "R ("_(value.Value-32768)_")"
    Return ..Registry.Get(value.Value-32768)
}

Method MemSet(index As %Integer, value As %Numeric)
{
    If index < 32768 {
        Do ..Memory.SetInt(index,value)
    }
    Else {
        Do ..Registry.SetInt(index-32768,value)
    }
}

}
