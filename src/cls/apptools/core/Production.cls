Include apptools.core

/// Utilities for group work with Ensemble or Interoperability products of different Namespaces
/// d ##class(apptools.core.Production).SaveAndStop()
/// d ##class(apptools.core.Production).StartAll()
Class apptools.core.Production [ Abstract ]
{

/// How long to wait for the product to stop before being stopped again by force (seconds)
Parameter TIMEOUTSTOP = 60;

Parameter SettingsGN = "^%apptools.core.Productions";

///  Check and save settings and status of products in all Namespaces
///  d ##class(apptools.core.Production).SaveStat(1)
ClassMethod SaveStat(resave = 0) As %Status
{
	s listns=##class(apptools.core.sys).ListNS(.inf,"NotPref,Ens")
	s GN=..#SettingsGN
	i 'resave,$d(@GN) w !,"Settings have already been saved. Rewrite ? [Y/N] <N>" r r q:$zconvert(r,"L")'["y"
	KILL @GN
	MERGE @GN=inf
	w !,"Updated "_GN,!!
	s ns=""
	f { s ns=$o(inf(ns)) q:ns=""
	 zw inf(ns,"Ens")
	}
 quit $$$OK
}

///  Save settings and status of products in all Namespaces; Stop all productions
///  d ##class(apptools.core.Production).SaveAndStop()
ClassMethod SaveAndStop() As %Status
{
	d ..SaveStat(1)
	d ..StopAll()
}

/// Remove autostart from all products; stop all products in Namespaces before restarting the OS
/// d ##class(apptools.core.Production).StopAll()
ClassMethod StopAll() As %Status
{
 d ..EnsAction("auto0")
 d ..EnsAction("stop")
 w !!,"ok"
 q
}

/// Check and restore autorun products in Namespaces, run all products that were launched
/// d ##class(apptools.core.Production).StartAll()
ClassMethod StartAll(nsOnly = "") As %Status
{
 	d ..EnsAction("auto1")
 	d ..EnsAction("start",nsOnly)
 	w !!,"ok"
 	q
}

/// Create new Interoperability Production (from diashenrique.messageviewer.util.InstallerProduction)
/// https://openexchange.intersystems.com/package/IRIS-Interoperability-Message-Viewer
/// write $System.Status.GetErrorText(##class(apptools.core.Production).CreateProduction("USER","Test.TestProd","Ens.MonitorService,Ens.Alerting.AlertManager,Ens.Activity.Operation.REST"))
/// zn "USER" do ##class(Ens.Director).StartProduction("Test.TestProd")
ClassMethod CreateProduction(ns = {$Namespace}, pn = "TestProduction", ConfItem = "") As %Status
{
	New $Namespace
	Set $Namespace = ns
	d ..Init(ns)
	Set sc = $$$OK
	Try {
		#; create new production
		Set class = ##class(%Dictionary.ClassDefinition).%New(pn)
		Set class.ProcedureBlock = 1
		Set class.Super = "Ens.Production"
		Set class.GeneratedBy = $ClassName()
		Set xdata = ##class(%Dictionary.XDataDefinition).%New()
		Set xdata.Name = "ProductionDefinition"
		Do xdata.Data.Write("<Production Name="""_pn_""" LogGeneralTraceEvents=""true""></Production>")	
		Do class.XDatas.Insert(xdata)
		Set sc = $$$ADDSC(sc,class.%Save())
		Set sc = $$$ADDSC(sc,$System.OBJ.Compile(pn,"fck-dv"))
		if ConfItem'="" {
			Set production = ##class(Ens.Config.Production).%OpenId(pn)
			for i=1:1:$l(ConfItem,",") { continue:$p(ConfItem,",",i)=""
				Set item = ##class(Ens.Config.Item).%New()
				Set item.ClassName = $p(ConfItem,",",i)
				Do production.Items.Insert(item)
				Set sc = $$$ADDSC(sc,production.%Save())
			}
		}
	}
    Catch (err) {
		Set sc = $$$ADDSC(sc,err.AsStatus())
	}
	Return sc
}

/// Creating tasks message cleaning
/// d ##class(apptools.core.Production).CreateTasksPurgeMess(30)
ClassMethod CreateTasksPurgeMess(days = 90) As %Status
{
	s listns=##class(apptools.core.sys).ListNS(.inf,"NotPref,Ens")	
	set ns=""
	for { set ns=$o(inf(ns)) q:ns=""
		continue:'$d(inf(ns,"Ens"))
	 	write !,ns," ",..CreateTaskPurge("Cleaning productions messages "_ns,ns,days)
	}
 quit $$$OK
}

/// Create a task to clean productions messages
///  w ##class(apptools.core.Production).CreateTaskPurge("Cleaning production messages "_$Namespace,$Namespace,7) }
ClassMethod CreateTaskPurge(Name As %String = "", ns = {$Namespace}, days = 90)
{
		Set Task=##Class(%SYSTEM.Task).%New()
		Set Task.Name=Name 
		Set Task.Type=0
		Set Task.Description=Name
		Set Task.TaskClass="Ens.Util.Tasks.Purge"
		#;Every day at 1:00 am
		Set Task.DailyStartTime=3600
		;Do Task.idSet(Number)
		Set Task.RunAsUser="SuperUser"
		Set Task.MirrorStatus=3
		s t=##class(Ens.Util.Tasks.Purge).%New()
		s t.KeepIntegrity=1
		s t.NumberOfDaysToKeep=days
		s t.BodiesToo=1
		s t.TypesToPurge="all"
		Set Task.Settings=t.GetSettings()
		s Task.NameSpace=ns
		q Task.%Save()
}

/// Initiate all Namespaces for the Ensemble\Interoperability
/// d ##class(apptools.core.Production).Init("USER")
ClassMethod Init(nsList = "") As %Status
{
 if nsList="" set nsList=##class(apptools.core.sys).ListNS(.inf,"NotPref")
	for i=1:1:$l(nsList) {
		continue:$p(nsList,",",i)=""
		do ##class(%EnsembleMgr).EnableNamespace($p(nsList,",",i),1) 
	}
	q $$$OK
}

/// Change products status in Namespaces
/// d ##class(apptools.core.Production).EnsAction("restart")
/// ex= "auto0" - clean all Namespaces of auto start products
/// ex= "auto1" - enable auto start products, restore from #SettingsGN(ns)
/// ex= "stop"  - stop all products
/// ex= "restart"  - reload all products
/// ex= "start"  - run the ones that were started, restore from #SettingsGN(ns)
/// ex= "status" - output statuses
/// ex= "info" - output of additional information about products and services with parameters d ##class(apptools.core.Production).EnsAction("info",,.out)
/// out - result ;d ##class(apptools.core.Production).EnsAction("status",$Namespace,.out)
ClassMethod EnsAction(ex = "", nsOnly = "", out) As %Status [ PublicList = (tProductionName, inf) ]
{
	;get all namespace with ensemble
	s listns=##class(apptools.core.sys).ListNS(.inf,"NotPref,Ens")
	#define NotSaveStat " settings not saved, to do ##class(apptools.core.Production).SaveStat(1) "
	$$$forAll(ns,inf)
	i nsOnly'="",nsOnly'=ns continue
	$$$NspGoto(curN,ns)
	i '$d(inf(ns,"Ens")) continue
	s GN=..#SettingsGN
	i ex'="info" w !!,"--- ",ns
	if ex="stop" {
		s sc=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP)
		i 'sc {
			s sc2=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP,1) 
			i 'sc2 w $System.Status.DisplayError(sc2)
		}
	}
	elseif ex="restart" {
		s sc=##class(Ens.Director).RestartProduction()
		i 'sc w $System.Status.DisplayError(sc)
	}
	elseif ex="start" {
		i '$d(@GN@(ns,"Ens")) w !,$$$NotSaveStat
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			continue:$lg(@GN@(ns,"Ens",tProductionName),1)'[$$$EnsProductStatusRun
			w !,ns," ",tProductionName
			Set sc = ##class(Ens.Director).StartProduction(tProductionName) ; Quit:$$$ISERR(tSC)
			i 'sc w $System.Status.DisplayError(sc)
		$$$forEnd	
	}
	if ex="auto0" {
		i '$d(@GN@(ns,"Ens")) w !,$$$NotSaveStat
			$$$NspGoto(curNs,ns)
			Set sc = ##class(Ens.Director).SetAutoStart("")
			i 'sc w $System.Status.DisplayError(sc)
			e  w " clean auto start"
			$$$NspReturn(curNs)
	} elseif ex="auto1" {
		i '$d(@GN@(ns,"Ens")) w !,$$$NotSaveStat
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			continue:'$lg(@GN@(ns,"Ens",tProductionName),4)
			$$$NspGoto(curNs,ns)
			Set sc = ##class(Ens.Director).SetAutoStart(tProductionName)
			i 'sc w $System.Status.DisplayError(sc)
			e  w " set auto start"
			$$$NspReturn(curNs)
		$$$forEnd		
	} elseif ex="status"||(ex="info") {
		i '$d(@GN@(ns,"Ens")) w !,$$$NotSaveStat
		Set sc = ##class(Ens.Director).GetProductionSummary(.pInfo, ns)	if ex'="info" w ! zw pInfo
		Set sc = ##class(Ens.Director).GetProductionSettings("",.tSettings)	if ex'="info" w ! zw tSettings
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			;continue:'$lg(@GN@(ns,"Ens",tProductionName),4)
			$$$NspGoto(curNs,ns)
			if ex'="info" w !,"Name production :"_tProductionName
			Set sc = ##class(Ens.Director).GetProductionStatus(tProductionName,.Stat)
			s stat=$s(Stat=1:"Running",Stat=2:"Stopped",Stat=3:"Suspended",Stat=4:"Troubled",1:"?")
			if ex'="info" w " Status :"_stat
			i 'sc w $System.Status.DisplayError(sc)
			s out(ns,tProductionName)=stat
			if ex="info" k ou d ..ExtInfo(tProductionName,.ou) m out(ns,tProductionName)=ou
			$$$NspReturn(curNs)
		$$$forEnd		
	}
	$$$forEnd
	if $g(curN)'="" $$$NspReturn(curN)
 	quit $$$OK
}

/// Extended Product Information
/// w $System.Status.GetErrorText(##class(apptools.core.Production).ExtInfo("Spgz.SpgzProduction",.o))
ClassMethod ExtInfo(pClassName, ou, write = 0) As %Status
{
	Set tSC = ##Class(Ens.Util.XML.Reader).ObjectFromXData(.tObject,pClassName,"ProductionDefinition","Ens.Config.Production")
	if 'tSC q tSC
	;zw tObject
	s json=$$$AppObJs(tObject)
	;Analysis of products into elements
	set Description={}.$$$jsonFromJSON(json).Description
	set Name={}.$$$jsonFromJSON(json).Name
	write:write !,Name_" "_Description
	s ou(Name)=Description
	;s Items={}.$$$jsonFromJSON(json).Items
	s items=[].$$$jsonFromJSON(json)."Items"
	if items'="" {
		for i=0:1:items.$$$jsonSize()-1 {
			set item = items.$$$jsonGet(i)
			i $isobject(item) {
				s itemIn=item.$$$jsonToJSON()
				s Enabled={}.$$$jsonFromJSON(itemIn).Enabled
				continue:'Enabled
				s NameIten={}.$$$jsonFromJSON(itemIn)."Name"
				write:write !," "_NameIten
				s ClassName={}.$$$jsonFromJSON(itemIn).ClassName
				s ou(Name,NameIten)=$lb(ClassName,{}.$$$jsonFromJSON(itemIn).Category)
				s Settings=[].$$$jsonFromJSON(itemIn).Settings
				
				for ii=0:1:Settings.$$$jsonSize()-1 {
					set setts = Settings.$$$jsonGet(ii)
					i $isobject(setts) {
						s sett=setts.$$$jsonToJSON()
						s Target={}.$$$jsonFromJSON(sett).Target
						s NameSett={}.$$$jsonFromJSON(sett).Name
						s Value={}.$$$jsonFromJSON(sett).Value
						k ip
						if Value["http" {
							s host=$p($p($p(Value,"://",2),"/",1),":",1)
							if host'="" s ip=##class(apptools.core.net).GetIP(host)
						}
						if NameSett="HTTPServer" s:Value'="" ip=##class(apptools.core.net).GetIP(Value)
						write:write !,"  "_NameSett_" "_Value_" "_$g(ip)
						s ou(Name,NameIten,NameSett)=Value
						s:$g(ip)'="" ou(Name,NameIten,NameSett,"ip")=$g(ip)
					}
				}
			}
		}
	}
	q $$$OK
}

/// d ##class(apptools.core.Production).getModelTable("User.model.",.result)
ClassMethod getModelTable(like, all) As %Status
{
	set sql = "SELECT cls.Name as ""Class Name"", cls.Description as ""Description"", prop.Name ""Property"",  prop.Type ""Type"",  prop.Description ""Description property"" FROM ""%Dictionary"".ClassDefinition cls  JOIN ""%Dictionary"".PropertyDefinition prop ON cls.Name = prop.parent WHERE cls.Name LIKE '"_like_"%'"
	;Genaration table for HTML
	set result="^||tmpPackgetModelTable"
	set st=##class(apptools.core.sys).SaveSQL(sql,result)
	 	d ..addstr(.all,$$$appTab3("Table name, Description table","Property, Type","Description type"))
	s row="0",last=""
	for { s row=$o(@result@(row)) q:row=""
		s tab=$lg(@result@(row),1)_", "_$lg(@result@(row),2)
		s tabpro=$lg(@result@(row),3)_", "_$lg(@result@(row),4)
		d ..addstr(.all,$$$appTableTrTd3($s(last=tab:"",1:tab),tabpro,$lg(@result@(row),5)))
		s last=tab
	}
	s %DrawArray=1
	d ..addstr(.all,$$$appTableEnd3)
	q $$$OK
}

/// add string to array
ClassMethod addstr(ByRef all, s) As %Status
{
	s all($i(all))=s_$c(13,10)
    q
}

/// Automatic generate documenation
/// CategotyDoc = Category Elements
/// filename - report html
/// namespacelist - if empty then all
/// title - Discriptions report
/// d ##class(apptools.core.Production).GenDoc("/home/project/shared/gen-doc.xml")
/// d ##class(apptools.core.Production).GenDoc("G:/!/gen-doc.xml")
ClassMethod GenDoc(filename = "", namespacelist = "", title = "Productions ", CategotyItem = "", StatusProd = 1) As %Status
{
	#define appTableAttr "border=1"
	new $namespace
	d ##class(apptools.core.Production).SaveStat(1)
	set:title="" subtitle="Productions documentation"
	if '##class(apptools.core.files).OpenFile(filename) quit:$$$ERROR($$$GeneralError,"Error open file "_filename)
	use filename		
	&html<
	<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<title>Productions</title>
	</head>
	<body><a name='0'>
			<h1>#(title)#</h1>
		>
	s bk=$c(13,10)
	;get information about active productions
	do ##class(apptools.core.Production).EnsAction("info",namespacelist,.proj)
	if $d(proj) {
		 set aNs=""
			 for { s aNs=$o(proj(aNs)) q:aNs=""
			 	d ..addstr(.all,bk_"<H2>Namespace "_aNs_"</H2>"_bk)
			 	d ..addstr(.all,$$$appTable3("Productions Name","Productions Item","Configuration"))
			 	set aNp="",lastprod=""
			 	for { s aNp=$o(proj(aNs,aNp)) q:aNp=""	;Name Production
			 		set aCp=""	
			 		for { s aCp=$o(proj(aNs,aNp,aCp)) q:aCp=""	;Class Production
			 			set aNb=""	
			 			for { s aNb=$o(proj(aNs,aNp,aCp,aNb)) q:aNb=""	;Name Elements
			 				s aClass=$lg(proj(aNs,aNp,aCp,aNb),1) ;Class Elements
			 				s aCategory=$lg(proj(aNs,aNp,aCp,aNb),2) ;Category Elements
						 	i aCategory'="",(" "_aCategory_" ")'[(" "_CategotyItem_" ") continue ;
			 				s aNbp="",listProp="<ul>"
			 				for { s aNbp=$o(proj(aNs,aNp,aCp,aNb,aNbp)) q:aNbp=""	;Name Property
			 					s listProp=listProp_"<li>"_aNbp_" :"_$g(proj(aNs,aNp,aCp,aNb,aNbp))
			 					if $g(proj(aNs,aNp,aCp,aNb,aNbp,"ip"))'="" {
				 					s listProp=listProp_"<ul><li>IP :<font color=red>"_$g(proj(aNs,aNp,aCp,aNb,aNbp,"ip"))_"</font></li></ul>"
			 					}
			 				}
			 				s listProp=listProp_"</ul>"
			 				s valprod=$$NoRepit(aNp,aCp)
			 				d ..addstr(.all,$$$appTableTrTd3($s(lastprod=(valprod):"",1:valprod),$$NoRepit(aNb,aClass)_", "_aCategory,listProp))
			 				s lastprod=valprod
			 			}
			 			
			 		}
			 	}
			 	d ..addstr(.all,$$$appTableEnd3)
			 }
	}
	w "<hr>"	
 	s a=""
 	for { s a=$o(all(a)) q:a=""
 		w $g(all(a))
 	}
 &html<
	</body></html>
	>
	close filename
	write !,"Output documentation in "_filename
	q $$$OK
NoRepit(a,b)
	q a_$s(a=b:"",1:", "_b)
}

///  d ##class(apptools.core.Production).FindAndDrawAllErr("Select * from Ens_Util.Log where Type='2' and TimeLogged>'2020-09-29 21:00' order by id desc",##class(apptools.core.sys).ListNS(.info,"NotPre,Ens"), .result)
ClassMethod FindAndDrawAllErr(sql, nspaces, result) As %String
{
	set GN=..#SettingsGN
	if '$Data(@GN) do ##class(apptools.core.Production).SaveStat(1)
	for i=1:1:$l(nspaces,",") { continue:$p(nspaces,",",i)=""||("%All"[$p(nspaces,",",i))
		$$$NspGoto(curNs,$p(nspaces,",",i))
		set NS=$p(nspaces,",",i)
		if '$D(@GN@(NS)) continue ; there is no namespace in the system, skip
		set PN=""
		set p="" for { set p=$o(@GN@(NS,"Ens",p)) quit:p=""
			if $lg($g(@GN@(NS,"Ens",p)),1)[$$$EnsProductStatusRun s PN=p quit
		}
		set onclicknone="$('.taberrors').css('display','none'); "
		set url="<b><a target='ensprod2"_($Namespace)_"' href='/csp/"_$zconvert($Namespace,"L")_"/EnsPortal.ProductionConfig.zen?$NAMESPACE="_$Namespace_"' >"_NS_"</a></b>"
		if PN="" write !,"<li>"_url_" no running products" continue
		if $Namespace'=NS s result(NS,"Err")="<br><font color=red>Go to error "_url_"</font>" w result(NS,"Err") continue
		
		set sql2=$replace(sql,"*","count(*)")
		set gn="tmpErrEns"
		do ##class(apptools.core.sys).SaveSQL(sql2,gn)
		set (ec,result(NS,"Count"))=$lg(@gn@(1),1)
		if ec {
			s onclick=onclicknone_"$('#div"_NS_"').css('display','block'); "
			s ec="<b><font color=red style='cursor:hand' onclick="""_onclick_""">Found "_ec_" errors</font></b>"
		} else { 
			set ec="<b><font color=green style='cursor:hand' onclick="""_onclicknone_"""> No errors found </font></b>"
		}
		write !,"<li>"_url_" "_ec_" <div class='taberrors' id='div"_NS_"' style='display:none'>"
		set exec="##class("_..%ClassName(1)_").AddTraceUrl(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp)"
		set st=##class(apptools.core.LogInfoPane).DrawSQL(sql,$g(Max,10000),$Namespace," Ensemble Errors ",exec)
		write !,"</div>"
		$$$NspReturn(curNs)
	}
}

/// Procedure for ##class(apptools.core.Production).AddTraceUrl
ClassMethod AddTraceUrl(Val, Col, Head, Temp, Del = 0) As %String
{
	set res=Val
	if $g(Head) {
		i $g(Val)="SessionId" s Temp("SessionId",Col)=""
	}
	else {
		if $D(Temp("SessionId",Col)) {
			set res="<a target=Trace"_Val_" title='Go to Visual Trace' href='"_"/csp/"_$Namespace_"/EnsPortal.VisualTrace.zen?SESSIONID="_Val_"' >"_Val_"</a>"
		}
	}
	quit res
}

///  do ##class(apptools.core.Production).GetQueryTotal(.info)
ClassMethod GetQueryTotal(ByRef total) As %String
{
	set serv="",total=0
	for { 	set serv=$order(^Ens.Queue(serv)) quit:serv=""
			set count=$get(^Ens.Queue(serv,0,"count"))
			set total(serv)=count
			if count {
				set total=$g(total)+count
			}
		}
	quit $$$OK
}

///  do ##class(apptools.core.Production).FindAndDrawAllQueue(##class(apptools.core.sys).ListNS(.info,"NotPre,Ens"))
ClassMethod FindAndDrawAllQueue(nspaces) As %String
{
	write "<Table>"
	for i=1:1:$l(nspaces,",") { continue:$p(nspaces,",",i)=""||("%All"[$p(nspaces,",",i))
		$$$NspGoto(curNs,$p(nspaces,",",i))
		if $Namespace'=$p(nspaces,",",i) continue
		if $DATA(^Ens.Queue) {
			set serv="",total=0
			set ns=$p(nspaces,",",i)
			do ..GetQueryTotal(.total)
			set csp="csp"
			set url="/"_csp_"/"_$zconvert(ns,"L")_"/EnsPortal.Queues.zen?$NAMESPACE="_ns
			write "<tr><td><a target=Que"_ns_" href='"_url_"'>"_ns_"</a></td><td>"_total_"</td></tr>"
		}
		$$$NspReturn(curNs)
	}
	write "</Table>"
}

/// do ##class(Spgz.ReloadItemProd).ReloadList("BP2,BP3")
ClassMethod ReloadList(list As %String) As %String
{
	for in=1:1:$L(list,",") {
		continue:$p(list,",",in)=""
		d ..Reload($p(list,",",in))
	}
	q $$$OK
}

ClassMethod Reload(item As %String) As %String
{
	do ##class(apptools.core.Production).GetQueryTotal(.info)
	if '$g(info(item)) {
		set st=##class(Ens.Director).EnableConfigItem(item,0)
		set st=##class(Ens.Director).EnableConfigItem(item)
		write !,item," reload"
	}
	else {
		write !,item," continue"
	}
	q $$$OK
}

/// do ##class(apptools.core.Production).ShowGlobals("^tmp**",##class(apptools.core.sys).ListNS(.info,"NotPre,Ens"))
ClassMethod ShowGlobals(gn, nspaces) As %String
{
	for i=1:1:$l(nspaces,",") { continue:$p(nspaces,",",i)=""||("%All"[$p(nspaces,",",i))
		$$$NspGoto(curNs,$p(nspaces,",",i))
		if $Namespace'=$p(nspaces,",",i) continue
		set a=$lb(gn,1000,$Namespace,1,"<b>"_$namespace_"</b> globals "_gn,$g(exp),$g(Filtr),$g(ExecuteDraw))
		write "<br><br>"
		set st=##class(apptools.core.LogInfoPane).DrawGN(a)
		$$$NspReturn(curNs)
	}
}

/// Get a list of product errors per day or more for one namespace
/// d ##class(apptools.core.Production).GetListErrProducts(1,"USER".res)
ClassMethod GetListErrProducts(day, NS, result) As %String
{

	new $namespace
	set sql="select ConfigName,Text,TimeLogged from Ens_Util.Log where Type='2' and TimeLogged>'"_##class(apptools.core.type).getYYYYMMDD($h-day)_" 21:00' order by id desc"
	set listns= ##class(apptools.core.sys).ListNS(.info,"NotPre,Ens")
	set GN="info" ;##class(apptools.core.Production).#SettingsGN
	if $D(@GN@(NS)) {
		zn NS
		if $Namespace'=NS quit ""
		set PN=""
		set p="" for { s p=$o(@GN@(NS,"Ens",p)) q:p=""
			if $lg($g(@GN@(NS,"Ens",p)),1)[$$$EnsProductStatusRun s PN=p quit
		}
		if PN="" q ""
		set gn="^||tmpErrEnsam" kill @gn
		do ##class(apptools.core.sys).SaveSQL(sql,gn)
		for i=1:1:10 {  
			if $d(@gn@(i)) {
			;k r m r(1)=@gn@(i)	;zw r  
			m result(i)=@gn@(i)
			}
		}
	}
 q $$$OK
}

/// Get the status of products for a day or more
/// d ##class(apptools.core.Production).GetStatusProducts(0,.res)
ClassMethod GetStatusProducts(day, result) As %String
{
	set result("server")=$zu(110)
		, result("version")=$zv
		
	if day=0 	quit $$$OK ;
	set sql="select * from Ens_Util.Log where Type='2' and TimeLogged>'"_##class(apptools.core.type).getYYYYMMDD($h-day)_" 21:00' order by id desc"
	set listns= ##class(apptools.core.sys).ListNS(.info,"NotPre,Ens")
	set GN="info" ;##class(apptools.core.Production).#SettingsGN
 	set NS=""
	set sql2=$replace(sql,"*","count(*)")
	set result("sql")=sql2
	set result("listns")=listns
	for { s NS=$o(@GN@(NS)) q:NS=""
		$$$NspGoto(curNs,NS)
		if $Namespace'=NS  continue
		if '$D(@GN@(NS)) continue
		set PN=""
		set p="" for { s p=$o(@GN@(NS,"Ens",p)) q:p=""
			if $lg($g(@GN@(NS,"Ens",p)),1)[$$$EnsProductStatusRun s PN=p quit
		}
		if PN="" continue

		set gn="^||tmpErrEns" kill @gn
		do ##class(apptools.core.sys).SaveSQL(sql2,gn)
		set result(NS,"CountErrors")=$lg(@gn@(1),1)
	}
	quit $$$OK
}

/// Get the status of products for a day or more to Json
/// d ##class(apptools.core.Production).GetStatusProductsJson(1,"system-stat",.res) zw res
/// d ##class(apptools.core.Production).GetStatusProductsJson(1,"count-errors",.res) zw res
/// d ##class(apptools.core.Production).GetStatusProductsJson(1,"list-errors-SPGZ",.res) zw res
ClassMethod GetStatusProductsJson(day, mode = 0, result) As %String
{
	set result={} 
	set result.server=$zu(110)
	set result.version=$zv		

	if mode="system-stat" {
		quit $$$OK
	}
	set result.ns=[]
	set sql="select * from Ens_Util.Log where Type='2' and TimeLogged>'"_##class(apptools.core.type).getYYYYMMDD($h-day)_" 21:00' order by id desc"
	set listns= ##class(apptools.core.sys).ListNS(.info,"NotPre,Ens")
	set gn="^||tmpErrEns" kill @gn
	if mode="count-errors" {
		set sql2=$replace(sql,"*","count(*)")
	}
	elseif mode["list-errors" {
		set sql2=$replace(sql,"*","ConfigName,Text,TimeLogged ")
		set NSpace=$p(mode,"list-errors-",2)
	}

	set NS=""
	for { s NS=$o(info(NS)) q:NS=""
		$$$NspGoto(curNs,NS)
		if $Namespace'=NS  continue
		if $GET(NSpace)'="",NS'=NSpace continue 
		if '$D(info(NS)) continue
		set PN=""
		set p="" for { s p=$o(info(NS,"Ens",p)) q:p=""
			if $lg($g(info(NS,"Ens",p)),1)[$$$EnsProductStatusRun s PN=p quit
		}
		if PN="" continue

		do ##class(apptools.core.sys).SaveSQL(sql2,gn)
		set prod = {}
		set prod.namespace = $namespace
		set prod.nameproduction = PN
		if mode="count-errors" {
			set prod.counterrors = $lg(@gn@(1),1)
		}
		elseif mode["list-errors" {
			set prod.errors = []
			for i=1:1:10 {  if $d(@gn@(i)) {
				set err = {}
				set err.ConfigName=$lg(@gn@(i),1)
				set err.Text=$lg(@gn@(i),2)
				set err.TimeLogged=$lg(@gn@(i),3)
				do prod.errors.%Push(err)
				}
			}
		}
		
		do result.ns.%Push(prod)
		
	}
}

/// Stoped production and dismount. Later mounted 
/// d ##class(apptools.core.Production).StopProdAndDismount("AAA")
/// w $System.Status.GetErrorText(##class(apptools.core.sys).MountListDB("AAA"))
ClassMethod StopProdAndDismount(ns) As %String
{
	new $namespace
	try {
		set $namespace=ns
		s sc=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP)
		if 'sc {
			s sc2=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP,1) 
			if 'sc2 write $System.Status.DisplayError(sc2) q
			set sc=$$$OK
		}
		set $namespace="%SYS"
		set sc=##class(apptools.core.sys).DismountListDB(ns)
		if 'sc {
			write $System.Status.DisplayError(sc) q
		}
		else {
			write !,"Dismount "_ns
		}
	} catch ex {
	   Set sc = $g(%objlasterror, $$$OK)
	   Set sc = $$$ADDSC(sc, ex.AsStatus())
	   write "Error type   "_ex.Name,!
	   write "Error code   "_ex.Code,!
	   write "Error location "_ex.Location,!
 	}
}

/// GetSettings
/// write ##class(apptools.core.Production).GetSettings("ProductionName","ItemName","SettName",.val)
ClassMethod GetSettings(ProductName = "", ItemName = "", SettingName = "", ByRef Value) As %Status
{

 #dim p As Ens.Config.Production
 Set p = ##class(Ens.Config.Production).%OpenId(ProductName)
 quit:p="" $$$ERROR($$$GeneralError,"Production not found: "_ProductName)
 #dim item As Ens.Config.Item
 #dim sett As Ens.Config.Setting
 set st=0
 for i=1:1:p.Items.Count() {
	 s item=p.Items.GetAt(i)
	 ;w !,item.Name
	 if item.Name=ItemName 	{
	 	for s=1:1:item.Settings.Count() {
	 		set sett=item.Settings.GetAt(s)
	 		;w !,sett.Name
	 		if sett.Name=SettingName set Value=sett.Value, st=$$$OK quit
	 	}
	 }
 }
 if 'st q $$$ERROR($$$GeneralError,"Settings or ItemName not found")
 quit st
}

}

