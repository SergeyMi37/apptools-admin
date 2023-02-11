/// Ping remote service 
Class apptools.Task.DatabaseStat Extends %SYS.Task.Definition
{

Property GlobalName As %String(MAXLEN = "") [ InitialExpression = "^%apptools.DatabaseStat" ];

Method OnTask() As %Status
{
	;If ..URL="" Quit $$$ERROR($$$GeneralError,"Invalid - URL - not supplied")
	s st=$$$OK 
	set gn=$na(@..GlobalName@($zd($h,3)))
	kill @gn
    set st=..GetStat(gn)
    q st
}

/// do ##class(apptools.Task.DatabaseStat).GetStat("^tmpDatabaseStat")
ClassMethod GetStat(gn)
{
	;do ##class(apptools.core.sys).SaveQuery("%SYS.DatabaseQuery:FreeSpace","^mtempGN",0)
	do ##class(apptools.core.rest).getDBsize("dbsize",.list)
    merge @gn@("dbsize")=list
    do ##class(apptools.core.sys).ListNS(.info)
    merge @gn@("namespace")=info
    set ns=""
    for { set ns=$Order(info(ns)) quit:ns=""
    	continue:ns="%ALL"
		w !,ns," ",##class(apptools.core.type).GetDateTime($h," ")
		do ##class(apptools.core.LogInfoPane).DrawGN($lb("^**",100000,ns,1),0,.res)
		;res="^||tmpGList("%SYS.GlobalQuery:NameSpaceList EIS tmp**",0)"
		w !,res
		merge @gn@("globals",ns)=@res
    }
    quit $$$OK
}

}

