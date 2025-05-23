Include apptools.core

Class apptools.core.Log Extends %Persistent
{

/// Replacement for missing values
Parameter Null = "Null";

/// Type of event
Property EventType As %String(MAXLEN = 10, VALUELIST = ",NONE,FATAL,ERROR,WARN,INFO,STAT,DEBUG,RAW") [ InitialExpression = "INFO" ];

/// Name of class, where event happened
Property ClassName As %String(MAXLEN = "");

/// Name of method, where event happened
Property MethodName As %String(MAXLEN = "");

/// Line of int code
Property Source As %String(MAXLEN = "");

/// Cache user
Property UserName As %String(MAXLEN = 128) [ InitialExpression = {$username} ];

/// Arguments' values passed to method
Property Arguments As %String(MAXLEN = "", TRUNCATE = 1);

/// Date and time
Property TimeStamp As %TimeStamp(XMLTIMEZONE = "IGNORE") [ InitialExpression = {$zdt($h, 3, 1)} ];

/// Identifies the job from which this event was logged.
Property Job As %String [ InitialExpression = {$job} ];

/// User message
Property Message As %String(MAXLEN = "", TRUNCATE = 1);

/// User IP address
Property ClientIPAddress As %String(MAXLEN = 32) [ InitialExpression = {..GetClientAddress()} ];

Index idxEventType On EventType [ Type = bitmap ];

Index idxUserName On UserName [ Type = bitmap ];

Index idxClassName On ClassName [ Type = bitmap ];

Index idxTimeStamp On TimeStamp [ Type = bitslice ];

Index idxClientIPAddress On ClientIPAddress;

/// apptools_core.Log_ConvertOutHTML(txt)
ClassMethod ConvertOutHTML(text As %String) As %String [ SqlProc ]
{
	q $zcvt(text, "O", "HTML")
}

/// Determine user IP address
/// write ##class(apptools.core.Log).GetClientAddress()
ClassMethod GetClientAddress()
{
	// %CSP.Session source is preferable
	#dim %request As %CSP.Request
	If ($d(%request)) {
		Return %request.CgiEnvs("REMOTE_ADDR")
	}
	Return $system.Process.ClientIPAddress()
}

/// Add new log event
/// Use via $$$LogEventTYPE().
/// Return ID log
///         write ##class(apptools.core.Log).AddRecord(ClassName, MethodName, Source, EventType, Arguments, Message)
/// Example do ##class(apptools.core.Log).AddRecord("I want", "log", "everything", "INFO", "actions", "users")
/// Kill - Do ##class(apptools.core.Log).%KillExtent()
ClassMethod AddRecord(ClassName As %String = "", MethodName As %String = "", Source As %String = "", EventType As %String = "", Arguments As %String = "", Message As %String = "")
{
	try {
		Set record = ..%New()
		Set record.Arguments = Arguments
		Set record.ClassName = ClassName
		Set record.EventType = EventType
		Set record.Message = Message
		Set record.MethodName = MethodName
		Set record.Source = Source
		set sc=record.%Save()
		set:sc id=record.%Id()
	} catch err {
		set id=""
	}
	
	quit $g(id)
}

/// Entry point to get method arguments string 
ClassMethod GetMethodArguments(ClassName As %String, MethodName As %String) As %String
{
	Set list = ..GetMethodArgumentsList(ClassName,MethodName)
	Set string = ..ArgumentsListToString(list)
	Return string
}

/// Get a list of method arguments
ClassMethod GetMethodArgumentsList(ClassName As %String, MethodName As %String) As %List
{
	Set result = ""
	Set def = ##class(%Dictionary.CompiledMethod).%OpenId(ClassName _ "||" _ MethodName)
	If ($IsObject(def)) {
		Set result = def.FormalSpecParsed
	}
	Return result
}

/// Convert list of method arguments to string
ClassMethod ArgumentsListToString(List As %List) As %String
{
	Set result = ""
	For i=1:1:$ll(List) {
		Set result = result _ $$$quote($s(i>1=0:"",1:"; ") _ $lg($lg(List,i))_"=") 
		_ ..GetArgumentValue($lg($lg(List,i)),$lg($lg(List,i),2))
		_$S(i=$ll(List)=0:"",1:$$$quote(";"))
	}
	Return result
}

ClassMethod GetArgumentValue(Name As %String, ClassName As %Dictionary.CacheClassname) As %String
{
	If $ClassMethod(ClassName, "%Extends", "%RegisteredObject") {
		// it's an object
		Return "_##class(apptools.core.Log).SerializeObject("_Name _ ")_"
	} Else {
		// it's a datatype
		Return "_$g(" _ Name _ ","_$$$quote(..#Null)_")_"
	}
}

/// Serialize the object to json
/// obj - the object
/// gn - global link to save flow
/// mode - the storage mode of the object see: /csp/log/apptools.core.LogInfo.cls?WHAT=?
/// w ##class(apptools.core.Log).SerializeObject(obj,"^gn","sveta")
ClassMethod SerializeObject(Object, gn = "", mode = "") As %String
{
	Return:'$IsObject(Object) Object
	if $ClassMethod(Object.%ClassName(1), "%Extends", "%Stream.Object") {
		d Object.Rewind() while '(Object.AtEnd) { 
			set:gn'="" @gn@($i(inc))=$zconvert(Object.Read(32000),"I","UTF8")
		}
		Return Object.%ClassName(1)_" %Extends %Stream.Object"
	} 
	Return ..WriteJSONFromObject(Object)
}

/// w ##class(apptools.core.Log).WriteJSONFromSQL("select * FROM %Library.sys_SQLConnection WHERE Connection_Name='postgres'")
ClassMethod WriteJSONFromSQL(sql As %String) As %Status
{
	#dim sc As %Status = $$$OK
	set provider = ##class(%ZEN.Auxiliary.altJSONSQLProvider).%New()
	set provider.maxRows = $$$MaxCacheInt
	set provider.%Format = $$$formatJSONSQL
	set provider.sql = sql
	if $isobject($g(%request)) {
		set provider.pageSize = %request.Get("size", 25)
		set provider.currPage = %request.Get("page", 1)
	}
	set sc = provider.%DrawJSON()
	return sc
}

/// w ##class(apptools.core.Log).WriteJSONFromObject(b) ;format As %String = "aeos" ;aceloqtw
ClassMethod WriteJSONFromObject(obj, format As %String = "tw", alt = 1) As %String [ ProcedureBlock = 0 ]
{
    set tOldIORedirected = ##class(%Device).ReDirectIO()
    set tOldMnemonic = ##class(%Device).GetMnemonicRoutine()
    set tOldIO = $io
    try {
        set str = ""
        use $io::("^" _ $ZNAME)
        do ##class(%Device).ReDirectIO(1)
		if $$$IsNewJSON {
			;##class(Form.JSON.OBJ).%ObjectToJSON(obj,,,"aeloqtwc")
			if alt {set jsobj = ##class(%ZEN.Auxiliary.altJSONProvider).%ObjectToAET(obj,,format)}
			else {set jsobj = ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToAET(obj,,format)}
			;write jsobj.%ToJSON()
        	set formatter = ##class(%JSON.Formatter).%New()
        	set sc = formatter.Format(jsobj)
		} else {
        	;##class(Form.JSON.OBJ).%ObjectToJSON(obj,,,$$$formatJSON)
        	if alt {do ##class(%ZEN.Auxiliary.altJSONProvider).%ObjectToJSON(obj,,,format)}
        	else {do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(obj,,,format)}
		}

    } catch ex {
        set str = ""
    }
    if (tOldMnemonic '= "") {
        use tOldIO::("^" _ tOldMnemonic)
    } else {
        use tOldIO
    }
    do ##class(%Device).ReDirectIO(tOldIORedirected)
    return str

rchr(c)
    quit
rstr(sz,to)
    quit
wchr(s)
    do output($char(s))
    quit
wff()
    do output($char(12))
    quit
wnl()
    do output($char(13,10))
    quit
wstr(s)
    do output(s)
    quit
wtab(s)
    do output($char(9))
    quit
output(s)
    set str = str _ s
    quit
}

/// Download the context of Protocol global
/// Example: d ##class(apptools.core.Log).Load("^logMSWstack(3)")
ClassMethod Load(gn) As %Status [ ProcedureBlock = 0 ]
{
	Return:gn'["^"||('$d(@gn)) $$$OK
	set key = ""
	if gn'["varList" {
		set GN=$na(@gn@("varList"))
		For { set key=$order(@GN@(key)) quit:key=""
			continue:key["%%%$$LOG^%ETN"||(key["%AppLogId")
			if key="%zlog" {
				set keyzlog="" 
				for { set keyzlog=$order(@GN@(key,keyzlog)) 
					quit:keyzlog=""
					do LoadNode($na(@GN@(key,keyzlog)),keyzlog)
				}
			} else {
				do LoadNode($na(@GN@(key)),key)
			}
		}
	} else {
		do LoadNode(gn,$qs(gn,$ql(gn)))
	}
	Kill key,gn,GN
	Return $$$OK
LoadNode(GNkey,key)
	try {
		// If in the json there is a _class
		if $Get(@GNkey)["_class"":" {
			set @key = ..DeserializeObject($Get(@GNkey),$p($p($Get(@GNkey),"_class"":",2),$c(34),2))
		}
		else {
			set @key=$Get(@GNkey)
		}
	} catch e { set LastErrorLoad=$ze}
	q
}

/// To load the context from the table Protocol
ClassMethod LoadContext(Id) As %Status [ ProcedureBlock = 0 ]
{
	Return:'..%ExistsId(Id) $$$OK
	Set Obj = ..%OpenId(Id)
	Set Arguments = Obj.Arguments
	Set List = ..GetMethodArgumentsList(Obj.ClassName,Obj.MethodName)
	For i=1:1:$Length(Arguments,";")-1 {
		Set Argument = $Piece(Arguments,";",i)
		Set @$lg($lg(List,i)) = ..DeserializeObject($Piece(Argument,"=",2,*),$lg($lg(List,i),2))
	}
	Kill Obj,Arguments,Argument,i,Id,List
}

ClassMethod DeserializeObject(String, ClassName) As %String
{
	If $ClassMethod(ClassName, "%Extends", "%RegisteredObject") {
		// it's an object
		Set st = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(String,,.obj)
		Return:$$$ISOK(st) obj
	}
	Return String
}

Query FindLog() As %SQLQuery(CONTAINID = 1)
{
SELECT %ID,ClassName,ClientIPAddress,EventType,Message,MethodName,Source,TimeStamp,UserName FROM Log
}

Storage Default
{
<Data name="LogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>EventType</Value>
</Value>
<Value name="3">
<Value>ClassName</Value>
</Value>
<Value name="4">
<Value>MethodName</Value>
</Value>
<Value name="5">
<Value>Source</Value>
</Value>
<Value name="6">
<Value>UserName</Value>
</Value>
<Value name="7">
<Value>Arguments</Value>
</Value>
<Value name="8">
<Value>TimeStamp</Value>
</Value>
<Value name="9">
<Value>Job</Value>
</Value>
<Value name="10">
<Value>Message</Value>
</Value>
<Value name="11">
<Value>ClientIPAddress</Value>
</Value>
</Data>
<DataLocation>^apptools.core.LogD</DataLocation>
<DefaultData>LogDefaultData</DefaultData>
<ExtentSize>4</ExtentSize>
<IdLocation>^apptools.core.LogD</IdLocation>
<IndexLocation>^apptools.core.LogI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Arguments">
<AverageFieldSize>44.75</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="ClassName">
<AverageFieldSize>23</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ClientIPAddress">
<AverageFieldSize>7.75</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="EventType">
<AverageFieldSize>6</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Job">
<AverageFieldSize>8.25</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Message">
<AverageFieldSize>21.25</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="MethodName">
<AverageFieldSize>8</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Source">
<AverageFieldSize>23</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="TimeStamp">
<AverageFieldSize>12.5</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="UserName">
<AverageFieldSize>84</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<SQLMap name="$Log">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="idxClassName">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="idxClientIPAddress">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="idxEventType">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="idxTimeStamp">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="idxUserName">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^apptools.core.LogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

