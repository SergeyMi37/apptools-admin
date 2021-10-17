Include apptools.core

Class apptools.core.LogInfo Extends apptools.core.AutoPage [ DependsOn = apptools.core.msg ]
{

Parameter CSPURL = "apptools.core.LogInfo.cls";

Parameter PAGENAME = "apptools.Tools";

Parameter PARENTPAGE = "apptools.core.AutoPage.cls";

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	quit ##class(apptools.core.LogInfoPane).%New()
}

/// To INPUT button to clear form fields
/// fields - field names separated by commas
/// w ##class(apptools.core.LogInfo).ClearFields("a,b")
ClassMethod ClearFields(fields = "", onclick)
{
	set res="<span class='ui-icon ui-icon-trash' name='clearFields' id='clearFields' onclick=""#"" title='clear form fields'></span>"
	for f=1:1:$l(fields,",") {
		continue:$p(fields,",",f)=""
		s onclick=$g(onclick)_"try{document.getElementById('"_$p(fields,",",f)_"').value=''}catch(e){};"
	}
	quit $replace(res,"#",$g(onclick,"alert('not fields');"))
}

/// Mark in red the context in the original string
/// Source - the Source string
/// Mark - the context to mark a comma
/// w ##class(apptools.core.LogInfo).MarkRed("ssssazzzzbssss","a,b")
ClassMethod MarkRed(Source, Mark)
{
	set res=Source
	for f=1:1:$l(Mark,",") {
		continue:$p(Mark,",",f)=""
		s res=$replace(res,$p(Mark,",",f),"<font color=red>"_$p(Mark,",",f)_"</font>")
	}
	quit res
}

/// To include in the string frame tag
/// Source - the Source string
/// Mark - the context of the phrases to insert this list
/// TagBeg, TagEnd - borders tag for each phrase needs to be your list
/// w ##class(apptools.core.LogInfo).IncludTags("ssssazzzzbssss","a,b",")
ClassMethod IncludTags(Source, Mark, TagBeg, TagEnd)
{
	set res=Source
	for f=1:1:$ll(Mark) {
		continue:$lg(Mark,f)=""
		s res=$replace(res,$lg(Mark,f),$lg(TagBeg,f)_$lg(Mark,f)_$lg(TagEnd,f))
	}
	quit res
}

/// To obtain a set of input elements to discharge flow in Excel and sending by mail
/// w ##class(apptools.core.LogInfo).GetInputXLSTags()
/// To upload a XLS <input type="checkbox" name="exportXLS" id="exportXLS" #($s($g(exportXLS):"checked",1:""))#>
ClassMethod GetInputXLSTags(exportXLS, exportXLSfile, exportXLSfileEmail)
{
 &html<
 #($$$aText("Unload in",""))# XLS <input type="checkbox" name="exportXLS" id="exportXLS" >
 #($$$aText("file",""))# <input type="text" size=30 name="exportXLSfile" id="exportXLSfile" value="#($g(exportXLSfile))#">
 #($$$aText("and send on",""))# <input placeholder="email@mail.com,email2@mail.com" type="text" size=30 name="exportXLSfileEmail" id="exportXLSfileEmail" value="#($g(exportXLSfileEmail))#">
 >
 quit ""
}

/// To obtain the values of input elements to discharge flow in Excel and sending by mail
/// d ##class(apptools.core.LogInfo).GetInputXLSTagsVal(.exportXLS, .exportXLSfile, .exportXLSfileEmail)
ClassMethod GetInputXLSTagsVal(exportXLS, exportXLSfile, exportXLSfileEmail, SDNum, suffix = "")
{
	set:$d(%request) exportXLSfile=%request.Get("exportXLSfile")
	if $g(exportXLSfile)="" s exportXLSfile=$$$EMAILXLSPATH_$zd($h,3)_"_"_$tr($zt($p($h,",",2),1),":")_"_"_suffix_".xls"
	set:$d(%request) exportXLS=%request.Get("exportXLS")["on"
	set:$d(%request) exportXLSfileEmail=%request.Get("exportXLSfileEmail")
	if $g(exportXLSfileEmail)="" s exportXLSfileEmail=$$$EMAILSUPPORT
	set:$d(%request) SDNum=%request.Get("SDNum")
	quit ""
}

/// To send a file to the user with the message
/// w ##class(apptools.core.LogInfo).SendEmail("mihaylenko_sv@server-post.ru", "Test", "Test message", "c:\temp\2019-01-16_32309.xls")
ClassMethod SendEmail(supportemail = "", subj = "", msg = "", file = "") As %Status
{
		set subj=$$$aText("Server","")_" : "_$zu(110)_", "_subj
		set text="<html><head></head><body color=greay><h4>"_$$$aText("Hello","")_"!</h4><br><br>"_$g(msg)
		set text=text_"</body></html>"
		// support
		if supportemail="" set supportemail=$$$EMAILSUPPORT		
		set email=supportemail //only 
		
		set authFrom=$$$EMAILAUTH
		set authFromPass=$$$EMAILAUTHPASS
		if file'="" {
			s path=$p(file,$$$slash,1,*-1)
			s file=$lb($p(file,$$$slash,1,*-1)_$$$slash,$p(file,$$$slash,*))
		}
		set sc=##class(apptools.core.net).SendMail($$$EMAILSERVERIP,$$$EMAILSERVERPORT, 0, 0, "", authFrom, authFromPass, authFrom, email_","_supportemail, subj, text,.file)
		;set ^logMSW($i(^logMSW))=$lb(sc,$$$EMAILSERVERIP,$$$EMAILSERVERPORT, 0, 0, "", authFrom, authFromPass, authFrom, email_","_supportemail, subj)
		if 'sc {
			w !,"Error "_$System.Status.GetErrorText(sc) 
			$$$AppLogTab("ERROR","()",$System.Status.GetErrorText(sc))
		}
		else { w !,$$$aText("Sent to","")_" "_email
		 	$$$AppLogTab("INFO","()",$$$FormatText($$$aText("Sent to %1 file %2",""),email,$g(file)))
		}
		quit sc
}

/// w ##class(apptools.core.LogInfo).GetInfoImg("tools")
ClassMethod GetInfoImg(code)
{
	quit "<a title='to tools' target=tools href=""apptools.core.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_$zconvert("?","O","URL")_""">"_..GetImgJqUi(code)_"</a>"
}

/// w ##class(apptools.core.LogInfo).GetImgJqUi("help")
ClassMethod GetImgJqUi(code)
{
	quit:code="help" "<span class='ui-icon ui-icon-help'></span>"
	quit:code="search" "<span class='ui-icon ui-icon-search'></span>"
	;quit:code="apptools" "<img src="""_$$$PATHCSP_"jqueryui/img/apptools-ico-lofel.ico"" width=""1%""/>" 
	;quit:code="apptools" "<img src="""_$$$PATHCSP_"jqueryui/img/apptools-ico.ico"" width=""1%""/>" ;gear
	quit:code="tools" "<span class='ui-icon ui-icon-wrench' ></span>" ;gear wrench
	quit:code="trash" "<span class='ui-icon ui-icon-trash'></span>"
	quit:code="check" "<span class='ui-icon ui-icon-check'></span>"
	quit:code="closethick" "<span class='ui-icon ui-icon-closethick'></span>"
	quit ""
}

/// Export all projects to XML
/// d ##class(apptools.core.LogInfo).ExportProjects("/backup/iris/source/",.file)
ClassMethod ExportProjects(Dir, files) As %Status
{
	$$$NspGoto(curNs,"apptools")
	d ..ExportAppProj(Dir,"apptools",.files)
	$$$NspReturn(curNs)
	d ##class(apptools.core.net).SendFilesToEmail($zn,Dir,.files)
	q $$$OK
}

/// xec do ##class(apptools.core.LogInfo).ExtSQL()
ClassMethod ExtSQL(gn, DSN = "", h = "", v = "") As %Status
{
	if '$d(@gn) w "It's node undefined" q $$$OK
	if $d(@gn@(-3,"sql")) {
		s sql=$replace( $lg(@gn@(-3,"sql"),1), $c(34)_$c(9)_$c(34) , "")
		if h'="" s h="CHARACTERISTIC = '"_h_"'"
		if v'="" s v="CHARACTERISTICSPGZENUM like '%"_v_"%'"
		i h'="" s sql=$replace(sql,"where","where "_h_" and "_v_" and ")
		w "<b>"_sql_"</b>"
		set MaxNode=10000
		if $g(sql)'="" {
			if DSN'="" {
				set gnTemp=$na(@$$$TEMPORYGN@($username))
				KILL @gnTemp
				set st=##class(apptools.core.sys).SqlToDSN(sql,DSN,gnTemp,MaxNode)
				if $d(@gnTemp) {
					set st=##class(apptools.core.LogInfoPane).DrawSQL("result "_gnTemp,MaxNode,$NameSpace,"DSN: "_DSN_", Query: <br>"_$g(sql)_"<br>"_gnTemp,$g(ExecuteDraw))
				}
			}
			else {
					set st=##class(apptools.core.LogInfoPane).DrawSQL(sql,MaxNode,$NameSpace,"Namespace: "_$NameSpace_" "_$g(msg),$g(ExecuteDraw))
			}
			if $$$ISERR(st) write "<br>Error :"_##class(%CSP.Page).EscapeHTML(sql_"; "_$SYSTEM.OBJ.DisplayError(st))_"<br>"
		}
	} else {
		w "Not found nnode -3,""sql"")"
	}
	quit $$$OK
}

/// Export all projects to XML
/// d ##class(apptools.core.LogInfo).ExportProj("/backup/source/","app")
ClassMethod ExportAppProj(Dir, proj = "", files) As %Status
{
	/*
The items to export.
Each of the items must have a type determined by an extension selected from the following list of basic types, additional types are supported under the abstract routine interface so this list is not exhaustive.

CLS - Classes
CSP - Cache Server Pages
CSR - Cache Rule files
MAC - Macro routines
INT - Non-macro routines
BAS - Basic routines
INC - Include files
GBL - Globals
PRJ - Studio projects
OBJ - Compiled object code
PKG - Package definitions
If exporting multiple items, separate them with commas, pass the items("item")="" as an array. You can also use ? or * wild cards and if you wish to exclude items pass ' before the item name which also supports wild card, e.g. "User.*.cls,'User.T*.cls".
	*/
	new $namespace
	try {
	s pFileName=Dir_$zu(110)_"-"_$zu(5)_"-"_proj_"-"_$tr(##class(apptools.core.type).GetDateTime($h),":T","-_")_".xml"
	s list("apptools*.CLS")=""
	s list("apptools*.INC")=""
	s list("apptools.core.ParameterD.GBL")=""
	s st=$SYSTEM.OBJ.Export(.list, pFileName)
	i st w !,pFileName s files(pFileName)=""

	k list
	s list("/apptools/*.*")=""
	s pFileName=Dir_$zu(110)_"-"_$zu(5)_"-"_proj_"-CSP-"_$tr(##class(apptools.core.type).GetDateTime($h),":T","-_")_".xml"
	s st=$SYSTEM.OBJ.Export(.list, pFileName)
	i st w !,pFileName s files(pFileName)=""

	k list
	s list("%apptools.Setting.GBL")=""
	s list("%AppCacheMsg.GBL")=""
	s list("%apptools.Proj.GBL")=""
	s list("%apptools.core.ParameterD.GBL")=""
	
	s pFileName=Dir_$zu(110)_"-"_$zu(5)_"-"_proj_"-AppSett-"_$tr(##class(apptools.core.type).GetDateTime($h),":T","-_")_".xml"
	s $namespace="%SYS"
	s st=$SYSTEM.OBJ.Export(.list, pFileName)
	i st w !,pFileName s files(pFileName)=""

	} catch e { w !,"Error: "_$ze}
	w !,$System.Status.GetErrorText(st)
	
	q $$$OK
}

}

