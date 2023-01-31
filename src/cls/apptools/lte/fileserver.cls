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

/// Application
Property App As %String(MAXLEN = "");

/// Size
Property Size As %String(MAXLEN = "");

/// Description
Property Description As %String(MAXLEN = "");

/// Date and time
Property TimeStamp As %TimeStamp [ InitialExpression = {$zdt($h, 3, 1)} ];

/// User IP address
Property ClientIPAddress As %String(MAXLEN = 32) [ InitialExpression = {..GetClientAddress()} ];

Index idxNamespace On Namespace [ Type = bitmap ];

Index idxSize On Size [ Type = bitmap ];

Index idxApp On App [ Type = bitmap ];

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
/// Example do ##class(apptools.lte.fileserver).AddRecord($namespace, $username, "file.xml", "/backup/temp/file.xml", "Description file","app")
ClassMethod AddRecord(Namespace As %String = "", UserName As %String = "", Filename As %String = "", PathFilename As %String = "", Description As %String = "", app = "", size = "")
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
		Set record.App = app
		if '$g(size),##class(%File).Exists(PathFilename) {
			Set file=##class(%File).%New(PathFilename)
			set size=file.Size
		}
		Set record.Size = size
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

ClassMethod GetSelectNSpace(divId, CurNs = {$Namespace}) As %String
{
	set listNs=##class(apptools.core.sys).ListNS(.info)
	set selectNS=" <SELECT title="""_$$$aText("Namespace","")_""" name="""_divId_"NSpace"" id="""_divId_"NSpace""  ONCHANGE=""document.forms['loginfo'].submit();""> "
	for ns=1:1:$l(listNs,",") { continue:$p(listNs,",",ns)=""
		continue:$p(listNs,",",ns)["%ALL"
		set selected=$select(CurNs=$p(listNs,",",ns):"selected",1:"")
		set selectNS=selectNS_" <OPTION "_selected_" VALUE="""_$p(listNs,",",ns)_""">"_$p(listNs,",",ns)_"</OPTION>"
	}
	quit selectNS
}

ClassMethod FirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set app=$G(Par("app"))
	set %ui=1
	set onclick=$$$blockui("Wait...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~app="_app_"~mode=*")
	s dataFrom=$zd($h,3) ;##class(apptools.core.type).GetYear($h-30)_"-"_##class(apptools.core.type).GetMonth($h-30)_"-01"
	s dataTo=$zd($h+1,3) ;##class(apptools.core.type).GetYear($h)_"-12-31"
	if $roles["%All" {
		set onclick2=$$$blockui("Wait...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"FormContentSave",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~app="_app_"~mode=*")
		set ButtDel=$$$appButton(divId_"appButtonClenResult"," title='Delete files' onclick="""_$replace(onclick2,"*","del")_"""","delete")
		set selectNS=..GetSelectNSpace(divId)
		set checkboxDel=$$$appCheck(divId_"Dele","no-checked title='mark all for deletion' ","")
	}
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
			#($g(selectNS))#
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult","onclick="""_$replace(onclick,"*","find")_"""","find"))#		
			#($get(ButtDel)_" "_$g(checkboxDel))#
			</td>
		</tr>
		</table>
	>
	$$$SetHeightContent(divId,250)
	quit $$$OK
}

/// Admins files
ClassMethod AFSResult(Par = "") As %Status
{
	set app=$g(Par("app"))
	do ##class(apptools.lte.fileserver).Result(.Par)
}

/// Files
ClassMethod FSResult(Par = "") As %Status
{
	set app=$g(Par("app"))
	do ##class(apptools.lte.fileserver).Result(.Par)
}

ClassMethod Result(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set app=$g(Par("app"))
	set GN=..#GNStore
	set fromDate=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"fromDate")	
	set toDate=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"toDate")	
	set toDate=toDate_" 23:59:59"
	set NSpace=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"NSpace")
	set Dele=$s($d(Par("%request.Data",divId_"Dele")):1,1:0)
	write "<form id='"_divId_"FormContentSave'>"
	if NSpace'="",$namespace'=NSpace set $namespace=NSpace
	write $$$appInputHidden(divId_"NSpace","",$namespace)
    if mode="del" {
	    set count=0,i="",deleted=0
		for { set i=$o(Par("%request.Data",i)) quit:i=""
			if i[(divId_"chk-Id") {
				set id=$p(i,divId_"chk-Id",2)
				set count=count+1
				Set record = ..%OpenId(id)
					;w id_" "_$zu(5)
					if $iso(record) {
						set PathFilename=record.PathFilename
						write "<br>"_id_" "_PathFilename ; continue
						do ##class(%File).Delete(PathFilename)
						do ##class(%File).Delete(PathFilename_".zip")
						Set sc = ##class(apptools.lte.fileserver).%DeleteId(id)
						if sc set deleted=deleted+1
						else  write "<br>"_$System.Status.GetErrorText(sc)
						kill record
					}
				}
		}
		if count {
			write "<br>Found to delete: "_count_", deleted: "_deleted
		}
		else {
			write "<br>No items found to delete"
		}
    }
	elseif mode="find" {
		set sql="select ID,Filename, PathFilename, TimeStamp, UserName, Namespace, App from apptools_lte.fileserver where TimeStamp >='"_fromDate_"' and TimeStamp <='"_toDate_"' "
		if $roles'["%All" {
			set sql=sql_" and UserName='"_$UserName_"'"
		}
		else {
			set sql=$replace(sql,", App",", App, Size as SizeByte, PathFilename as Path")
		}
		if app'="" set sql=sql_" and App='"_app_"'"
		set sql=sql_" order by id desc"
		set %ui=1
		if $roles["%All" set addcheck="delete"
		set ExecuteDraw="##class(apptools.lte.fileserver).AddRefDownLoad(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp,"_##class(%Global).Quote($lb(addcheck,divId,Dele))_")"
		;write ExecuteDraw
		set tit=$zu(5)_" "_sql
		set st=##class(apptools.core.LogInfoPane).DrawSQL(sql,10000,$zu(5),tit,$g(ExecuteDraw),,1)
		write $System.Status.GetErrorText(st)
	}
	write "</form>"
	quit $$$OK
}

/// Generate active links for DownLoad files
ClassMethod AddRefDownLoad(Val, Col, Head, Temp, mode)
{
	set res=Val
	if $g(Head) {
		if $g(Val)="PathFilename" s Temp("PathFilename",Col)=""
		if $g(Val)="UserName" s Temp("UserName",Col)=""
		if $g(Val)="SizeByte" s Temp("SizeByte",Col)=""
		if $g(Val)="ID" s Temp("ID",Col)=""
	}
	else {
		if $D(Temp("PathFilename",Col)) {
		if Val[$$$slash {
				if ##class(apptools.core.DownloadCSP).GetFileId(Val,.url) { 
				set res="<a title='DownLoad' href='"_url_"'>"_$P(Val,$$$slash,*)_"</a>"
				}
			}
		}
		elseif $D(Temp("SizeByte",Col)) {
			set res=$j(res/(1024*1024),"",2)_" Mb"
			if res>30 set res="<span style='color:red'>"_res_"</span>"
		}
		elseif $D(Temp("ID",Col)) {
			if $g(mode)'="" { 
				set checked=$S($lg(mode,3):"checked",1:"")
				set checkbox=$$$appCheck($lg(mode,2)_"chk-Id"_res,checked_" title='mark for deletion' ","")_" "
				set res=$g(checkbox)_res
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
<Value name="9">
<Value>App</Value>
</Value>
<Value name="10">
<Value>Size</Value>
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

