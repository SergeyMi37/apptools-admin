Include apptools.core

/// http://localhost:52773/apptoolsrest/a/info
Class apptools.lte.zapm Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "zapm";

/// Global Name Store Referens files
Parameter GNStore = "^%apptools.zapm";

/// Roles
Parameter AppRoles = "ui_zapm";

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set base64=##class(apptools.core.rest).getStatic(..%ClassName(1)_":zip")
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
		set opt(key,"aw-icon")="fa-solid fa-asterisk" ;"fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free
		set opt(key,"Active")=1 ;active menu item
	
		do ##class(apptools.lte.resources).GetZpmNamespaces(.List,"fileserver",.firstnamespace)
	  if $D(List("fileserver")) {
		set ns=$G(firstnamespace) ;$O(List("fileserver",""))
		set key="File"
		set opt(key,"Menu")=sideMenu
		set opt(key)="File-server"
		set opt(key,"Namespace")=ns
		set opt(key,"id")=key
		set opt(key,"TabName")="File-server"
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Role")="%All"
		;set opt(key,"MethodUrlNewWin")="/fileserver/files"
		set opt(key,"Method")="ShowInIFrame" 
		set opt(key,"InFrameUrl")="/fileserver/files"
		set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free
		set opt(key,"Active")=0 ;active menu item
     }	

	set sideMenuName="PackagesManager",
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
			set opt(key,"ClassMetod")="NSpaceFirstHead" ;class name is the same for all namespaces
			set opt(key,"TabName")=$s(ns="-SYS":"%SYS",1:ns)
			set opt(key,"ClassName")=..%ClassName(1)
			set opt(key,"Role")="%All"
			set opt(key,"Namespace")="%SYS"
			set opt(key,"Method")="ShowTabSample"
			set opt(key,"TabMenu","Close")=1 ;0 = the tab cannot be deleted
			;set opt(key,"Active")=1 ;active menu item
			set opt(key,"aw-icon")="fa-solid fa-angle-right" ;"fa-solid fa-angle-up"  ; https://fontawesome.com/icons?d
		}
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
	s opt(key,"TabName")="Search"_"-"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSearch"
	s opt(key,"TabMenu","Mode")=0 ;1 - for each new search bar to make new tab, 0-tab is always the same
	do ..GetAppsOpenWinPanel(.opt,"menu-top-zapm", "/apptoolsrest/a/zapm", "zapm", $lb(LeftMenuNumer,LeftMenuName))
	do ..GetAppsOpenWinPanel(.opt,"menu-top-zinfo", "/apptoolsrest/a/info", "info", $lb(LeftMenuNumer,LeftMenuName))
	
	do ..CheckRoleMenu(.opt)
	quit $$$OK
}

ClassMethod NSpaceFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	set ns=$p(key,"NS",2,*)
	if $e(ns,1)="-" set ns="%"_$e(ns,2,*)
	set GN=##class(apptools.lte.zapm).#GNStore
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",ns,..%ClassName(1),"NSpaceResult","&key="_key_"&divId="_divId_"&mode=*")

	do ##class(%ZAPM.ext.zpm).GetListModule(ns,.List,0)
	set pk="",
		gn="^||tmpPK",
		zpmname=""
	set disabled=""
	set lastmask=$g(@GN@("lastfindmask"),"*")
	if lastmask="" set lastmask="*"
	if '##class(apptools.lte.zapm).PrivateRepo(,.currepo) set disabled="disabled"
	write $$$appButton(divId_"appButtonResult1"_ns,"title='Create new Packet' onclick="""_$replace(onclick,"*","new&ns="_ns_"&zpmname="_zpmname)_"""","Create")
	;write $$$appButton(divId_"appButtonResult4"_ns,"title='Load zpm into current namespace' onclick="""_$replace(onclick,"*","load&ns="_ns_"&zpmname="_zpmname)_"""","Load")
	write $$$appButton(divId_"appButtonResult2"_ns,"title='Installing packages from found in the current registry "_$g(currepo(0))_" ' onclick="""_$replace(onclick,"*","install&ns="_ns_"&zpmname="_zpmname)_"""","Search")
	write $$$appText(divId_"FindMask"," title='Search context in registry' size=8 ",lastmask)_"  "
	do ##class(apptools.core.sys).SetTableHeader(gn,"Name","Version","Description","Action") ;,"Description")
	for i=1:1 { set pk=$o(List(pk)) quit:pk=""
		if pk="apptools-admin",$zconvert($G(^%apptools.Setting("HomeNamespace")),"L")'=$zconvert(ns,"L") continue
		set data=$G(List(pk,"L")),
			repo="",
			disabledpk="",
			urldesc=$lg(data,2)
		if $G(List(pk,"R"))'="" {
			set repo=$lg($G(List(pk,"R")),3)
			set click="WinOpen('"_$zu(5)_"','"_..%ClassName(1)_"','RepoWinOpen','~zpmname="_pk_"~ns="_ns_"~repo="_repo_"','','"_##class(apptools.core.Action).WriteWinOpenREST(%request)_"');"
			;set urldesc="<a href=""#"" onclick="""_click_""">"_$lg(data,2)_"</a>"
			set urldesc="<a target=repo"_pk_" href="""_repo_""">"_$lg(data,2)_"</a>"
		}
		set zpmname=pk
		set editbutton=$$$appButton(divId_"appButtonResult4"_pk,"title='Edit Packet' onclick="""_$replace(onclick,"*","edit&ns="_ns_"&zpmname="_zpmname)_"""",pk)
		if pk="zpm"||(pk="zapm")||(pk="apptools-admin") set disabledpk="disabled"
		set deletebutton=$$$appButton(divId_"appButtonResult5"_pk,disabledpk_" title='Uninstall Packet' onclick="""_$replace(onclick,"*","uninstall&ns="_ns_"&zpmname="_zpmname)_"""","Uninstall")
		set publish=$$$appButton(divId_"appButtonPublish"_pk,disabled_" title='Publish into "_$g(currepo(0))_"' onclick="""_$replace(onclick,"*","publish&ns="_ns_"&zpmname="_zpmname)_"""","Publish")

		do ##class(apptools.core.sys).SetTableRow(gn,i,editbutton,$lg(data,1),urldesc,deletebutton_" "_publish) ;,$lg(data,2))
	}
	set row=i
	;set disabled="disabled"
	;if zpmname'="" set disabled=""
	;write $$$appButton(divId_"appButtonResUpd"_ns," "_$g(disabled)_" title='Update installed packets' onclick="""_$replace(onclick,"*","update&ns="_ns_"&zpmname="_zpmname)_"""","Update")
	write ..ButtonAgain(divId,key,"Refresh","NSpace","title='Update the current list of elements' ")
	
	set gnpro=$na(@GN@("prototype",ns)),
		pk=""
	for i=row:1 { set pk=$o(@gnpro@(pk)) quit:pk=""
		set zpmname=pk
		set editbutton=$$$appButton(divId_"appButtonPR4"_pk,"title='Edit prototype' onclick="""_$replace(onclick,"*","editpro&ns="_ns_"&zpmname="_zpmname)_"""",pk)
		set deletebutton=$$$appButton(divId_"appButtonPR5"_pk,"title='delete prototype' onclick="""_$replace(onclick,"*","delete&ns="_ns_"&zpmname="_zpmname)_"""","Delete")
		set gstar="<font color=green>*</font>"
		set desc=$g(@gnpro@(pk,"Application-module","Description"))
		set vers=$g(@gnpro@(pk,"Application-module","Version"))
		do ##class(apptools.core.sys).SetTableRow(gn,i,editbutton,$replace(gstar,"*",vers),$replace(gstar,"*",desc),deletebutton)
	}
	do:$d(@gn@(1)) ##class(apptools.core.LogInfoPane).DrawSQL("result "_gn,10000,"","<br>Installed packets:",,,1)
	$$$SetHeightContent(divId,0)
	quit $$$OK
}

/// Draw Resource in modal window
ClassMethod RepoWinOpen(Par = "")
{
	set zpmname=$g(Par("zpmname"))
	set ns=$g(Par("ns"))
	set repo=$g(Par("repo"))
	w repo q 1
	&html<
		<form id="#("ModalMainForm")#">
		<div class="uk-grid">
		    <iframe id="#("ModalMainIFrame")#" width="1500" height="1000" style='overflow: auto;' src='#(repo)#' ></iframe>
		    </div>
		</div>
		</form>
		>
	quit $$$OK
}

ClassMethod NSpaceResult(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set ns=Par("ns")
	set mode=Par("mode")
	set GN=..#GNStore
	set gnpro=$na(@GN@("prototype",ns))
	set %ui=1
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",ns,..%ClassName(1),"NSpaceResult","&key="_key_"&divId="_divId_"&mode=*")
	set zpmname=Par("zpmname")
	if mode="new"||(mode="edit")||(mode="editpro") {
		set head=$s(mode="new":"Create new packet",mode="edit":"Edit '"_zpmname_"' packet",mode="editpro":"Edit prototype '"_zpmname_"' packet",1:"")
		write head_"<br>"
		do ##class(apptools.lte.resources).UiMatrixResources(key,divId,ns,mode,zpmname,GN)
	}
	elseif mode="install" {
		set FindMask=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"FindMask")
		set @GN@("lastfindmask")=FindMask
		;set head=$s(mode="install":"Install selected packages",1:"install selected packages into new database")
		set head="Install selected packages"
		write head_"<br>"
		do ##class(apptools.lte.resources).UiMatrixRepo(key, divId, ns, mode,zpmname,FindMask)
		
	}
	elseif mode="load" {
		set head="Load selected packages into current namespace "_ns
		write head_"<br>"
		;do ##class(apptools.lte.resources).UiMatrixLoad(key, divId, ns, mode, zpmname)
		
	}
	elseif mode="publish" {
		if ##class(apptools.lte.zapm).PrivateRepo(,.currepo) {
			set head="Publish package into '"_$G(currepo(0))_"'"
			write head_"<br><pre>"
			set st=##class(%ZPM.PackageManager).Shell("publish "_zpmname)
			write "</pre>"
			if 'st write $$$appError($System.Status.GetErrorText(st))
			else  write $$$appMsg("Done")
		}
		else { write $$$appError("Publication is not possible '"_$G(currepo(0))_"'")
			write ..ButtonAgain(divId,key,"Refresh","NSpace","title='Update the current list of elements' ")
		}
	}
	elseif mode="delete" {
		KILL @gnpro@(zpmname)
		write $$$appMsg("Killed "_zpmname)
		write ..ButtonAgain(divId,key,"Refresh","NSpace","title='Update the current list of elements' ")
	}
	elseif mode="uninstall" {
		do ##class(apptools.lte.resources).GetResourcesFromZpm(zpmname,.Module,.reso)
		set gn2="tmpRes"
		do ##class(apptools.core.sys).SetTableHeader(gn2,"Name Resources","Type")
		set typ="",i=0
		for { set typ=$o(reso(typ)) quit:typ=""
			set item=""
			for { set item=$o(reso(typ,item)) quit:item=""
				set i=i+1
				do ##class(apptools.core.sys).SetTableRow(gn2,i,item,typ)
			}
		}
		do:$d(@gn2@(1)) ##class(apptools.core.LogInfoPane).DrawSQL("result "_gn2,10000,"","<br>Resources to remove:",,,1)
		set head="<br>Uninstall packages '"_zpmname_"' from current namespace '"_ns_"'. Are you sure ?"
		write head_"<br>"
		write $$$appButton(divId_"appButtonResult5"_zpmname,"title='Uninstall Packet' onclick="""_$replace(onclick,"*","yes&ns="_ns_"&zpmname="_zpmname)_"""","YES")
		write $$$appButton(divId_"appButtonResult6"_zpmname,"title='Cancel' onclick="""_$replace(onclick,"*","no&ns="_ns_"&zpmname="_zpmname)_"""","NO")
	}
	elseif mode="yes" {
		set head="Uninstall packages '"_zpmname_"' from current namespace '"_ns_"' "
		write head_"<br><pre>"
		set st=##class(%ZPM.PackageManager).Shell("uninstall "_zpmname)
		write "</pre>"
		if 'st write $$$appError($System.Status.GetErrorText(st))
		else  write $$$appMsg("Done")
		write ..ButtonAgain(divId,key,"Refresh","NSpace","title='Update the current list of elements' ")
	}
	elseif mode="no" {
		set head="Canceled"
		write head_"<br>"
		write ..ButtonAgain(divId,key,"Refresh","NSpace","title='Update the current list of elements' ")
	}
	elseif mode="update" {
		set head="Update installed packages in current namespace "_ns_". "
		write head_"<br>"
		write $$$appButton(divId_"appButtonResult7"_zpmname,"title='Uninstall Packet' onclick="""_$replace(onclick,"*","updateall&ns="_ns_"&zpmname="_zpmname)_"""","ALL")
		write $$$appButton(divId_"appButtonResult8"_zpmname,"title='Uninstall Packet' onclick="""_$replace(onclick,"*","updateyes&ns="_ns_"&zpmname="_zpmname)_"""","YES")
		write $$$appButton(divId_"appButtonResult9"_zpmname,"title='Uninstall Packet' onclick="""_$replace(onclick,"*","no&ns="_ns_"&zpmname="_zpmname)_"""","NO")
	}
	elseif mode="updateall" {
		set head="update all packages in current namespace '"_ns_"' "
		write head_"<br>"
		w $namespace
	}
	elseif mode="updateyes" {
		set head="update ... packages '"_zpmname_"' from current namespace '"_ns_"' "
		write head_"<br>"
		w $namespace
	}
	quit $$$OK
}

ClassMethod OptionsFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	set dirrepo="/backup/temp/"
	if $D(@..#GNStore@("dir"),data) set dirrepo=data
	
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",$namespace,..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	write "The work directory for packet and publish<br>"
	write $$$appText(divId_"WorkDirPacket","title='The work directory for packet and publish' size=80 ",dirrepo)
	write $$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Save")

	if ##class(apptools.lte.zapm).PrivateRepo(,.currepo)
	write "<br><br><br>The current registry is "_$g(currepo(0))

	set reset="repo -r -n registry -reset-defaults"
	if $D(@..#GNStore@("Reset"),data) set reset=data
	write "<br><br>Reset to default registry (pm.community.intersystems.com) and it is equivalent to a command<br>"
	write $$$appText(divId_"Reset"," size=80 ",reset)
	write $$$appButton(divId_"appButtonRest","onclick="""_$tr(onclick,"*",2)_"""","Reset")

	set switch="repo -r -n registry -url https://zpm-ui.demo.community.intersystems.com/registry/ -user ""_system"" -pass ""SYS"""
	if $D(@..#GNStore@("Switch"),data) set switch=data
	write "<br><br>Switch to the private registry:<br>"
	write $$$appText(divId_"Switch"," size=80 ",switch)
	write $$$appButton(divId_"appButtonSwitch"," onclick="""_$tr(onclick,"*",3)_"""","Switch")

	set switch2="repo -n registry -r -url https://test.pm.community.intersystems.com/registry/ -user test -pass PassWord42"
	if $D(@..#GNStore@("SwitchTest"),data) set switch2=data
	write "<br><br>Switch to a public test registry:<br>"
	write $$$appText(divId_"Switch2"," size=80 ",switch2)
	write $$$appButton(divId_"appButtonSwitch2"," onclick="""_$tr(onclick,"*",4)_"""","Switch to Test")

	set find="*"
	if $D(@..#GNStore@("FindStr"),data) set find=data
	write "<br><br><br>Find a project in the current instance<br>"
	write $$$appText(divId_"FindStr"," size=80 ",find)
	write $$$appButton(divId_"appButtonFindStr","title='Context by project name' onclick="""_$tr(onclick,"*",5)_"""","Find")

	write "<br><br><br>Viewing and editing global for storing package prototypes:<br>"
	;write $$$appText(divId_"Switch"," size=80 ",switch)
	s store=..#GNStore
	s store=$$$addAppLog("Load apptools-panel in new window"," for view globals ",store,"target=store")
	write $replace(store,"apptools.core","/apptools/apptools.core")

	quit $$$OK
}

/// Search result
ClassMethod OptionsResult(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set %ui=1
	;Geting elements from form and prepare array Par
	set dirrepo=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"WorkDirPacket")
	set Reset=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"Reset")
	set Switch=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"Switch")
	set Switch2=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"Switch2")
	set FindStr=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"FindStr")
	write ..ButtonAgain(divId,key,"Refresh",,"title='Update the current list of elements' ")
	set st=$$$OK
	if mode=1 {
		if dirrepo="" w $$$appError($$$aText("work directory is empty","")) quit $$$OK
		set @..#GNStore@("dir")=dirrepo
		write $$$appMsg(dirrepo_" saved")
	} 
	elseif mode=2 {
		if Reset="" w $$$appError($$$aText("work directory is empty","")) quit $$$OK
		set @..#GNStore@("Reset")=Reset
		write $$$appMsg(Reset_" saved")
		write "<pre>"
		set st=##class(%ZAPM.ext.zapp).prompt(Reset)
		;set st=##class(%ZPM.PackageManager).Shell(Reset)
		write "</pre>"
		if 'st write $$$appError($System.Status.GetErrorText(st))
		else  write $$$appMsg("Done")
	} 
	elseif mode=3 {
		if Switch="" w $$$appError($$$aText("switch string is empty","")) quit $$$OK
		set @..#GNStore@("Switch")=Switch
		write $$$appMsg(Switch_" saved")
		write "<pre>"
		set st=##class(%ZAPM.ext.zapp).prompt(Switch)
		;set st=##class(%ZPM.PackageManager).Shell(Switch)
		write "</pre>"
		if 'st write $$$appError($System.Status.GetErrorText(st))
		else  write $$$appMsg("Done")
	} 
	elseif mode=4 {
		if Switch2="" w $$$appError($$$aText("switch string is empty","")) quit $$$OK
		set @..#GNStore@("SwitchTest")=Switch2
		write $$$appMsg(Switch2_" saved")
		write "<pre>"
		set st=##class(%ZAPM.ext.zapp).prompt(Switch2)
		;set st=##class(%ZPM.PackageManager).Shell(Switch)
		write "</pre>"
		if 'st write $$$appError($System.Status.GetErrorText(st))
		else  write $$$appMsg("Done")
	} 
	elseif mode=5 {
		set @..#GNStore@("FindStr")=FindStr
		set FindStr=$tr(FindStr,"*")
		set onclick="AppRpc('','MainHidden','%SYS:apptools.lte.zapm:ShowTab:&appPar=NS*','/apptoolsrest/post-json');"
			do ##class(apptools.lte.resources).GetZpmNamespaces(.List,FindStr)
		set gn2="tmpRepo"
		do ##class(apptools.core.sys).SetTableHeader(gn2,"Name Packets","Namespaces Version Packets")
		set module="",i=0
		for { set module=$o(List(module)) quit:module=""
			set item="",nspaces=""
			for { set item=$o(List(module,item)) quit:item=""
				set ver=$lg($G(List(module,item,module)),1)
				set butt=$$$appButton(divId_"appButtonNs"_item,"onclick="""_$replace(onclick,"*",$tr(item,"%","-"))_"""",item_" "_ver)
				set nspaces=nspaces_" "_butt
			}
			set i=i+1
			do ##class(apptools.core.sys).SetTableRow(gn2,i,module,nspaces)
		}
		do:$d(@gn2@(1)) ##class(apptools.core.LogInfoPane).DrawSQL("result "_gn2,10000,"","<br>Packets in Namespaces:",,,1)
	} 
	write "<br>"
	quit $$$OK
}

/// write ##class(apptools.lte.zapm).PrivateRepo(,.r)
ClassMethod PrivateRepo(serverClassList = "", ByRef repo) As %Status
{
    Set tRes = ##class(%ZPM.PackageManager.Client.ServerDefinition).ListFunc()
    $$$ThrowSQLIfError(tRes.%SQLCODE,tRes.%Message)
	Set tDisplayCount = 0
	set yes=0
	While tRes.%Next(.tSC) {
			$$$ThrowOnError(tSC)
			Set tRepository = ##class(%ZPM.PackageManager.Client.ServerDefinition).ServerDefinitionKeyOpen(tRes.%Get("Name"),,.tSC)
			$$$ThrowOnError(tSC)
			If serverClassList = "" || ($ListFind(serverClassList, $Classname(tRepository))) {
				;Do tRepository.Display()
				set repo(tDisplayCount)=tRepository.Details
				if repo(tDisplayCount)'="https://pm.community.intersystems.com" {
					if (tRepository.Enabled)&(tRepository.GetPackageService().IsAvailable()) set yes=1
				}
			}
			Set tDisplayCount = tDisplayCount +1
    }
	$$$ThrowOnError(tSC)
    Quit yes
}

/// do ##class(apptools.lte.zapm).init()
ClassMethod init(installall = 0) As %Status
{
 set curna=$namespace
 new $namespace
 set $namespace="%SYS"
	if '..IsInstallzpm("zapm") {
		do ##class(%ZPM.PackageManager).Shell("install zapm")
	}
 set $namespace=curna
 write !,"Load for demo "_##class(apptools.core.net).GetURI(.prop)_"/apptoolsrest/a/zapm"
 quit:installall="note" $$$OK
 ;for demo
 ;try { } catch e {}
	set tMgrDir = $System.Util.ManagerDirectory()
	set tBinDir = $System.Util.BinaryDirectory()
	set tCSPDir = ##class(%File).NormalizeDirectory("csp", ##class(%File).GetDirectory($zu(86)))
	if $zversion(1)=3 {  //Linux
		set dir="/opt/irisapp/src/"
		set dir2="/irisdev/" 
		set pattpath="/opt/irisapp/src/csp/sql2xlsx/pattern/"
		set outputpath="/usr/irissys/mgr/Temp/"
		if ##class(%File).DirectoryExists(dir) {
		 if '##class(%File).DirectoryExists(dir2) {	;for demo  GCR -------------------
			set switch="repo -r -n registry -url https://zpm-ui.demo.community.intersystems.com/registry/ -user ""_system"" -pass ""SYS"""
			set @..#GNStore@("Switch")=switch
			set @..#GNStore@("dir")=outputpath
			 for i="zpm-registry","zpmshow" {
			 	set st=##class(%ZAPM.ext.zapp).prompt("newdb "_i)
			 }
		    do:'..IsInstallzpm("fileserver") ##class(%ZPM.PackageManager).Shell("load https://github.com/SergeyMi37/Cache-FileServer")
		 }
		 else {  ;install zpm modules for Docker -------------------------------
			 for i="zpm-registry","zpmshow" {
			 	set st=##class(%ZAPM.ext.zapp).prompt("newdb "_i)
			 }
		    do:'..IsInstallzpm("fileserver") ##class(%ZPM.PackageManager).Shell("load https://github.com/SergeyMi37/Cache-FileServer")
		 }
		}
		else {  //just linux without docker
		}
	    ;set options for linux
		;if ##class(%File).DirectoryExists(pattpath)	{
		;	set @gn@("pattpath")=pattpath
		;}
		;else {
		;	set @gn@("pattpath")=tCSPDir_"sql2xlsx/pattern/"
		;}
		;if ##class(%File).DirectoryExists(outputpath)	{
		;	set @gn@("outputpath")=outputpath
		;}
		;else {
		;	set @gn@("outputpath")=$System.Util.ManagerDirectory()_"Temp/"
		;}
	}
	else { ;set options for Windows
		;set @gn@("pattpath")=tCSPDir_"sql2xlsx/pattern\"
		;set @gn@("outputpath")=$System.Util.ManagerDirectory()_"Temp\"
	}
	quit $$$OK
}

/// write ##class(appmsw.python.util).IsInstallzpm("exchange-rate-cbrf")
ClassMethod IsInstallzpm(modulename, ns = {$namespace}) As %String
{
	do ##class(%ZPM.PackageManager).GetListModule(ns,.list)
	;zw list
	quit $DATA(list(modulename))
}

/// set xml = ##class(apptools.core.rest).getStatic("apptools.lte.zapm:module")
XData module [ MimeType = application/yaml ]
{
<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
 <Document name="test.ZPM">
  <Module>
  <Name>test</Name>
  <Version>1.0.0</Version>
  <Description>test desciption</Description>
  <Packaging>module</Packaging>
  <Keywords>zpm</Keywords>
  <Author>
   <Person>Mikhaylenko Sergey</Person>
   <CopyrightDate>2022</CopyrightDate>
   <License>MIT</License>
  </Author>
  <SystemRequirements Version=">=2020.1" Interoperability="enabled" />
  <SourcesRoot>src</SourcesRoot>
 </Module>
 </Document>
</Export>
}

/// set base64 = ##class(apptools.core.rest).getStatic("apptools.lte.info:zip")
XData zip [ MimeType = application/yaml ]
{
data:image/x-png;base64,iVBORw0KGgoAAAANSUhEUgAAAC0AAAAxCAIAAADBbLctAAAABnRSTlMA/wD/AP83WBt9AAAACXBI
WXMAAA7EAAAOxAGVKw4bAAAFX0lEQVR4nO2Y208bVxCH55y9eO31DezYDgYcY0JTKkW5qFIrVVX/
5jxEat8qVaoUVYpISkNA3OKEyNiYGljvdWb6YOPdJWA7ULV5YB6so91zznz+zZyZoxXMDF+Ayf8b
YGi3HHG75YjbLUfc1PGvOTghrwVkXywyDACAyAFS3zP6bjJlmqZpWpZlWZap20ndUVWhSCmkCiIh
9aLUctfnIO/AP/qZ3AMeeA5/ABj6Np71g2a3tH80V6stNRqNnZ2dvd2dxdkPC7MtM6WmkppQ0op+
R5/94UYcHJyis8vuB6GkhYhMZgYAr+/0urZt6YRl3/cdx/E8z/e9/lm3B+80TpqqQd4heV018814
RxM4Bi6lmtPMhlTMoQ5DWRicngPdmTvL5fuPE4kkAJRKpbSZojPfsW1h5I1syj1rBkGPyb0xB4CQ
mqJmpZYNOZgBGBRGdg0jOzMz02q1P378WCwWC4WZMz/t2EmhpFXd9KTCZAHTeBdTnBeOZEQUYvgE
mJiQtra2nj9/vrm5iUjnvXM0ebJN5uBYdl6AYGBmJiQ0DKNYLBqGQYTMFMZusGiSl6nicoUSw8EA
pF6vFwqFZDKJSEThnCkFmZJj6DEOMXRB53pomkZEiD4znU++AH1tjsjfvgyCR3oQAxEhIiIxRSMZ
rTnX5ThfPtJ2BBFOYSIkZBaISEREyCNEmApiMgec7xcShEcgzNOLegxPKYerb84RIwiVCIEGIHv7
zd3d3Wq1Wq3OMZMcTZju+vtZ/ZYj2RfJD2JEevv27bNnzzY2NhCRiaYKxudxjAT4RImBERMRViqV
p0+fVioVQiTmy+I4zqY7twyfKAFh+JmRqF6vz83NCSGQSInlx1Q2kWMgw6d1mgE4oSvZjHHs+Eed
DhIw83Gn2eu+X6pyfS6haxKYmBmYmQIgH4QC4vIITHdeLoMYcOQyRrfvtdttYgEAe1trze0XxR9X
8w9WErrCjMCDKCGzL4S4KhM+p67HIQYc+awhDo6PWzuJVMXMzS9/9WhlZfnBPc5lSIG+Z1mIrgAM
zrY8NaOmV5Rk9Voc0UYRhwDmhK4mdEXibq+1li8/zhVqjcaTpfq9DLwy4U/npONah0QBAATWJpMr
tOx1OSCaapenaqG8tPp4PmFWUtnyUWv7cP/31SVYWSAin9BT9YzUUoHvotdhdK5yMlV+jIEA4Nni
4n1tgUEVQr55+WLr9S+FxNcr80tMPqKX0E09WcDePrpHTDfgiDm+pNtBp7W9vr5mZObT+dpsafm7
n4rVRQ+gP1gkhJRSEULy2GvIlHGJ16WYPNA7er+3+SZXeljkbG1xYXHx27yyDvDX8MwLKaQEmNBn
puq3gy4S2SjWaArlxuqTup4qJ9Ol7uH2wc6vD5eV7L1I3//X6unIdzgIx9l8eaFeZalLqbabf+xu
/Dafq0NtIVYDb3j/OGeIQ0QbDXCntb3++mUyW8vM1mfLjXLl7tzdU4BexHvscnZNjoiol+eHddo5
PNjOeBK0Yq1WW1yo5uQa8KsL24z38plxiSsxwKxUV558/wjUnKLnAaDdbmsZK5O8QDyBZCoOJsTA
BhDDfaNhYjYz1Wp91XZ813Vt2+71jjP8d1GzCQNmJvTRd5gQQLkBBwMAB/6pffJOCHWkQfia4fBE
2Tk2HDfwPM91Xd938tS8I5u+azGjax0FrhX4jlBnxlx3JnAIxZCJCpNPHE+UiMh+IDzP831EHNyQ
BbEaUAq0lKIBAwQsQM8rRkmq6Ssdjf9+Sn4X++8IrfBReB0Z2pmbPnWzSExERMRMM6l+LmXH/Ugh
DTW1qCSK1+H4z+xL+S51yxG3W4643XLE7R+yytyjJ+NMkAAAAABJRU5ErkJggg==
}

}

