Include apptools.core

/// http://hp-msw:52773/apptoolsrest/a/permiss2
Class apptools.lte.permiss2 Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Permissions";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.Permissions";

Parameter AppRoles = "ui_Permissions";

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set path=par("=path=")
 set par("=Brand-Text=")="Admin v.2"
 set par("=Logo-image=")=path_"adminlte/dist/img/ApptoolsLogo.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"adminlte/dist/img/ApptoolsLogo","png")
 quit ..RepaceParameter(.h,.par)
}

/// what modes are available
ClassMethod GetAllApps(opt) As %Status
{
	;side menu
	set sideMenuName="Permission",
		sideMenuNumer=1,
		sideMenuOpen=1,        //3 =1 open menu
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
			set opt(key,"TabMenu","Close")=1
			set opt(key,"Active")=1 ;active menu item
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
			set opt(key,"TabMenu","Close")=1
			set opt(key,"aw-icon")="fa-table"   ;https://fontawesome.com/icons?d=gallery&p=2&m=free

	;top menu
		s LeftMenuName="Support",LeftMenuNumer=1
		s key="menu-top-support"
		s opt(key)="support"
		s opt(key,"id")="Support"
		s opt(key,"TabName")="Support" 
		s opt(key,"ClassName")=..%ClassName(1)
		s opt(key,"Method")="ShowTabSupport"
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
		set opt(key,"TabMenu","Close")=1
		set opt(key,"MenuTop")=$lb(topMenuNumer,topMenuName)
	set key="menu-top-account3"
		set opt(key,"MenuTop")=$lb(topMenuNumer,topMenuName) ; 99-account has nested items
		set opt(key)="Exit"
		set opt(key,"id")="AccountExit"
		set opt(key,"TabName")="Logoit" 
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Method")="Logout"
	
	do ..CheckRoleMenu(.opt)
	quit $$$OK
}

/// the render Tab On the program"
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabSupport(key = "") As %Status
{
	if $g(key("appPar"))'="" set key=key("appPar")
	do ..GetAllApps(.opt) 
	if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
	set divId=$g(opt(key,"id"))
	write ..#ToAdmin
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
 			Login <br><br>#($$$appText(divId_"name","title='"_$$$aText("Names separated by a comma or by context","")_"'","s"))#
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

