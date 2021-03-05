Include apptools.core

/// http://hp-msw:52773/apptoolsrest/a/permiss
Class apptools.lte.permiss Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Permissions";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.Permissions";

Parameter AppRoles = "ui_Permissions";

/// Replace parameters
ClassMethod MainParameter(ByRef h, path, url = "") As %Status
{
 set par("=Brand-Text=")="AppTools-admin"
 set par("=Logo-png=")="ApptoolsLogo.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"dist/img/ApptoolsLogo","png")
 quit ..RepaceParameter(.h, path, url,.par)
 quit $$$OK
}

/// what modes are available
ClassMethod GetAllApps(opt) As %Status
{
	if ..IsPermiss("%All") {	
	set LeftMenuName="Permission",
		LeftMenuNumer=1,
		open=1,        //3 =1 open menu
		icon="fa-cog"  //4  icon
	set menu=$lb(LeftMenuNumer,LeftMenuName,open,icon) 
	set key="MenuMatrix"
	set opt(key)=$$$aText("The matrix","") ;The name of the menu
	set opt(key,"id")="Matrix"
	set opt(key,"TabName")=$$$aText("The matrix","") ;the name of the tab
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabSample"
	set opt(key,"Disable")=0 ;developed
	set opt(key,"TabMenu","Close")=1
	set opt(key,"Menu")=menu
	set opt(key,"Active")=1 ;active menu item
	set opt(key,"aw-icon")="fa-list-alt" ;fa-table"

	set LeftMenuName="Account",LeftMenuNumer=99
	set key="menu-top-account3"
	set opt(key)="Exit"
	set opt(key,"id")="AccountExit"
	set opt(key,"TabName")="Logoit" 
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="Logout"
	set opt(key,"MenuTop")=$lb(LeftMenuNumer,LeftMenuName) ; 99-account has nested items
	}
	quit $$$OK
}

/// download form template search users and roles
ClassMethod MatrixFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	set onclick=$$$blockui("Load...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
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

}

