Include apptools.core

/// fileserver module for LTE admin application
/// (%Persistent, apptools.lte.adminTabs) [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
Class apptools.lte.fileserver Extends %Persistent
{

/// Application title
Parameter HeaderText = "fileserver";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.fileserver";

/// Roles
Parameter AppRoles = "ui_fileserver";

/// Namespace
Property Namespace As %String(MAXLEN = "");

/// Cache user
Property UserName As %String(MAXLEN = 128) [ InitialExpression = {$username} ];

/// Filename
Property Filename As %String(MAXLEN = "");

/// PathFilename
Property PathFilename As %String(MAXLEN = "");

/// Description
Property Description As %String(MAXLEN = "");

/// Date and time
Property TimeStamp As %TimeStamp [ InitialExpression = {$zdt($h, 3, 1)} ];

/// User IP address
Property ClientIPAddress As %String(MAXLEN = 32) [ InitialExpression = {..GetClientAddress()} ];

Index idxNamespace On Namespace [ Type = bitmap ];

Index idxUserName On UserName [ Type = bitmap ];

Index idxPathFilename On PathFilename [ Type = bitmap ];

Index idxFilename On Filename [ Type = bitmap ];

Index idxTimeStamp On TimeStamp [ Type = bitslice ];

Index idxClientIPAddress On ClientIPAddress;

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

/// select * from apptools_lte.fileserver
/// Example do ##class(apptools.lte.fileserver).AddRecord($namespace, $username, "everything", "INFO", "actions")
ClassMethod AddRecord(Namespace As %String = "", UserName As %String = "", Filename As %String = "", PathFilename As %String = "", Description As %String = "")
{
	new $namespace
	try {
		if Namespace'="" set $namespace=Namespace
		Set record = ..%New()
		Set record.Namespace = Namespace
		Set record.UserName = UserName
		Set record.Filename = Filename
		Set record.PathFilename = PathFilename
		Set record.Description = Description
		;zw record
		set sc=record.%Save()
		set:sc sc=record.%Id()
	} catch ex {
		Set sc = $g(%objlasterror, $$$OK)
   		Set sc = $$$ADDSC(sc, ex.AsStatus())
	}
	quit $g(sc)
}

/// do ##class(apptools.lte.fileserver).GetApp(.opt,"FilesServ","FS","Files",$namespace,sideMenu)
ClassMethod GetApp(ByRef opt, key, id, title, ns, sideMenu) As %Status
{
	set opt(key,"Menu")=sideMenu
	set opt(key)=title
	set opt(key,"Namespace")=ns
	set opt(key,"id")=id
	set opt(key,"TabName")=title
	set opt(key,"ClassName")="apptools.lte.fileserver"
	set opt(key,"Method")="ShowTabSample" 
	set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free
	set opt(key,"Active")=0 ;active menu item
	quit $$$OK
}

ClassMethod FirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	set onclick=$$$blockui("Wait...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~mode=*")
	s dataFrom=$zd($h,3) ;##class(apptools.core.type).GetYear($h-30)_"-"_##class(apptools.core.type).GetMonth($h-30)_"-01"
	s dataTo=$zd($h+1,3) ;##class(apptools.core.type).GetYear($h)_"-12-31"
	;if $roles["%All" set ButtDel=$$$appButton(divId_"appButtonClenResult"," title='Delete files' onclick="""_$replace(onclick,"*","del")_"""","delete")
	&html<
		<table>
		<tr>
			<td>
			from #($$$appDate(divId_"fromDate","",dataFrom))#
			</td>
			<td>
			to #($$$appDate(divId_"toDate","",dataTo))#
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult","onclick="""_$replace(onclick,"*","find")_"""","find")_$get(ButtDel))#		
			
			</td>
		</tr>
		</table>
	>
	$$$SetHeightContent(divId,0)
	quit $$$OK
}

/// Файлы отчета админа
ClassMethod AFSResult(Par = "") As %Status
{
	do ##class(apptools.lte.fileserver).Result(.Par)
}

/// Файлы
ClassMethod FSResult(Par = "") As %Status
{
	do ##class(apptools.lte.fileserver).Result(.Par)
}

ClassMethod Result(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set GN=..#GNStore
	set fromDate=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"fromDate")	
	set toDate=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"toDate")	
	set sql="select Filename, PathFilename, TimeStamp, UserName,Namespace from apptools_lte.fileserver where TimeStamp >='"_fromDate_"' and TimeStamp <='"_toDate_"' "
	if $roles'["%All" set sql=sql_" and UserName='"_$UserName_"'"
	set sql=sql_" order by id desc"
	set %ui=1
	if mode="find" {
		s ExecuteDraw="##class(apptools.lte.fileserver).AddRefDownLoad(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp)"
		set st=##class(apptools.core.LogInfoPane).DrawSQL(sql,10000,$zu(5)," ",$g(ExecuteDraw))
		write $System.Status.GetErrorText(st)
	}
	elseif mode="del" {
		set sql="select id, PathFilename, TimeStamp from apptools_lte.fileserver where TimeStamp >='"_fromDate_"' and TimeStamp <='"_toDate_"' "
		set gn="^||del"
		set st=##class(apptools.core.sys).SaveSQL(sql,gn)
		for i=1:1 { quit:'$d(@gn@(i))
			set $lb(id,fn)=##class(apptools.core.sys).GetValueGN(gn,i,"ID,PathFilename")
			;w "<br>"_fn
		}
		w "Deleted"
	}
	quit $$$OK
}

/// Generate active links for DownLoad files
ClassMethod AddRefDownLoad(Val, Col, Head, Temp)
{
	set res=Val
	if $g(Head) {
		if $g(Val)="PathFilename" s Temp("PathFilename",Col)=""
		if $g(Val)="UserName" s Temp("UserName",Col)=""
	}
	else {
		if $D(Temp("PathFilename",Col)) {
			if Val[$$$slash {
				if ##class(apptools.core.DownloadCSP).GetFileId(Val,.url) { 
				set res="<a title='DownLoad' href='"_url_"'>"_$P(Val,$$$slash,*)_"</a>"
				}
			}
		}
	}
	quit res
}

Storage Default
{
<Data name="fileserverDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Namespace</Value>
</Value>
<Value name="3">
<Value>UserName</Value>
</Value>
<Value name="4">
<Value>Filename</Value>
</Value>
<Value name="5">
<Value>PathFilename</Value>
</Value>
<Value name="6">
<Value>Description</Value>
</Value>
<Value name="7">
<Value>TimeStamp</Value>
</Value>
<Value name="8">
<Value>ClientIPAddress</Value>
</Value>
</Data>
<DataLocation>^apptools.lte.fileserverD</DataLocation>
<DefaultData>fileserverDefaultData</DefaultData>
<ExtentSize>0</ExtentSize>
<IdLocation>^apptools.lte.fileserverD</IdLocation>
<IndexLocation>^apptools.lte.fileserverI</IndexLocation>
<StreamLocation>^apptools.lte.fileserverS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

