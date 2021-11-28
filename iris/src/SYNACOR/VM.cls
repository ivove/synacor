/// Synacor VM
Class SYNACOR.VM Extends %RegisteredObject
{

Property Memory As SYNACOR.Memory;

Property Registry As SYNACOR.Memory;

Property Stack As SYNACOR.Stack;

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
    Set ..Stack = ##class(SYNACOR.Stack).%New()
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
        ElseIf (current.Value = 2) { Do ..Push() }
        ElseIf (current.Value = 3) { Do ..Pop() }
        ElseIf (current.Value = 4) { Do ..Eq() }
        ElseIf (current.Value = 5) { Do ..Gt() }
        ElseIf (current.Value = 6) { Do ..Jmp() }
        ElseIf (current.Value = 7) { Do ..Jt() }
        ElseIf (current.Value = 8) { Do ..Jf() }
        ElseIf (current.Value = 9) { Do ..Add() }
        ElseIf (current.Value = 12) { Do ..And() }
        ElseIf (current.Value = 13) { Do ..Or() }
        ElseIf (current.Value = 17) { Do ..Call() }
        ElseIf (current.Value = 19) { Do ..Out() }
        Else { Do ..Noop() }
        //add
    }
}

/// opcode 0 -> stop execution and terminate the program
Method Halt()
{
    Do ..Debug(1,"Halt")
    Set ..Running = 0
}

/// opcode 1 a b -> set register <a> to the value of <b> 
Method Set()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Set")
    Set addr = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Set")
    Set value = ..GetValue(..Cursor)
    Do ..MemSet(addr.Value,value.Value)
    Set ..Cursor = ..Cursor + 1
}

/// Opcode 2 a -> push <a> onto the stack
Method Push()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Push")
    Set value = ..GetValue(..Cursor)
    Do ..Stack.Push(value)
    Set ..Cursor = ..Cursor + 1
}

/// Opcode 3 a -> remove the top element from the stack and write it into <a>; empty stack = error
Method Pop()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Pop")
    Set value = ..Stack.Pop()
    Set addr = ..Memory.Get(..Cursor)
    Do ..MemSet(addr.Value,value.Value)
    Set ..Cursor = ..Cursor + 1
}

/// opcode 4 a b c-> set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise
Method Eq()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Eq")
    Set addr = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Eq")
    Set value1 = ..GetValue(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Eq")
    Set value2 = ..GetValue(..Cursor)
    If (value1.Value = value2.Value) {
        Do ..MemSet(addr.Value,1)
    } Else {
        Do ..MemSet(addr.Value,0)
    }
    Set ..Cursor = ..Cursor + 1
}

/// Opcode 5 a b c -> set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise
Method Gt()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Gt")
    Set addr = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Gt")
    Set value1 = ..GetValue(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Gt")
    Set value2 = ..GetValue(..Cursor)
    If (value1.Value > value2.Value ) {
        Do ..MemSet(addr.Value,1)
    } Else {
        Do ..MemSet(addr.Value,0)
    }
    Set ..Cursor = ..Cursor + 1
}

/// opcode 6 a -> jump to <a>
Method Jmp()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Jmp")
    Set value = ..GetValue(..Cursor)
    Set ..Cursor = value.Value
}

/// opcode 7 a b -> if <a> is nonzero, jump to <b>
Method Jt()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Jt")
    Set value = ..GetValue(..Cursor)
    If value.Value { Do ..Jmp() }
    Else { Set ..Cursor = ..Cursor + 1 }
}

/// opcode 8 a b -> if <a> is zero, jump to <b>
Method Jf()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Jf")
    Set value = ..GetValue(..Cursor)
    If 'value.Value { Do ..Jmp() }
    Else { Set ..Cursor = ..Cursor + 1 }
}

/// Opcode 9 a b c -> assign into <a> the sum of <b> and <c> (modulo 32768)
Method Add()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Add")
    Set addr = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Add")
    Set value1 = ..GetValue(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Add")
    Set value2 = ..GetValue(..Cursor)
    Set sum = (value1.Value + value2.Value) # 32768
    Do ..MemSet(addr.Value,sum)
    Set ..Cursor = ..Cursor + 1
}

/// opcode 12 a b c -> stores into <a> the bitwise and of <b> and <c>
Method And()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"And")
    Set addr = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"And")
    Set value1 = ..GetValue(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"And")
    Set value2 = ..GetValue(..Cursor)
    set and = $BITLOGIC(value1.BitValue&value2.BitValue)
    do ..MemSetBit(addr.Value,and)
    set ..Cursor = ..Cursor + 1
}

/// Opcode 13 a b c -> stores into <a> the bitwise or of <b> and <c>
Method Or()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Or")
    Set addr = ..Memory.Get(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Or")
    Set value1 = ..GetValue(..Cursor)
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Or")
    Set value2 = ..GetValue(..Cursor)
    set and = $BITLOGIC(value1.BitValue|value2.BitValue)
    do ..MemSetBit(addr.Value,and)
    set ..Cursor = ..Cursor + 1
}

/// Opcode 17 a -> write the address of the next instruction to the stack and jump to <a>
Method Call()
{
    Set ..Cursor = ..Cursor + 1
    Do ..Debug(1,"Call")
    Set addr = ..Memory.Get(..Cursor)
    do ..Stack.Push(..Cursor + 1)
    set ..Cursor = addr.Value
}

/// opcode 19 a -> write the character represented by ascii code <a> to the terminal
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

Method MemSetBit(index As %Integer, value As %String)
{
    If index < 32768 {
        Do ..Memory.setBit(index,value)
    }
    Else {
        Do ..Registry.SetBit(index-32768,value)
    }
}

}
