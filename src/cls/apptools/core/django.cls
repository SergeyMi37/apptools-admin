Include apptools.core

/// Utilities for Django
Class apptools.core.django [ Abstract ]
{

/// Global Name Store Referens
Parameter GN = "^%apptools.django";

/// Get base responce
ClassMethod GetResp(arg = "") As %String
{
	set js={}
	set js.status="ok"
	set js.instance = $ZU(86)
	set js.version=$zv
	set:arg'="" js.django={}.%FromJSON(arg)   //"AnonymousUser"
	quit js
}

/// TimeStamp
/// w ##class(apptools.core.django).TS(,.json)
ClassMethod TS(arg = "", js) As %String
{
	set js=..GetResp(arg)
	set js.datetime= $ZDT($NOW()+0,3,1,3)_" "_##class(apptools.core.type).GetValidZT($h)
	set js.zts= $zts
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Alerts Systems
/// w ##class(apptools.core.django).Alerts(,.json)
ClassMethod Alerts(arg = "", js = "") As %String
{
	set js=..GetResp(arg)
	do ##class(apptools.core.rest).GetAlertsSys(,.js,0)
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Status Systems
ClassMethod SS(arg = "", js) As %String
{
	set js=..GetResp(arg)
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Get Info for Footer
/// w ##class(apptools.core.django).GetFooter("")
ClassMethod GetFooter(arg = "", js) As %String
{
	set js=..GetResp(arg)
	try {
		set js.host=$zu(110)
		;if 'js.django.authenticated quit 
		do ##class(apptools.core.net).GetURI(.prop)
		do ##class(apptools.lte.info).GetTopMenuFavorites(.opt,$lb("1","name"))	
		;set ip=##class(apptools.core.net).GetIP()
		;set js.ip=ip
		set js.webport=$g(prop("WebServerPort"))
		set js.apps = []
		set uri=js.django.absoluteuri ;request.build_absolute_uri()
		if js.django.irishost="iris",js.django.irisport="1972" {
			if $d(@..#GN@("uri"),uri) {
				}
			elseif ##class(apptools.core.files).ReadFile("/irisdev/app/docker-compose.yml",.txt,1) { 	// if we are in the docker, then we will find the port   
				set port=$p($p(txt,":52773")," ",*)
				if port="" set port=52773
				set uri=$p(uri,":",1,2)_":"_port
				set @..#GN@("uri")=uri
			}
		}
		elseif js.django.irishost'="iris" {
			set uri="http://"_js.django.irishost_":"_prop("WebServerPort")
		}
		set i=""
		for { set i=$o(opt(i)) quit:i=""
			set app={}
			set app.name=opt(i,"TabName")
			set app.url=uri_opt(i,"InFrameUrl")
			do js.apps.%Push(app)
		}
	}
	catch e { 
		set js.status="error "_$ze
	}
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Get Info for Managment Portal
/// w ##class(apptools.core.django).GetPortal("",.js)
ClassMethod GetPortal(arg = "", js) As %String
{
	set js=..GetResp(arg)
	try {
		;if 'js.django.authenticated quit 
		set gn="^||tmp",
			gnTab="^||tmpTab"
		set %Param=js.django.arg
		
		if %Param["iditem=" {
			set iditem=$p(%Param,"iditem=",2)
			set data=##class(apptools.core.django).AddIdItem(,iditem)
			set method=$lg(data,1),id=$lg(data,2),ns=$lg(data,3)
			set js.title=ns_", "_method_", " _id
			set js.draw="Form for "_%Param
			quit
		}
		elseif %Param="" {
			set js.prod={}
			set js.prod.count=##class(apptools.core.django).GetPortalProd(0,gn)
			set js.proc={}
			set js.proc.count=##class(apptools.core.django).GetPortalProc(0,gn)
			set js.lock={}
			set js.lock.count=##class(apptools.core.django).GetPortalLock(0,gn,gnTab)
			set js.db={}
			set js.db.count=##class(apptools.core.django).GetPortalNS(0,gn,"Databases")
			set js.ns={}
			set js.ns.count=##class(apptools.core.django).GetPortalNS(0,gn,"Namespaces")
			set js.roles={}
			set js.roles.count=##class(apptools.core.django).GetPortalApps(0,gn,"Security.Roles"," ")
			set js.users={}
			set js.users.count=##class(apptools.core.django).GetPortalApps(0,gn,"Security.Users"," ")
			set js.apps={}
			set js.apps.count=##class(apptools.core.django).GetPortalApps(0,gn,"Security.Applications"," ")
			set js.serv={}
			set js.serv.count=##class(apptools.core.django).GetPortalApps(0,gn,"Security.Service"," ")
			set js.res={}
			set js.res.count=##class(apptools.core.django).GetPortalApps(0,gn,"Security.Resources"," ")
			set js.tasks={}
			set js.tasks.count=##class(apptools.core.django).GetPortalApps(0,gn,"%SYS.Task"," ")
			set js.alerts={}
			do ##class(%SYSTEM.Monitor).GetAlerts(,.str,.last)
			set st=$o(str(""),-1)
			set js.alerts.count=+st
		}
		elseif %Param["Namespaces" {
			do ##class(apptools.core.django).GetPortalNS(1,gn,"Namespaces"," ",gnTab)
		}
		elseif %Param["Databases" {
			do ##class(apptools.core.django).GetPortalNS(1,gn,"Databases"," ",gnTab)
		}
		elseif %Param["Process" {
			do ##class(apptools.core.django).GetPortalProc(1,gn,,,gnTab)
		}
		elseif %Param["Products" {
			do ##class(apptools.core.django).GetPortalProd(1,gn,,gnTab)
		}
		elseif %Param["Locktab" {
			do ##class(apptools.core.django).GetPortalLock(1,gn, gnTab)
		}
		elseif %Param["Apps" {
			do ##class(apptools.core.django).GetPortalApps(1,gn,"Security.Applications"," ",gnTab)
		}
		elseif %Param["Roles" {
			do ##class(apptools.core.django).GetPortalApps(1,gn,"Security.Roles"," ",gnTab)
		}
		elseif %Param["Users" {
			do ##class(apptools.core.django).GetPortalApps(1,gn,"Security.Users"," ",gnTab)
		}
		elseif %Param["Services" {
			do ##class(apptools.core.django).GetPortalApps(1,gn,"Security.Service"," ",gnTab)
		}
		elseif %Param["Resources" {
			do ##class(apptools.core.django).GetPortalApps(1,gn,"Security.Resources"," ",gnTab)
		}
		elseif %Param["Tasks" {
			do ##class(apptools.core.django).GetPortalApps(1,gn,"%SYS.Task"," ",gnTab)
		}
		elseif %Param["cpf" {
			set path=$p($ZU(86),"*")
			do ##class(apptools.core.django).GetPortalFile(path,gn, gnTab)
		}
		elseif %Param["Messages" {
			set path=##class(apptools.core.files).getPathcconsole() ;$ZU(12)
			do ##class(apptools.core.django).GetPortalFile(path,gn, gnTab)
		}
		elseif %Param["Alerts" {
			do ##class(%SYSTEM.Monitor).GetAlerts(,.str,.last)
			set i=""
			do ##class(apptools.core.sys).SetTableHeader(gnTab,"DataTime","PID","Level","Messages")
			for { set i=$o(str(i)) quit:i=""
				do ##class(apptools.core.sys).SetTableRow(gnTab,i,$p(str(i)," ",1),$p(str(i)," ",2),$p(str(i)," ",3),$p(str(i)," ",4,*))
			}
			do ##class(apptools.core.sys).SetTableFooter(gnTab)
			set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gnTab_""",10000,$zu(5),"" "",,,"""")"
			do ##class(apptools.core.sys).Run2Spool(run,gn)
		}
		if %Param["-csv" {  //example  
			do ..Table2Json(js,gnTab)
		}
		else {
			set out=$g(@gn)
			set js.draw=$p(out,("</table>"),1)_"</table>"
		}
	}
	catch e { 
		set js.status="error "_$ze
	}
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// set js={} do ##class(apptools.core.django).Table2Json(js,"^||test")
ClassMethod Table2Json(obj, gn) As %Status
{
	set cols=@gn@(0)
	set obj.table=[]
	for row=1:1 { quit:'$d(@gn@(row),data)
		set arr={}
		for col=1:1 { quit:$lg(cols,col)=""
			set key=$lg(cols,col)
			set val=$lg(data,col)
			set st = arr.$$$jsonSet(key, val)
		}
		do obj.table.%Push(arr)
	}
	quit $$$OK
}

/// do ##class(apptools.core.django).GetPortalApps(1,"^tmpNS","Namespaces"," ")
ClassMethod GetPortalApps(count, gn, mode = "Security.Applications", %Param = "", gnTab) As %String
{
	new $namespace
	set $namespace= "%SYS" 
	set:mode="Security.Applications" %sql="select count(*) FROM Security.Applications"
	set:mode="Security.Users" %sql="select count(*) FROM Security.Users"
	set:mode="Security.Roles" %sql="select count(*) FROM Security.Roles"
	set:mode="Security.Service" %sql="select count(*) FROM Security.Services"
	set:mode="Security.Resources" %sql="select count(*) FROM Security.Resources"
	set:mode="%SYS.Task" %sql="select count(*) FROM %SYS.Task"
	if 'count {
		do ##class(apptools.core.sys).sql2gn(%sql,"",gn)
		quit +$lg($g(@gn@(1)))
	}
	else { 
		set:mode="Security.Roles" %sql=$replace(%sql,"count(*)","Name,Description,GrantedRoles")
		set:mode="Security.Users" %sql=$replace(%sql,"count(*)","Name,FullName,Enabled,ExpirationDate")
		set:mode="Security.Applications" %sql=$replace(%sql,"count(*)","Name,Description,NameSpace,Path,DispatchClass")
		set:mode="Security.Service" %sql=$replace(%sql,"count(*)","Name,Description,AutheEnabledCapabilities,Capabilities")
		set:mode="Security.Resources" %sql=$replace(%sql,"count(*)","Name,Description,Type")
		set:mode="%SYS.Task" %sql=$replace(%sql,"count(*)","ID,Name,Description,DisplayRun,DisplayStartDate,DisplayStarted,DisplayStatus,ER")
	}
	do ##class(apptools.core.sys).sql2gn(%sql,"",gnTab)
	if gn="" quit 1
	set %AppLogInfoTemp("colomn")="Name",%AppLogInfoTemp("method")=mode
	set %exec="##class(apptools.core.django).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gnTab_""",10000,$zu(5),%Param,%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

/// w ##class(apptools.core.django).GetPortalFile("C:\InterSystems\IRISHealth\mgr\messages.log","^||tmpL","^||tmpL2")
ClassMethod GetPortalFile(path, gn, gnTab) As %String
{
	kill @gn
	if ##class(apptools.core.files).ReadFile(path,.txt,0,3000000) {
		set txt="<b>"_path_"</b>"_$c(10)_txt
		set @gn=$replace(txt,$c(10),"<br>")
		;set size=##class(apptools.core.files).File2Arr(path,gnTab)
	}
 	quit $$$OK
}

/// w ##class(apptools.core.django).GetPortalLock(1,"^||tmpL")
ClassMethod GetPortalLock(count, gn, gnTab) As %String
{
	new $namespace
	set $namespace= "%SYS" 
	do ##class(apptools.core.sys).SaveQueryTab("%SYS.LockQuery:List",gnTab)
	set %AppLogInfoTemp("colomn")="DelKey",%AppLogInfoTemp("method")="Locktab"
	set %exec="##class(apptools.core.django).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gnTab_""",100000,$zu(5),"" "",%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn,,.counts)
	if 'count {
		quit +$g(counts)
	}
	quit 0
}

/// do ##class(apptools.core.django).GetPortalProd(1,"^tmpNSoutpot"," ")
ClassMethod GetPortalProd(count, gn, %Param = " ", gnTab) As %String
{
	new $namespace
	set $namespace= "%SYS" 
	if count=0 {
		quit ..GetPortalProds(0)
	}
	d ..GetPortalProds(1,gnTab)
	set %AppLogInfoTemp("colomn")="ProductName",%AppLogInfoTemp("method")="Products"
	set %exec="##class(apptools.core.django).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gnTab_""",10000,$zu(5),%Param,%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

/// do ##class(apptools.core.django).GetPortalProds(1,"^tmpNSoutpot"," ")
ClassMethod GetPortalProds(count, gn, %Param = " ") As %String
{
	new $namespace
	set listns=##class(apptools.core.sys).ListNS(.inf,"NotPref,Ens")
		;do ##class(apptools.core.Production).EnsAction("info",,.out)
		set i="",coun=0
		do:count ##class(apptools.core.sys).SetTableHeader(gn,"NameSpace","ProductName","Status")
		for { set i=$o(inf(i)) quit:i=""
			if $d(inf(i,"Ens")) {
				set $namespace= i
				set p=""
				for { set p=$o(inf(i,"Ens",p)) quit:p=""
					set coun=coun+1
					if count {
						Set sc = ##class(Ens.Director).GetProductionStatus(p,.Stat)
						s stat=$s(Stat=1:"Running",Stat=2:"Stopped",Stat=3:"Suspended",Stat=4:"Troubled",1:"?")
						if stat="Running" set stat="<b>"_stat_"</b>"
						do ##class(apptools.core.sys).SetTableRow(gn,coun,i,p,stat)
						
					}
				}
			}
		}
		do:count ##class(apptools.core.sys).SetTableFooter(gn)
	quit coun
}

/// do ##class(apptools.core.django).GetPortalProc(1,"^tmpNSoutpot","Namespaces"," ")
ClassMethod GetPortalProc(count, gn, SectionHeader = "Namespaces", %Param = " ", gnTab) As %String
{
	new $namespace
	set $namespace= "%SYS" 
	if 'count {
		set %sql="select count(*) from %SYS.ProcessQuery"
		do ##class(apptools.core.sys).sql2gn(%sql,"",gn)
		quit +$lg($g(@gn@(1)))
	}
	else { 
		;set %sql="select Pid,NameSpace, Routine, CPUTime,LinesExecuted,CurrentLineAndRoutine,GlobalReferences,LastGlobalReference, State,PidExternal,UserName,ClientIPAddress,ClientNodeName,CurrentDevice,ClientExecutableName,MemoryAllocated,MemoryUsed,	OpenDevices,CSPSessionID, InTransaction,LicenseUserId,Priority,Roles from %SYS.ProcessQuery"
		set %sql="select Pid,NameSpace, Routine, CPUTime,LinesExecuted,CurrentLineAndRoutine,GlobalReferences, State,UserName from %SYS.ProcessQuery"
	}
	do ##class(apptools.core.sys).sql2gn(%sql,"",gnTab,100000)
	set %AppLogInfoTemp("colomn")="Pid",%AppLogInfoTemp("method")="Process"
	set %exec="##class(apptools.core.django).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gnTab_""",10000,$zu(5),%Param,%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

/// Procedure for ##class(apptools.core.django).AddUrl
ClassMethod AddUrl(Val, Col, Head, Temp, Del = 0) As %String
{
	set res=Val
	if $g(Head) {
		i $g(Val)=$g(Temp("colomn")) s Temp($g(Temp("colomn")),Col)=""
		i $g(Val)="NameSpace" s Temp("NameSpace",Col)=""
	}
	else {
		if $D(Temp("NameSpace",Col)) set %namespace=Val
		if $D(Temp($g(Temp("colomn")),Col)) {
			set item=..AddIdItem($lb(Temp("method"),Val,%namespace))
			set res="<a target=mp_item title='Go to Items panel' href='/iris_mp_item?iditem="_item_"' >"_Val_"</a>"
		}
	}
	quit res
}

/// Procedure for ##class(apptools.core.django).AddIdItem("temp",123)
ClassMethod AddIdItem(lb = "", iditem = "") As %String
{
	set gn=$na(@..#GN@(+$h))
	set gnn=$na(@..#GN@($h-1))
	if $d(@gnn) KILL @gnn set @gn=+$h
	if '$d(@gn) set @gn=+$h ;init node new day
	if iditem, $d(@gn@(iditem),data) quit data
	set item=$i(@gn)
	set @gn@(item)=lb
	quit item
}

/// do ##class(apptools.core.django).GetPortalNS(1,"^tmpNS","Namespaces"," ")
ClassMethod GetPortalNS(count, gn, SectionHeader = "Namespaces", %Param = "", gnTab) As %String
{
	new $namespace
	set $namespace= "%SYS" 
	if 'count {
		set %sql="select count(*) from Config.Namespaces where SectionHeader = '"_SectionHeader_"'"
		do ##class(apptools.core.sys).sql2gn(%sql,"",gn)
		quit +$lg($g(@gn@(1)))
	}
	else { 
		set tabs=""
		if SectionHeader = "Namespaces" set tabs=",Routines ,SysGlobals,SysRoutines,TempGlobals"
		set %sql="select Name, Globals"_tabs_" from Config.Namespaces where SectionHeader = '"_SectionHeader_"'"
	}
	;set st=##class(apptools.core.LogInfoPane).DrawSQL(%sql,10000,$zu(5),%Param,%exec,,"""")
	do ##class(apptools.core.sys).sql2gn(%sql,"",gnTab,100000)
	set %AppLogInfoTemp("colomn")="Name",%AppLogInfoTemp("method")=SectionHeader
	set %exec="##class(apptools.core.django).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gnTab_""",10000,$zu(5),%Param,%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

}

