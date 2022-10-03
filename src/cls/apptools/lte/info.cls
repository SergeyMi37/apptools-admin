Include apptools.core

/// http://localhost:52773/apptoolsrest/a/info
Class apptools.lte.info Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Info";

/// Global Name Store Referens files
Parameter GNStore = "^%apptools.Info";

/// Roles
Parameter AppRoles = "ui_Info";

/// Default query to productions logs
Parameter DefaultQuery = "Select * from Ens_Util.Log where Type='2' and TimeLogged>? order by id desc";

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set base64=##class(apptools.core.rest).getStatic(..%ClassName(1)_":info")
 set path=par("=path=")
 set par("=Brand-Text=")=$system
 set par("=Logo-image=")=base64
 set par("=titleAppToolsadmin=")=$system ;..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(,"png",base64)
 set par("<!--FooterLeft-->")=$system_" - "_$zv
 set par("<!--FooterRight-->")="<a target='license' href=""/csp/sys/op/UtilDashboard.csp?$NAMESPACE=%25SYS""> "_$$$aText("System Dashboard","")_"</a>"
 quit ..RepaceParameter(.h,.par)
}

/// what modes are available
ClassMethod GetAllApps(opt) As %Status
{
	;side menu
	set sideMenuName="Configuration",
		sideMenuNumer=1,
		sideMenuOpen=1,        //3 =1 open menu
		sideMenuIcon="fa-cog"  //4  icon   https://fontawesome.com/icons?d=gallery&p=2&m=free
		set sideMenu=$lb(sideMenuNumer,sideMenuName,sideMenuOpen,sideMenuIcon) 
		set key="Products"
		set opt(key,"Menu")=sideMenu
		set opt(key)=key
		set opt(key,"id")=key ; Methods must be implemented: ProductsFirstHead   ProductsResult
		set opt(key,"TabName")=key
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Role")="%All"
		set opt(key,"Namespace")="%SYS"
		set opt(key,"Method")="ShowTabSample"
		set opt(key,"TabMenu","Close")=1 ;0 = the tab cannot be deleted
		set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free
		set opt(key,"Active")=1 ;active menu item

		set key="Options"
		set opt(key,"Menu")=sideMenu
		set opt(key)=key
		set opt(key,"id")=key ; Methods must be implemented: OptionsFirstHead   OptionsResult
		set opt(key,"TabName")=key
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Role")="%All"
		set opt(key,"Namespace")="%SYS"
		set opt(key,"Method")="ShowTabSample"
		set opt(key,"TabMenu","Close")=1 ;0 = the tab cannot be deleted
		set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free
		set opt(key,"Active")=0 ;active menu item

		set key="FilesServ"
		set opt(key)="FilesServ"
		set opt(key,"id")="FS"
		set opt(key,"TabName")=opt(key)
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Method")="ShowTabSample"
		set opt(key,"TabMenu","Close")=1
		set opt(key,"Menu")=sideMenu
		set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free

	set sideMenuName="Namespaces",
		sideMenuNumer=3,
		sideMenuOpen=0,        //3 =1 open menu
		sideMenuIcon="fa-solid fa-cube" ;"fa-cog"  //4  icon   https://fontawesome.com/icons?d=gallery&p=2&m=free
		set sideMenu=$lb(sideMenuNumer,sideMenuName,sideMenuOpen,sideMenuIcon) 
		set nslist=##class(apptools.core.sys).ListNS(.info)
		for i=1:1:$l(nslist,",") {
			set ns=$p(nslist,",",i)
			if ns=""||(ns="%ALL") continue
			if (ns="%SYS") set ns="-SYS"
			set key="NS"_ns
			set opt(key,"Menu")=sideMenu
			set opt(key)=ns
			set opt(key,"id")="NS"_ns
			set opt(key,"ClassMetod")="NSFirstHead" ;class name is the same for all namespaces
			set opt(key,"TabName")=$s(ns="-SYS":"%SYS",1:ns)
			set opt(key,"ClassName")=..%ClassName(1)
			set opt(key,"Role")="%All"
			set opt(key,"Namespace")="%SYS"
			set opt(key,"Method")="ShowTabSample"
			set opt(key,"TabMenu","Close")=1 ;0 = the tab cannot be deleted
			;set opt(key,"Active")=1 ;active menu item
			set opt(key,"aw-icon")="fa-solid fa-angle-right" ;"fa-solid fa-angle-up"  ; https://fontawesome.com/icons?d
		}
		
		/*
		set key="Databases"
		set opt(key,"Menu")=sideMenu
		set opt(key)=key
		set opt(key,"id")=key
		set opt(key,"TabName")=key
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Role")="%All"
		set opt(key,"Namespace")="%SYS"
		set opt(key,"Method")="ShowTabSample"
		set opt(key,"TabMenu","Close")=1 ;0 = the tab cannot be deleted
		set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free
		*/
	set sideMenuName="Permission",
		sideMenuNumer=2,
		sideMenuOpen=0,        //3 =1 open menu
		sideMenuIcon="fa-cog"  //4  icon   https://fontawesome.com/icons?d=gallery&p=2&m=free
		set sideMenu=$lb(sideMenuNumer,sideMenuName,sideMenuOpen,sideMenuIcon) 
			set key="MenuMatrix"
			set opt(key,"Menu")=sideMenu
			set opt(key)=$$$aText("The matrix","") ;The name of the menu
			set opt(key,"id")="Matrix"
			set opt(key,"TabName")=$$$aText("The matrix","") ;the name of the tab
			set opt(key,"ClassName")=..%ClassName(1)
			set opt(key,"Role")="%All"
			set opt(key,"Namespace")="%SYS"
			set opt(key,"Method")="ShowTabSample"
			set opt(key,"TabMenu","Close")=1 ;0 = the tab cannot be deleted
			;set opt(key,"Active")=1 ;active menu item
			set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free

			set key="User-Copy"
			set opt(key,"Menu")=sideMenu
			set opt(key)=$$$aText("UserCopy","") ;The name of the menu
			set opt(key,"id")="UserCopy"
			set opt(key,"TabName")=$$$aText("UserCopy","") ;the name of the tab
			set opt(key,"ClassName")=..%ClassName(1)
			set opt(key,"Role")="%All"
			set opt(key,"Namespace")="%SYS"
			set opt(key,"Method")="ShowTabSample"
			set opt(key,"aw-icon")="fa-table"   ;https://fontawesome.com/icons?d=gallery&p=2&m=free
	
	;top menu
		s LeftMenuName="Support",LeftMenuNumer=1
		s key="menu-top-support"
		s opt(key)="support"
		s opt(key,"id")="Support"
		s opt(key,"TabName")="Support" 
		s opt(key,"ClassName")=..%ClassName(1)
		s opt(key,"Method")="ShowTabAbout"
		s opt(key,"TabMenu","Close")=1
		s opt(key,"MenuTop")=$lb(LeftMenuNumer,LeftMenuName)
	do ..GetAppsOpenWinPanel(.opt,"menu-top-zapm", "/apptoolsrest/a/zapm", "zapm", $lb(LeftMenuNumer,LeftMenuName))
	do ..GetAppsOpenWinPanel(.opt,"menu-top-zinfo", "/apptoolsrest/a/info", "info", $lb(LeftMenuNumer,LeftMenuName))
	
	set elem(1)="Productions",
		elem(2)="EventLogs",
		elem(3)="Queues",
		elem(4)="SQL",
		elem(5)="GlobalList"  
	do ..GetAppsProducts(.opt,(LeftMenuNumer+1),.elem)
	
	set topMenuName="Account",
		topMenuNumer=99
		set key="menu-top-accoun2"
		set opt(key)="Account: "_$username
		set opt(key,"id")="AccountProf"
		set opt(key,"TabName")="Profile "_$username 
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Method")="ShowInIFrame" 
		set opt(key,"InFrameUrl")="http://"_$zu(110)_":52773/csp/sys/sec/%25CSP.UI.Portal.User.zen?PID="_$username
		set opt(key,"MenuTop")=$lb(topMenuNumer,topMenuName)
	set key="menu-top-account3"
		set opt(key,"MenuTop")=$lb(topMenuNumer,topMenuName) ; 99-account has nested items
		set opt(key)="Exit"
		set opt(key,"id")="AccountExit"
		set opt(key,"TabName")="Logoit" 
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Method")="Logout"
	
	;----- Setup the search in the top menu
	s key="Search"
	s opt(key)="Search"
	s opt(key,"id")="Search-"
	s opt(key,"TabName")=""
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSearch"
	s opt(key,"TabMenu","Mode")=11 ;1 - for each new search bar to make new tab, 0-tab is always the same, 11-not increment
	
	do ..CheckRoleMenu(.opt)
	quit $$$OK
}

/// fileserver
/// do ##class(apptools.lte.fileserver).AddRecord($namespace, $username, guidPacket, filename, "desc", "proj")
ClassMethod FSFirstHead(Par = "") As %Status
{
	do ##class(apptools.lte.fileserver).FirstHead(.Par)
}

ClassMethod OptionsFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	set sqldef=..#DefaultQuery
	set GNset=$na(@..#GNStore@("settings"))
	
	if $D(@GNset@("sqldef"),sql) set sqldef=sql
	set WorkDirDflt="/tmp"
	if $D(@GNset@("WorkDirDflt"),wdir) set WorkDirDflt=wdir
	
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",$namespace,..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	write $$$appText(divId_"WorkDirDflt","size=88 title='Default work directory'",WorkDirDflt)
	write $$$appButton(divId_"appButtonSett1","title='Setting default work directory' onclick="""_$replace(onclick,"*","setdir")_"""","Save")
	write "<br><br>"
	write $$$appText(divId_"QueryDflt","size=88 title='Default prompt for error messages in products'",$zconvert(sqldef,"O","HTML"))
	write $$$appButton(divId_"appButtonSett2","title='Setting default query' onclick="""_$replace(onclick,"*","setsql")_"""","Save")
	quit $$$OK
}

ClassMethod OptionsResult(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	;set NSpace=Par("ns")
	;if $e(NSpace,1)="-" set NSpace="%"_$e(NSpace,2,*)
	set mode=Par("mode")
	set GNset=$na(@..#GNStore@("settings"))

	if mode="setdir" {
		set WorkDirDflt=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"WorkDirDflt")
		set @GNset@("WorkDirDflt")=WorkDirDflt
		write $$$appMsg("Saved")
	}
	elseif mode="setsql" {
		set QueryDflt=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"QueryDflt")
		set @GNset@("sqldef")=QueryDflt
		write $$$appMsg("Saved")
	}
	quit $$$OK
}

ClassMethod NSFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	set (NS,ns)=$p(key,"NS",2,*)
	if $e(ns,1)="-" set NS="%"_$e(ns,2,*)
	zn NS
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",NS,..%ClassName(1),"NSpaceResult","&key="_key_"&divId="_divId_"&mode=*")

	write $$$appButton(divId_"appButtonExe","title='Execute query' onclick="""_$replace(onclick,"*","exe&ns="_ns)_"""","Execute")
	write $$$appButton(divId_"appButtonXls","title='Execute query and export XLSX' onclick="""_$replace(onclick,"*","xlsx&ns="_ns)_"""","XLSX")
	write $$$appButton(divId_"appButtonZip","title='Execute query, export XLSX and packed to ZIP' onclick="""_$replace(onclick,"*","zip&ns="_ns)_"""","ZIP")
	;write $$$appText(divId_"MaxNode","size=8 title='Count MaxNode'","10000")
	;write $$$appText(divId_"Next","size=2 title='Direct'","1")
	;write " "_$$$appText(divId_"exportXLS","title='exportXLS'","")
	set id=divId_"selectDSN"
	set listDSN=##class(apptools.core.sys).getSQLConnection(.listDSN)
	set selectDSN="<SELECT title="""_$$$aText("DSN ODBC/JDBC","")_""" name="""_id_""" id="""_id_""" ><OPTION></OPTION> "
	for ns=1:1:$l(listDSN,",") { continue:$p(listDSN,",",ns)=""
		continue:$p(listDSN,",",ns)["%"
  		;set selected=$select(DSN=$p(listDSN,",",ns):"selected",1:"")
  		set selectDSN=selectDSN_" <OPTION "_$g(selected)_" VALUE="""_$p(listDSN,",",ns)_""">"_$p(listDSN,",",ns)_"</OPTION>"
	}
	set selectDSN=selectDSN_"</SELECT>"
	write " "_selectDSN
	write " "_$$$appButton(divId_"appButtonHelp","title='View Help' onclick="""_$replace(onclick,"*","help&ns="_ns)_"""","Help")
	write " "_$$$appButton(divId_"appButtonHist","title='History' onclick="""_$replace(onclick,"*","history&ns="_ns)_"""","history")
	write " "_$$$appButton(divId_"appButtonClear","title='Clear' onclick="""_$replace(onclick,"*","clear&ns="_ns)_"""","Clear")

	write "<br>"_$$$appTextarea(divId_"what","rows=3 cols=80 title='Enter command'","")

	$$$SetHeightContent(divId,250)
	quit $$$OK
}

ClassMethod NSpaceResult(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set NSpace=Par("ns")
	if $e(NSpace,1)="-" set NSpace="%"_$e(NSpace,2,*)
	set mode=Par("mode")
	set sqldef=..#DefaultQuery
	set (DSN,%DSN)=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"selectDSN")
	set what=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"what")
	set MaxNode=10000 ;##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"MaxNode")
	set exportXLS=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"exportXLS")
	set Next=1 ;##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"Next")
	set Filtr=""
	do ##class(apptools.core.LogInfoPane).AddHistory(what,NSpace,%DSN,MaxNode,Next,Filtr)
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",NSpace,..%ClassName(1),"NSpaceResult","&key="_key_"&divId="_divId_"&moderes=*")
	;zw Par
	if ($e(what,1)="^"),what'="^" {
		set gn=""
		if $e(what)="^" { set gn=what }
	}
	
	if what="?"||(mode="help") {
		do ##class(apptools.core.LogInfoPane).GetHelp(.%help)
		// ExecuteArray = code for ison when outputting arrays
		set gn="%help",what="",Message=$$$aText("help command","")
		set ExecuteDraw="##class(apptools.core.LogInfoPane).DrawHelp(.%AppLogInfoVal,%AppLogInfoCol,%AppLogInfoHead,.%AppLogInfoTemp,"""_NSpace_""","""_%DSN_""")"
	}
	elseif (mode="history") {
		set gn=$$$HISTORYGN,what="",Message="History"
	}
	#; queries and query results
	elseif ",query,result,select,call,delete,insert,s,q,r,begin,"[(","_$zconvert($p(what," ",1),"L")_",") {
			set sql=what
			if sql["p.party_id( )" s sql=$replace(sql,"p.party_id( )","p.party_id(+)")
	}
	#; SQL table query 
	elseif $e($zconvert($p(what," ",1),"L"),1,3)="log" {
		#; Delete the protocol table
		if $g(exp)="-" Do ##class(apptools.core.Log).%KillExtent() set msg=" "_$$$aText("Cleaned the protocol","")
		set (what,sql)="select * FROM apptools.core.Log order by id desc"
	}
	#; Run class methods
	elseif $p($zconvert(what,"L")," ",1)="xec" {
		set execute=$e(what,5,*)
	}

	
	// Execute	-------------------------------------
	if $g(execute)'="" {
		write "<H5>"_$$$aText("Executing the command","")_" "_execute_"</H5>"
		if ##class(apptools.core.LogInfoPane).GetCodeExtensionNamespace(execute,.code) {
			set execute=code
		}
		xecute execute
		quit $$$OK
	}
	if $g(zpipe)'="" {
		write "<H5>"_$$$aText("Executing the command OS","")_" "_zpipe_"</H5>"
		do ##class(apptools.core.net).zpipe(zpipe)
		quit $$$OK
	}
	if what="trm" {
		write "WebTerminal"
		if ##class(apptools.core.sys).ClassExist("WebTerminal.Engine") {
			write !,"<iframe style='width:95%; height:70%' id='terminal"_NSpace_"' src='/terminal/?ns="_NSpace_"&clean=1' ></iframe>"
		}
		quit $$$OK
	}
	
	set obj=""
	#; arbitrary query
	if $g(sql)'="" {
		if %DSN'="" {
			set gnTemp=$na(@"^tmpLogInfo"@($j))  ;$$$TEMPORYGN@($j))
			KILL @gnTemp
			if $G(listDSN(DSN))'="" {
				set st=##class(apptools.core.sys).SaveGateway(sql,$G(listDSN(DSN)),%request.Get("User"),%request.Get("Password"),gnTemp,MaxNode) 
			}
			else {
				//do ##class(%SYS.System).WriteToConsoleLog("job "_$j_" sql "_$tr(sql,$c(13,10)," "),,0)
				KILL %objlasterror
				set st=##class(apptools.core.sys).SqlToDSN(sql,DSN,gnTemp,MaxNode)
				if 'st write "<font color=red>"_$System.Status.GetErrorText(st)_"</font>"
				Set sc = $g(%objlasterror, $$$OK)
				if 'sc write "<font color=red>"_$System.Status.GetErrorText(sc)_"</font>"
			}
			if $d(@gnTemp) {
				set st=##class(apptools.core.LogInfoPane).DrawSQL("result "_gnTemp,MaxNode,NSpace,"DSN: "_DSN_", Query: <br>"_$g(sql)_"<br>"_gnTemp,$g(ExecuteDraw),$lb(exportXLS,exportXLSfile,exportXLSfileEmail))
			}
		}
		else {
			if exportXLS=1 { ;Running in the background
				job ##class(apptools.core.LogInfoPane).DrawSQL(sql,MaxNode,NSpace,"NameSpace: "_NSpace_" "_$g(msg),$g(ExecuteDraw),$lb(exportXLS,exportXLSfile,exportXLSfileEmail))::1
				if $T W $$$aText("The request will be executed in the background","") s st=1
			} else {
				set st=##class(apptools.core.LogInfoPane).DrawSQL(sql,MaxNode,NSpace,"Namespace: "_NSpace_" "_$g(msg),$g(ExecuteDraw),$lb(exportXLS,exportXLSfile,exportXLSfileEmail))
			}
		}
		if $$$ISERR(st) write "<br>Error :"_##class(%CSP.Page).EscapeHTML(sql_"; "_$SYSTEM.OBJ.DisplayError(st))_"<br>"
	}
	#; If the output of Global
	elseif $G(gn)'="" {
		set a=$lb(gn,MaxNode,NSpace,Next,$g(Message),$g(exp),Filtr,$g(ExecuteDraw),exportXLS,exportXLSfile,exportXLSfileEmail)
		;d ##class(apptools.core.LogInfoPane).DrawGN(a) ;debug 
		if exportXLS=1 { ;Running in the background
			job ##class(apptools.core.LogInfoPane).DrawGN(a)::1
			if $T W $$$aText("The request will be executed in the background","") s st=1
		} else {
			set st=##class(apptools.core.LogInfoPane).DrawGN(a)
		}
	}
	elseif (what'="") {
		&html<<center><b>#($$$aText("Commands not defined",""))#</b></center>>
	}
	write "<br><br>"
	quit $$$OK
}

ClassMethod ProductsFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",$namespace,..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	set DateTime=$ZDT($NOW()-1,3,1,3)_"T00:00:00"
	write " "_$$$appDateTime(divId_"DateTime","title='The work directory for packet and publish'",DateTime)
	write " "_$$$appCheck(divId_"OnlyRunning","checked title='Only Running'",1)
	write " "_$$$appCheck(divId_"OnlyError","checked title='Only Error'",1)
	write " "_$$$appButton(divId_"appButtonResult1","title='Refresh' onclick="""_$replace(onclick,"*","1")_"""","Refresh")

	$$$SetHeightContent(divId,0)
	q $$$OK
}

/// Search result 
ClassMethod ProductsResult(Par = "") As %Status
{
	set %ui=1
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set DateTime=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"DateTime")
	set OnlyError=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"OnlyError")
	set OnlyRunning=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"OnlyRunning")
	if DateTime="" set DateTime=$ZDT($NOW()-1,3,1,3)_"T12:00"
	if mode=1 {
		set nspaces=##class(apptools.core.sys).ListNS(.info,"NotPre,Ens") ;^%apptools.core.Productions
		if '$d(info) write "not productions" quit $$$OK
		set sqldef=..#DefaultQuery
		set sql2=$replace(sqldef,"*","count(*)")
		set sql2=$replace(sql2,"?","'"_DateTime_"'")
		w sql2
		do ##class(apptools.lte.info).FindAllErr(sql2,nspaces,.result,.index)
		set NS="",ln="lockname"
		do ##class(apptools.core.sys).SetTableHeader(ln,"NameSpace","Productions Errors","Querys")
		for { set NS=$o(result(NS)) quit:NS=""
			set cnt=$g(cnt)+1
			;if $g(result(NS,"ProdUrl"))="" continue
			set prodname=$g(result(NS,"ProdUrl"))
			if OnlyRunning, $g(result(NS,"NoRun"))'="" continue
			set gns=..GetGN(NS)
			KILL @gns
			set @gns=$lb(DateTime,sqldef,sql2)
			MERGE @gns@("result")=result(NS)
			set onclick="AppRpc('','MainHidden','"_NS_":apptools.lte.info:ShowTab:&appPar=Search&Searchstr=Err-"_NS_"','/apptoolsrest/post-json');"
			if $g(result(NS,"NoRun"))'="" {
				set prodname=$g(result(NS,"NoRun")),ErrMsg=" no running products"
				set color="blue"
			}
			else {
				set color="green"
				if $g(result(NS,"Count")) {
					set color="red"
				}
				else { if OnlyError continue 
				}
				set ErrMsg="Errors: "_$g(result(NS,"Count"))
			}
			set ErrMsg="<a href=# onclick="""_onclick_"""><b><font color="_color_">"_ErrMsg_"</font></b></a>"
			do ##class(apptools.core.sys).SetTableRow(ln,cnt,prodname,ErrMsg,$g(result(NS,"QueryUrl")))
		}
		do ##class(apptools.core.sys).SetTableFooter(ln)
		do ##class(apptools.core.LogInfoPane).DrawSQL("result "_ln,10000,"")
	}
	elseif mode=2 {
		do ##class(apptools.lte.info).FindAllErr(,mode,.result,.index)
		write $G(result(mode,"ProdUrl"))_" Errors="_(+cnt)_" "_$G(result(mode,"QueryUrl"))_" Query="_(+qu)_"<br>"
		if cnt {
			set exec="##class(apptools.core.Production).AddTraceUrl(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp)"
			set sqldef=..#DefaultQuery
			set sql2=$replace(sqldef,"?","'"_$zd($h-1,3)_" 21:00'")
			set st=##class(apptools.core.LogInfoPane).DrawSQL(sql2,$g(Max,10000),$Namespace," Ensemble Errors ",$g(exec))
			w st
		}
	}
	write ..ButtonAgain(divId,key) ;,key_" - "_mode)
	quit $$$OK
}

ClassMethod GetGN(arg) As %Status
{
	quit $na(@..#GNStore@("sessions",+$h,$username,arg))
}

ClassMethod ShowTabSearch(key = "") As %Status
{
 set divId="Search-"_$G(key("appPar"))
 write "<div id='"_divId_"MainContent'>"
 if $G(key("appPar"))["Err-" {
	set NS=$p($G(key("appPar")),"Err-",2,*)
	zn NS 
	set gns=..GetGN(NS)
	set $lb(DateTime,sqldef,sql2)=@gns
	;MERGE result(NS)=@gns@("result")
	set sql=$replace(sql2,"count(*)","ConfigName,Job,MessageId,SessionId,SourceClass,SourceMethod,Text,TimeLogged")
	do ##class(apptools.core.LogInfoPane).DrawSQL(sql,1000,"")

 }
 else {
 }
 write "</div>"
 $$$jsstart w $$$NL write "$('#"_divId_"MainContent').height($(window).height()-"_250_");"_$$$NL $$$jsstop w $$$NL
 q $$$OK
}

///  do ##class(apptools.lte.info).FindAllErr(,,.result)
ClassMethod FindAllErr(sqldef = {..#DefaultQuery}, nspaces = "", result, index) As %String
{
	set GN=##class(apptools.core.Production).#SettingsGN
	if '$Data(@GN) do ##class(apptools.core.Production).SaveStat(1)
	if nspaces="" set nspaces=##class(apptools.core.sys).ListNS(.info,"NotPre,Ens")
	for i=1:1:$l(nspaces,",") { continue:$p(nspaces,",",i)=""||("%All"[$p(nspaces,",",i))
		$$$NspGoto(curNs,$p(nspaces,",",i))
		set NS=$p(nspaces,",",i)
		if '$D(@GN@(NS)) continue ; there is no namespace in the system, skip
		set PN=""
		set p="" for { set p=$o(@GN@(NS,"Ens",p)) quit:p=""
			if $lg($g(@GN@(NS,"Ens",p)),1)[$$$EnsProductStatusRun s PN=p quit
		}
		set url="<b><a target='ensprod2"_($Namespace)_"' href='/csp/"_$zconvert($Namespace,"L")_"/EnsPortal.ProductionConfig.zen?$NAMESPACE="_$Namespace_"' >"_NS_"</a></b>"
		if PN="" set result(NS,"NoRun")=url continue
		if $Namespace'=NS s result(NS,"Err")="<br><font color=red>Go to error "_url_"</font>" continue
		
		set gn="tmpErrEns"
		set sqldef=..GetSQLErrors4Prod(NS,sqldef)
		do ##class(apptools.core.sys).SaveSQL(sqldef,gn)
		set (ec,cnt,result(NS,"Count"))=+$lg($g(@gn@(1)),1)
		set result(NS,"ProdUrl")=url
		
		;Query
		set serv="",totalC=0,totalA=0
		set query="EnsPortal.Queues:EnumerateQueues",
			gn="qu"
		KILL @gn
		do ##class(apptools.core.sys).SaveQueryTab(query,gn)
		for ii=1:1 { quit:'$d(@gn@(ii))
			set Count=##class(apptools.core.sys).GetValue(gn,ii,"Count")
			set Active=##class(apptools.core.sys).GetValue(gn,ii,"Active")
			set totalA=totalA+Active
			set totalC=totalC+Count
		}
		set color="green",
			serv=ii-1
		if totalA||(totalC) {
			set color="red" 
		}
		set result(NS,"Query")=totalA+totalC
		set url="/csp/"_$zconvert(NS,"L")_"/EnsPortal.Queues.zen?$NAMESPACE="_NS
		set result(NS,"QueryUrl")="<a target=_blank href="_url_" ><b><font color="_color_" style='cursor:hand'> Querys: "_totalC_" Active: "_totalA_" </font></b></a>"
		set index(+cnt,totalA,NS)=""		
		$$$NspReturn(curNs)
	}
	quit $$$OK
}

ClassMethod GetSQLErrors4Prod(NS, sqldef) As %Status
{
	;Let it be for now
	quit sqldef
}

/// download form template search users and roles
ClassMethod MatrixFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	//##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",$namespace,..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	&html<
		<table>
		<tr>
			<td>
 			Login <br>#($$$appText(divId_"name","title='"_$$$aText("Names separated by a comma or by context","")_"'","s"))#
			</td>
			<td>
			Roles <br>#($$$appText(divId_"roles","title='"_$$$aText("Roles separated by a comma or by context","")_"'","d"))#
			</td>
			<td> <br>
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""",""_$$$aText("User roles","")))#
			</td>
		</tr>
		</table>
	>
	$$$SetHeightContent(divId,250)
	q $$$OK
}

/// Search result 
ClassMethod MatrixResult(Par = "") As %Status
{
	set %ui=1
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;Geting elements from form and prepare array Par
	set name=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"name")	
	set roles=$g(Par("%request.Data",divId_"roles"))
	write ..ButtonAgain(divId,key)
	do ##class(apptools.Tabs.security).UiMatrixPermission(name,roles,divId,key,"apptools.Tabs.security","UiSavePermiss")
	quit $$$OK
}

/// --------- User copy form
ClassMethod UserCopyFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	//##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",$namespace,..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	&html<
		<table>
		<tr>
			<td>
 			Login <br>#($$$appText(divId_"name","title='"_$$$aText("Names separated by a comma or by context","")_"'","s"))#
			</td>
			<td>
			Unclude Fullname, Comment or Roles <br>#($$$appText(divId_"desc","title='"_$$$aText("Description","")_"'","s"))#
			</td>
			<td> <br>
			#($$$appButton(divId_"appButtonFind","onclick="""_$replace(onclick,"*","find")_"""",""_$$$aText("Find Users","")))#
			</td>

			<td>
 			Copy from <br>#($$$appText(divId_"copyfrom","title='"_$$$aText("Username copy from","")_"'",""))#
			</td>
			<td>
			Copy to <br>#($$$appText(divId_"copyto","title='"_$$$aText("Username copy to","")_"'",""))#
			</td>
			<td> <br>
			#($$$appButton(divId_"appButtonCopy","onclick="""_$replace(onclick,"*","copy")_"""",""_$$$aText("Copy Users","")))#
			</td>
		</tr>
		</table>
	>
	$$$SetHeightContent(divId,250)
	q $$$OK
}

/// Search result 
ClassMethod UserCopyResult(Par = "") As %Status
{
	set %ui=1
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	if mode="find" {
		;Geting elements from form and prepare array Par
		set name=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"name")	
		set desc=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"desc")	
		write ..ButtonAgain(divId,key)
		set where="name['"_name_"'"
		if name="" set where="1=1"
		set wheredesc="1=1"
		if desc'="" set wheredesc="( Comment['"_desc_"' or FullName [ '"_desc_"' or Roles [ '"_desc_"' )"
		set sql="select name, comment, FullName, Superuser,Enabled, Roles, ExpirationDate,CreateDateTime,CreateUsername,LastModifiedDateTime,LastModifiedInfo,LastModifiedUsername, EmailAddress from Security.Users where "_where_" and "_wheredesc
		set st=##class(apptools.core.LogInfoPane).DrawSQL(sql,100000,$namespace,$g(msg),$g(exec),,1)
	}
	if mode="copy" {
		;Geting elements from form and prepare array Par
		set copyfrom=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"copyfrom")	
		set copyto=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"copyto")	
		if copyfrom=""||(copyto="") write $$$appError("Username is empty") quit $$$OK
		set st=##class(Security.Users).Copy(copyfrom,copyto)
		if 'st write $$$appError($System.Status.GetErrorText(st)) quit $$$OK
		write $$$appMsg("Copied successfully") quit $$$OK
	}
	quit $$$OK
}

/// set base64 = ##class(apptools.core.rest).getStatic("apptools.lte.info:info")
XData info [ MimeType = application/yaml ]
{
data:image/x-png;base64,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
AElFTkSuQmCC
}

}

