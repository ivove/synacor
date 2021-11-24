/// Synacor VM
Class SYNACOR.VM Extends %RegisteredObject
{

/// Load the VM (read the memory dump to memory)
Method Load() As %Status
{
    Set sc = $$$OK
    #DIM filename As %String = "/shared/challenge.bin"  
    Set stream=##class(%Stream.FileBinary).%New()
    Set sc=stream.LinkToFile(filename)
    While 'stream.AtEnd {
        set char1 = stream.Read(1)
        set char2 = stream.Read(1)
        set value = ##class(SYNACOR.Value).Parse(char1,char2)
        write !,char1,"-",$FACTOR(char1),*9,char2,"-",$FACTOR(char2)
    } 
    Return sc
}

}
