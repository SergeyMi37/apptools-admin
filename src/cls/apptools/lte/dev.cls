Include apptools.core

/// http://hp-msw:52773/apptoolsrest/a/dev
Class apptools.lte.dev Extends apptools.lte.adminStatic [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Development";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.Dev";

Parameter AppRoles = "%All";

/// do ##class(apptools.lte.dev).Init()
ClassMethod Init() As %Status
{
	set ServerPort=##class(apptools.core.net).GetURI(.prop)
	write !,"Open in browser "
    do ##class(apptools.core.Installer).AddAndWriteFavorite(##class(apptools.core.Installer).#AppName_" Dev","/"_##class(apptools.core.Installer).#AppCSP_"rest/a/dev",ServerPort)
}

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set path=par("=path=")
 set par("=Brand-Text=")=..#HeaderText
 set par("=path=")=path
 set par("=Brand-Text=")=..#HeaderText
 set par("=Logo-image=")=path_"adminlte/dist/img/ApptoolsLogo.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"adminlte/dist/img/ApptoolsLogo","png")
 do ..CheckPermiss(.par)
 quit ..RepaceParameter(.h, .par)
}

/// what are the available modes
ClassMethod GetAllApps(opt) As %Status
{
 

	;make sidebar
	quit $$$OK
}

/// download template forms search
ClassMethod FindFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set onclick=$$$blockui("Load...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~mode=*")
		&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
				Context name users
			</td>
			<td>
				#($$$appText(divId_"textName","title='context in Name'","s"))#
			</td>		
			<td>
				#($$$appText(divId_"textDesc","title='context in FullName'","m"))#
			</td>
		</tr>
		<tr>
			<td>
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Find USERS"))#
			</td>
			<td>
			</td>
		</tr>
		</table>
	>
 $$$jsstart
 	write "$('[id^="""_divId_"text""]').keydown(function (e) { if (e.keyCode == 13) { $('#"_divId_"appButtonResult1').click(); }});"_$c(13,10)
 $$$jsstop
	
	quit $$$OK
}

/// Search result
ClassMethod FindResult(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;Geting elements from form and prepare array Par
	set Name=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"textName")	
	set Desc=$g(Par("%request.Data",divId_"textDesc"))
	set st=$$$OK
	if mode=1 {
		write ..ButtonAgain(divId,key)
		if Name="" w $$$appError($$$aText("Context is empty","")) quit $$$OK
		zn "%sys"
		set sql="select ID,name,EmailAddress,fullName from Security.Users where Enabled [ '1' "
		if Name'="" s sql=sql_" and (name like '%"_Name_"%') "
		if Desc'="" s sql=sql_" and (fullName like '%"_Desc_"%') "
		set msg="Query: "_sql
		set exec="##class(apptools.core.LogInfo).MarkRed(%AppLogInfoVal,"""_$GET(Name)_","_$GET(Desc)_""")"
		set st=##class(apptools.core.LogInfoPane).DrawSQL(sql,100000,$zu(5),msg,exec)
		if 'st  w $$$appError($System.Status.GetErrorText(st))
		quit $$$OK
	} 
	write "<br>"
	quit $$$OK
}

}

