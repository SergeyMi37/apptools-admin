Include apptools.core

/// http://localhost:52773/apptoolsrest/a/info
Class apptools.lte.info Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Info";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.Info";

/// Roles
Parameter AppRoles = "ui_Info";

/// Default query to productions logs
Parameter DefaultQuery = "Select * from Ens_Util.Log where Type='2' and TimeLogged>? order by id desc";

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set path=par("=path=")
 set par("=Brand-Text=")=$system
 set par("=Logo-image=")=path_"adminlte/dist/img/ApptoolsLogo.png"
 set par("=titleAppToolsadmin=")=$system ;..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"adminlte/dist/img/ApptoolsLogo","png")
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
		set opt(key,"id")=key
		set opt(key,"TabName")=key
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Role")="%All"
		set opt(key,"Namespace")="%SYS"
		set opt(key,"Method")="ShowTabSample"
		set opt(key,"TabMenu","Close")=1 ;0 = the tab cannot be deleted
		set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free

		set key="Options"
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
		set opt(key,"Active")=1 ;active menu item

		/*
		set key="Namespaces"
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
	s opt(key,"TabName")="Search"_"-"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSearch"
	s opt(key,"TabMenu","Mode")=0 ;1 - for each new search bar to make new tab, 0-tab is always the same
	
	do ..CheckRoleMenu(.opt)
	quit $$$OK
}

ClassMethod OptionsFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	;set %ui=1
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",$namespace,..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	write key_divId
}

ClassMethod ProductsFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	;set %ui=1
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",$namespace,..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	set nspaces=##class(apptools.core.sys).ListNS(.info,"NotPre,Ens")
	set sqldef=..#DefaultQuery
	set sql2=$replace(sqldef,"*","count(*)")
	set sql2=$replace(sql2,"?","'"_$zd($h-1,3)_" 21:00'")
	do ##class(apptools.lte.info).FindAllErr(sql2,nspaces,.result,.index)
	set cnt=""
	for { set cnt=$o(index(cnt),-1) quit:cnt=""
		set qu=""
		for { set qu=$o(index(cnt,qu)) quit:qu=""
			set ns=""
			for { set ns=$o(index(cnt,qu,ns)) quit:ns=""
				write $$$appButton(divId_"appButtonResult"_ns,"title='Count Errors = "_cnt_", Query = "_qu_"' onclick="""_$replace(onclick,"*",ns_"&cnt="_cnt_"&qu="_qu)_"""",ns_"_"_cnt_"_"_qu)
			}
		}
	}
	$$$SetHeightContent(divId,250)
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
		;w "<li>",NS
		set PN=""
		set p="" for { set p=$o(@GN@(NS,"Ens",p)) quit:p=""
			if $lg($g(@GN@(NS,"Ens",p)),1)[$$$EnsProductStatusRun s PN=p quit
		}
		set onclicknone="$('.taberrors').css('display','none'); "
		set url="<b><a target='ensprod2"_($Namespace)_"' href='/csp/"_$zconvert($Namespace,"L")_"/EnsPortal.ProductionConfig.zen?$NAMESPACE="_$Namespace_"' >"_NS_"</a></b>"
		if PN="" s result(NS,"NoRun")="<li>"_url_" no running products" continue
		if $Namespace'=NS s result(NS,"Err")="<br><font color=red>Go to error "_url_"</font>" continue
		
		set gn="tmpErrEns"
		do ##class(apptools.core.sys).SaveSQL(sqldef,gn)
		set (ec,cnt,result(NS,"Count"))=+$lg($g(@gn@(1)),1)
		    ;if NS="MVK" zw @gn
		set result(NS,"ProdUrl")=url
		
		;Query
		set serv="",total=0
		for { s serv=$o(^Ens.Queue(serv)) q:serv=""
			s total=$g(total)+$g(^Ens.Queue(serv,0,"count"))
		}
		set result(NS,"Query")=total
		set url="/csp/"_$zconvert(NS,"L")_"/EnsPortal.Queues.zen?$NAMESPACE="_NS
		set result(NS,"QueryUrl")="<a target="_$zts_" href="_url_" > Query "_total_" </a>"
		set index(+cnt,total,NS)=""		
		$$$NspReturn(curNs)
	}
	quit $$$OK
}

/// Search result 
ClassMethod ProductsResult(Par = "") As %Status
{
	set %ui=1
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set cnt=Par("cnt")
	set qu=Par("qu")
	zn mode
	do ##class(apptools.lte.info).FindAllErr(,mode,.result,.index)
	write $G(result(mode,"ProdUrl"))_" Errors="_(+cnt)_" "_$G(result(mode,"QueryUrl"))_" Query="_(+qu)_"<br>"
	if cnt {
		set exec="##class(apptools.core.Production).AddTraceUrl(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp)"
		set sqldef=..#DefaultQuery
		set sql2=$replace(sqldef,"?","'"_$zd($h-1,3)_" 21:00'")
		set st=##class(apptools.core.LogInfoPane).DrawSQL(sql2,$g(Max,10000),$Namespace," Ensemble Errors ",$g(exec))
		w st
	}
	write ..ButtonAgain(divId,key) ;,key_" - "_mode)
	quit $$$OK
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
 			Login <br>#($$$appText(divId_"name","title='"_$$$aText("Names separated by a comma or by context","")_"'","ms"))#
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

}

