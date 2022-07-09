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
Property TimeStamp As %TimeStamp [ InitialExpression = {$zdt($h, 3, 1)} ];

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
/// Example do ##class(apptools.core.Log).AddRecord("I want", "log", "everything", "INFO", "actions", "users")
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

/// w ##class(apptools.core.Log).WriteJSONFromObject(b) ;format As %String = "aeos" ;aceloqtw
ClassMethod WriteJSONFromObject(obj, format As %String = "tw") As %String [ ProcedureBlock = 0 ]
{
    set tOldIORedirected = ##class(%Device).ReDirectIO()
    set tOldMnemonic = ##class(%Device).GetMnemonicRoutine()
    set tOldIO = $io
    try {
        set str = ""
        use $io::("^" _ $ZNAME)
        do ##class(%Device).ReDirectIO(1)
		if $$$IsNewJSON {
			set jsobj = ##class(%ZEN.Auxiliary.altJSONProvider).%ObjectToAET(obj,,format)
			;write jsobj.%ToJSON()
        	set formatter = ##class(%JSON.Formatter).%New()
        	set sc = formatter.Format(jsobj)
		} else {
        	;do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(obj,,,format)
        	do ##class(%ZEN.Auxiliary.altJSONProvider).%ObjectToJSON(obj,,,format)
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
<Value>UserName</Value>
</Value>
<Value name="5">
<Value>MethodName</Value>
</Value>
<Value name="6">
<Value>Arguments</Value>
</Value>
<Value name="7">
<Value>TimeStamp</Value>
</Value>
<Value name="8">
<Value>Message</Value>
</Value>
<Value name="9">
<Value>ClientIPAddress</Value>
</Value>
<Value name="10">
<Value>Source</Value>
</Value>
<Value name="11">
<Value>Job</Value>
</Value>
</Data>
<DataLocation>^apptools.core.LogD</DataLocation>
<DefaultData>LogDefaultData</DefaultData>
<ExtentSize>354</ExtentSize>
<IdLocation>^apptools.core.LogD</IdLocation>
<IndexLocation>^apptools.core.LogI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,16,$lb("-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000"),$lb(21,21,21,21,21,21,21,21,21,21,21,21,21,21,21),$lb(758198320,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,758198320))</Histogram>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3.28</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,1,0,$lb(1,24,48,72,96,120,144,168,192,216,239,262,285,308,331,354),$lb(0,0,0,0,0,1,1,1,0,1,1,1,0,1,1),$lb(822083584,822083584,842268672,842268672,876085248,876085248,926023680,926023680,959840256,959840256,825372672,842006528,875823104,875823104,909639680,909639680,959578112,825831936,842085888,825622528,859373568,859373568,909246464,909246464,942997504,842544384,858798080,808976384,858849280,858849280,892600320,859124736))</Histogram>
<Selectivity>1</Selectivity>
</Property>
<Property name="Arguments">
<AverageFieldSize>79.54</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" SENT TO CHERNYSHOVA_EE@MOSVODOKANAL.RU FILE"," SENT TO CHERNYSHOVA_EE@MOSVODOKANAL.RU,MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO MAZYARKINA_ON@MOSVODOKANAL.RU,MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO SHURSHIKOVA_EG@MOSVODOKANAL.RU,MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO SMAGINA_TG@MOSVODOKANAL.RU,MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO SMAGINA_TG@MOSVODOKANAL.RU,MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," SENT TO SMAGINA_TG@MOSVODOKANAL.RU,MIHAYLENKO_SV@MOSVODOKANAL.RU FILE"," НАПРАВЛЕНО ПО АДРЕСУ MIHAYLENKO_SV@MOSVODOKANAL.RU ФАЙЛА"," ОШИБКА #5005: НЕВОЗМОЖНО ОТКРЫТЬ ФАЙЛ '/BACKUP/TEMP/GIS-CPICOK-OTVETOV-OT-MBC-V-GIC-ZKX-2022-02-15_152055.XLSX'"," ОШИБКА #6167: AUTHENTICATION EXPECTED BUT FAILED."," ОШИБКА #6167: AUTHENTICATION EXPECTED BUT FAILED."),$lb(39,9,10,44,44,44,44,9,10,71,71,1,1,9,51),$lb(542328142,541477196,743262536,1128809810,1296128601,1096440129,1229472089,0,0,0,0,0,0,0,0,1296648257,1397249362,1213551187,1296123721,0,0,0,0,1397050964,3500003472,3500003472,3500069032,892350517,909194807,0,0,550543056))</Histogram>
<OutlierSelectivity>.358757:"Sent to mihaylenko_sv@mosvodokanal.ru file "</OutlierSelectivity>
<Selectivity>2.4663%</Selectivity>
</Property>
<Property name="ClassName">
<AverageFieldSize>23</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"," APPTOOLS.CORE.LOGINFO"),$lb(23,23,23,23,23,23,23,23,23,23,23,23,23,23,23),$lb(541151312,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,541151312))</Histogram>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ClientIPAddress">
<AverageFieldSize>14.05</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 172.16.0.230"," 192.168.195.192"),$lb(14,14,14,14,14,14,14,14,14,14,14,14,14,14,2),$lb(540096306,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,926035505,959589937,540096818))</Histogram>
<OutlierSelectivity>.983051:"172.16.0.230"</OutlierSelectivity>
<Selectivity>0.8475%</Selectivity>
</Property>
<Property name="EventType">
<AverageFieldSize>6.14</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" ERROR"," ERROR"," ERROR"," INFO"," INFO"," INFO"," INFO"," INFO"," INFO"," INFO"," INFO"," INFO"," INFO"," INFO"," INFO"," INFO"),$lb(7,7,1,6,6,6,6,6,6,6,6,6,6,6,6),$lb(541413970,0,0,0,0,1163022927,1229866575,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,541675078))</Histogram>
<OutlierSelectivity>.864407:"INFO"</OutlierSelectivity>
<Selectivity>13.5593%</Selectivity>
</Property>
<Property name="Job">
<AverageFieldSize>6.79</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" 10000"," 12307"," 14531"," 16267"," 16791"," 17918"," 19502"," 22604"," 25658"," 27830"," 28117"," 29852"," 30799"," 5018"," 7833"," 9942"),$lb(2,2,2,3,2,2,1,2,2,2,2,1,1,1,1),$lb(540094512,808464432,842215479,842215479,875901745,875901745,909260343,842413824,926494976,909588785,926495032,926495032,959787058,825832752,842151472,842412084,892745016,892745016,926430000,926430000,942747959,942747959,959984946,842610741,858797881,858797881,892350776,892350776,926430003,926430003,960050226,540621108))</Histogram>
<Selectivity>0.7634%</Selectivity>
</Property>
<Property name="Message">
<AverageFieldSize>4</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"," ()"),$lb(4,4,4,4,4,4,4,4,4,4,4,4,4,4,4),$lb(539502848,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,539502848))</Histogram>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="MethodName">
<AverageFieldSize>11</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"," SENDEMAIL"),$lb(11,11,11,11,11,11,11,11,11,11,11,11,11,11,11),$lb(542328142,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,542328142))</Histogram>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Source">
<AverageFieldSize>41.64</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" ZBASE64ENCODE+4^%NET.SMTP.1 +1"," ZSENDEMAIL+17^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+17^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+19^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"," ZSENDEMAIL+20^APPTOOLS.CORE.LOGINFO.1 +1"),$lb(2,42,13,12,42,42,42,42,42,42,42,42,42,42,42),$lb(542786113,1111577413,1397050948,0,0,928923984,962478416,825843265,842030657,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,542790469))</Histogram>
<OutlierSelectivity>.737288:"zSendEmail+20^apptools.core.LogInfo.1 +1"</OutlierSelectivity>
<Selectivity>4.3785%</Selectivity>
</Property>
<Property name="TimeStamp">
<AverageFieldSize>21</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb("2020-12-05 23:23:44","2021-08-09 11:41:06","2021-09-16 11:09:19","2022-01-21 12:24:11","2022-02-15 15:39:21","2022-02-22 13:05:28","2022-03-22 09:06:59","2022-03-23 08:31:58","2022-04-13 07:59:54","2022-04-20 09:10:42","2022-04-28 08:03:11","2022-05-19 08:04:07","2022-05-23 08:24:23","2022-06-06 07:42:51","2022-06-17 08:00:17","2022-06-28 07:57:45"),$lb(3,6,3,6,8,6,9,6,8,9,6,8,6,8,8),$lb(842019376,808268082,825045048,942485561,959263030,825045049,841822257,825045553,841822517,825565233,842145841,841822770,858599986,840970297,857747512,858599987,875376947,825434160,842014768,807415865,941633592,875377208,892154169,825827376,842211376,892154419,908931126,808853552,825696304,825696304,842539056,842019378))</Histogram>
<Selectivity>0.2959%</Selectivity>
</Property>
<Property name="UserName">
<AverageFieldSize>5</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"," MSW"),$lb(5,5,5,5,5,5,5,5,5,5,5,5,5,5,5),$lb(541938519,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,541938519))</Histogram>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="$Log">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-44</BlockCount>
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

Query FindLog() As %SQLQuery(CONTAINID = 1)
{
SELECT %ID,ClassName,ClientIPAddress,EventType,Message,MethodName,Source,TimeStamp,UserName FROM Log
}

}

