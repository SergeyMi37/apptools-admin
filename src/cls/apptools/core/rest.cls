Include apptools.core

/// // The REST interface: class that routes HTTP requests
Class apptools.core.rest Extends %CSP.REST [ DependsOn = apptools.core.msg ]
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "UTF-8";

Parameter ISCPREFIX = "isc_cache";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/get-html/:text" Method="GET" Call="Index"/>
<Route Url="/post-json" Method="POST" Call="jsonrpc"/>
<Route Url="/get-files/:text" Method="GET" Call="Files"/>

<Route Url="/testpost" Method="POST" Call="Test"/>
<Route Url="/testget/:text" Method="GET" Call="Test"/>  
<Route Url="/finduser/:text" Method="GET" Call="FindUser"/>

<Route Url="/auth" Method="GET" Call="Auth"/>
<Route Url="/css/index.css" Method="GET" Call="GetCss"/>
<Route Url="/css/themes/:theme" Method="GET" Call="GetTheme"/>
<Route Url="/js/index.js" Method="GET" Call="GetJs"/>

<Route Url="/db" Method="GET" Call="getDBsize"/>
<Route Url="/dirsize/:path" Method="GET" Call="getDirSize"/>

<Route Url="/products/:mode" Method="GET" Call="getProductions"/>
<Route Url="/productslist/:ns" Method="GET" Call="getListErrProducts"/>

<Route Url="/proj/:proj/:metrics/:mode" Method="GET" Call="apptools.MVK.Metrics:getProj"/>
</Routes>
}

/*
/// sample servise JSON-RPC 2.0 https://www.jsonrpc.org/specification

{"jsonrpc": "2.0", "result": {"likes": 123}, "id": 1}
If error:
{"jsonrpc": "2.0", "error": {"code": 666, "message": "Post not found"}, "id": "1"}
Request:
[
  {"jsonrpc":"2.0","method":"server.shutdown","params":{"server":"42"},"id":1},
  {"jsonrpc":"2.0","method":"server.remove","params":{"server":"24"},"id":2}
]
Response:
[
  {"jsonrpc":"2.0","result":{"status":"down"},"id":1}
  {"jsonrpc":"2.0","error":{"code":1234,"message":"Server not found"},"id": 2}
]
*/
/// post http://server:57772/rest/jsonrpc
/// {"jsonrpc":"2.0","method":"GetInfo","params":{"code":"5007092465"},"id":123}
ClassMethod jsonrpc(ns = "", class = "", meth = "") As %Status
{
	set sc = $$$OK
	try {
	 	;merge $$$AppL("MML","%request.Data")=%request.Data
		;set $$$AppL("MML","%request.AppData")=%request.AppData
		;set $$$AppL("MML","req")=$$$AppObJs(%request)
		;if %request.Get("Username")'="",'..Authorize(%request.Get("Username"),%request.Get("Password")) {
		; 	;set %response.Status = "401 Unauthorized" quit
		; 	d ..jsonrpcError(401,"Unauthorized "_%request.Content) 
		;}
		if $isobject(%request.Content) { //POST
			d %request.Content.Rewind() 
			set json=%request.Content.Read($$$MaxStringLength) 
			set json = $ZCVT(json,"I","UTF8") 
			s $$$AppL("MML","jsonrpc-json")=json
	 		if ($g(json)["{") {
	 			set method={}.$$$jsonFromJSON(json).method
	 			set params={}.$$$jsonFromJSON(json).params
	 			set jsonrpc={}.$$$jsonFromJSON(json).jsonrpc
	 			set id={}.$$$jsonFromJSON(json).id
	 			if jsonrpc'="2.0" w ..jsonrpcError(2,"Version not supported "_jsonrpc) q
	 			s appPar=""
	 			if method[":" { if $p(method,":",1)'="" s ns=$p(method,":",1)
					if $p(method,":",2)'="" s class=$p(method,":",2)
					if $p(method,":",3)'="" s meth=$p(method,":",3)
					if $p(method,":",4)'="" s appPar=$p(method,":",4,*)
				}
				if ns'="" zn ns
				if $e(class,1)="^" {
					do @(meth_class_"(.par,.json)") ;??? xec public 
				} else {
					if appPar["~" {
						do ##class(apptools.core.type).ParseURL(appPar,.appPar,"~")  ;parse in array
					}
					elseif appPar["&" {
						d ##class(apptools.core.type).ParseURL(appPar,.appPar,"&")
					}
				   ;set %response.CharSet = "utf-8"
    			;	set %response.ContentType = "text/html"
    				;s appPar("params")=params
    				if $isobject(params) d ##class(apptools.core.Action).GetElemParseForm(params.form,.appPar,"z",0)
      				do $classmethod(class,meth,.appPar) 
					quit
				}
				;w "{""text"":""Hello world"",""inn"":"""_params.inn_"""}" q
				;w $ZCVT(str,"O","UTF8") 
				;w resjson
	 			
	 		}
		} else {
			;s $$$AppL("MML","%request")=$$$AppObJs(%request)
			;m $$$AppL("MML","%request.Data")=%request.Data
			;m $$$AppL("MML","%request.Content")=%request.Content
			;set $$$AppL("MML","%request.AppData")=%request.AppData
			 d ..jsonrpcError(3,"Bad request "_%request.Content)
			 q
		}
	} catch ex {
		set sc = ex.AsStatus()
		;s $$$AppL("MML","jsonrpc-err")=$System.Status.GetErrorText(sc)
		d ..jsonrpcError(4,"exception: "_$zconvert($System.Status.GetErrorText(sc),"O","HTML"))
	}
	return $$$OK
}

ClassMethod Authorize(user, password) As %String
{
	q $SYSTEM.Security.Login(user, password)
}

ClassMethod jsonrpcError(code, message) As %Status
{
	;w "{""jsonrpc"":""2.0"",""error"":{""code"":"""_code_""",""message"":"""_message_"""}}"
	Set json = $$$NewDynObj
 	s json.jsonrpc="2.0"
	s json.code=code
	s json.message=message
	$$$DynObjToJSON(json)
	q $$$OK
}

/// Method writes files.
/// /apptoolsrest/get-files/fileId
ClassMethod Files(fileId) As %Status
{
 s file=##class(apptools.core.DownloadCSP).GetfileName(fileId,,,.ContentType)
 ;get date modification	file
 set dh=$zu(140,2,file)
 if dh<0 set dh=$now(0)
 set date=$zd(dh, 11) _ ", "_ $zdt(dh, 2,1) _ " GMT"
 
 ;do %response.SetHeader("Last-Modified", date)
 if (%request.GetCgiEnv("HTTP_IF_MODIFIED_SINCE")=date) {
	        set %response.Status = "304 Not Modified"
	    } 
 else {
	set %response.CharSet="raw"
	;d %response.SetHeader("Expires", "0")
	;d %response.SetHeader("Accept-Ranges","bytes")

	if $g(ContentType)'="" {
		s mimetype=ContentType
	} else {
		set ext=$p(file,".",*)
		set mimetype=##class(apptools.core.filesMimeTypes).GetMimeTypes4ext(ext)
	}
	set %response.ContentType=mimetype
	
	set stream=##class(%FileBinaryStream).%New()
	set stream.Filename=file
	set size=stream.Size
	do %response.SetHeader("Content-Length",size)

	if ContentType["application/force-download" {
		set name=$p(file,$$$slash,*)
		set name=$ZCVT($ZCVT(name,"O","UTF8"),"O","URL")
		d %response.SetHeader("Content-Disposition","attachment;filename="_name)
	}

	while 'stream.AtEnd {
		set line=stream.Read()
		write line
	}
 }
  return $$$OK
}

ClassMethod Test(parameter) As %Status
{
	set %response.CharSet = "utf-8"
    set %response.ContentType = "text/html"
	&html<<h1>Status: OK!</h1><pre>>
	zw %request
	zw %response
	&html<</pre>>
	quit $$$OK
}

/// Search users by context
/// http://localhost:57772/apptoolsrest/finduser/super
ClassMethod FindUser(text = "") As %Status
{
 i $l(text)<3 d ..jsonrpcError(5,$$$aText("Search string must be at least 3 characters","")) q $$$OK
 zn "%SYS"
 s sql="select Name,FullName,Comment,EmailAddress,Enabled,CreateDateTime,LastModifiedDateTime from Security.Users where UPPER(FullName) [ '"_$zconvert(text,"U")_"'"
	#if $$$comClassDefined("%ZEN.Auxiliary.jsonSQLProvider")
		set Provider = ##class(%ZEN.Auxiliary.jsonSQLProvider).%New()
		set Provider.sql = sql
		Set Provider.%Format = $$$formatJSONSQL
		Set Provider.maxRows = 10000
		set st = Provider.%DrawJSON()
	#else
		set st = $$$ERROR($$$GeneralError,"Class %ZEN.Auxiliary.jsonSQLProvider does not exist")
	#endif
	return st
}

/// Calls StaticContent.Write method or sends not modified header. Type have to be "css" or "js"
ClassMethod WriteStatic(type As %String, ContentType As %String = "", xDataClass = "apptools.core.rest", ClassCSPPage = "", IsCached = 0) [ Private ]
{
    #define CompileTime ##Expression("""" _ $zd($h, 11) _ ", "_ $zdt($NOW(0), 2,1) _ " GMT""")
    set %response.CharSet = "utf-8"
    set %response.ContentType = $case(type,
        "css": "text/css",
        "js": "text/javascript",
        "html": "text/html",
        : $case(ContentType="", 1:"text/plain", :ContentType)
    )
    do %response.SetHeader("Last-Modified", $$$CompileTime)
    try{
		;if %request.Get("Username")'="",'..Authorize(%request.Get("Username"),%request.Get("Password")) {
		; 	set %response.Status = "401 Unauthorized" quit
		;}
	    if IsCached,(%request.GetCgiEnv("HTTP_IF_MODIFIED_SINCE")=$$$CompileTime) {
	        set %response.Status = "304 Not Modified"
	    } 
	    elseif ClassCSPPage'="" {
		    s param=$p(ClassCSPPage,"?",2,*)
		    s ClassCSPPage=$p(ClassCSPPage,"?")
		    s:ClassCSPPage[".cls" ClassCSPPage=$p(ClassCSPPage,".cls",1)
		    ;set $$$AppL("MMM","WriteStatic")=$lb(type,ClassCSPPage) ;$$$AppObJs(id)
		    ;set $$$AppL("MMM","%request")=$$$AppObJs(%request)
		    s method="OnPage"
		    s:ClassCSPPage[":" method=$p(ClassCSPPage,":",2,*),ClassCSPPage=$p(ClassCSPPage,":",1)
		    do:method["OnPage" $classmethod(ClassCSPPage,method,param)
	    }
	    else {
	        do ..WriteStaticContent(xDataClass,type)
	    }
    }
    catch e { 
    	w $ze
    	set %response.Status = "501 Not Implemented" ;"405 Method Not Allowed" ;"400 Bad Request"
    }
}

/// Method writes application CSS.
ClassMethod GetCss(class) As %Status
{
    do ..WriteStatic("css")
    return $$$OK
}

/// Method writes application theme.
ClassMethod GetTheme(Theme As %String) As %Status
{
    do ..WriteStatic("Theme"_$REPLACE(Theme, ".css", ""),"text/css")
    return $$$OK
}

/// Method writes application JavaScript.
ClassMethod GetJs() As %Status
{
    do ..WriteStatic("js")
    return $$$OK
}

/// Method writes application HTML.
ClassMethod Index(class) As %Status
{
    do ..WriteStatic("html","","",class)
    return $$$OK
}

/// Write the contents of xData tag
ClassMethod WriteStaticContent(Class As %String, Const As %String) As %Status
{
    set obj = ##class(%Dictionary.CompiledXData).%OpenId(Class_"||"_Const)
    return:(obj = "") $$$OK
    set xdata = obj.Data
    set status = ##class(%XML.TextReader).ParseStream(xdata, .textreader)
    while textreader.Read() { if (textreader.NodeType="chars") {
        write textreader.Value
    } }
    return $$$OK
}

ClassMethod getStatic(name As %String, ByRef Description) As %String
{
	set class = $case($l(name, ":"), 2:$p(name, ":"), :$classname())
	set queryName = $p(name, ":", *)
	set Description=""
	set str = ""	
	if ##class(%Dictionary.XDataDefinition).IDKEYExists(class, queryName) {
		set stream = ##class(%Stream.TmpCharacter).%New()
		for i=1:1:$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata) {
			do stream.WriteLine($$$comMemberArrayGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata,i))
		}
		set str = stream.Read($$$MaxLocalLength)
		set Description=$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdescription)
		
	}
	return str
}

/// To sorted sizes subdirs for Linux
/// w ##class(apptools.core.rest).getDirSize("/opt/isc/ensemble/mgr/")
ClassMethod getDirSize(path = "", ByRef res, minsize = 10) As %Status
{
	set gn = "^||tmpfile"
	do ##class(apptools.core.files).getPathcconsole(.dir,.logname)
	if $g(path)="" set path=dir ;location of default database
	if $zv'["Linux" quit $$$OK  ;for other OS not implemented
	set st=$$$OK
	set curNs=$zu(5)
	zn "%sys"
	set prefix = ..#ISCPREFIX_"_dirsize"
	set tempfile=$SYSTEM.Util.InstallDirectory()_"mgr/Temp/dirsize.log"
	kill @gn set nl = $c(10)
	try {
		set cmd="du -sm "_path_"*| sort -nr >"_tempfile
		set result = $zf(-1, cmd)
		if (result '= 0) { 
			w !,$System.Status.GetErrorText(result)
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Error:" _ result_", "_cmd)) 
		}
		else {
			set size=##class(apptools.core.files).File2Arr(tempfile,gn,"RSK\UTF8\")
			for i=1:1 { q:'$d(@gn@(i))   ;pass the loop through the entire report
				continue:$p(@gn@(i),$c(9))'>minsize ;eliminate small and empty directories
				set str=$g(@gn@(i))
				if $d(res) s res(i)=$P(str,$c(9),2)_" "_$P(str,$c(9),1)
				else  w prefix_"_"_$P(str,$c(9),2)_" "_$P(str,$c(9),1)_nl
			}
		}
	} catch ex {
		set st = ex.AsStatus()
		;$$$TRACE($system.Status.GetErrorText(st))
	}
	zn curNs
	quit st
}

/// The size of the database in Gigabytes
/// d ##class(apptools.core.rest).getDBsize("dbsize",.list)
ClassMethod getDBsize(prefix = {..#ISCPREFIX_"_dbsize"}, dbname, int = 1, all = 0) As %Status
{
	set nl = $c(10)
	new $namespace
	set $namespace="%sys"
	set gn="^||db"
	set st=##class(apptools.core.sys).SaveQuery("SYS.Database:FreeSpace",gn)
	set r=$q(@gn@("")) ;to the first link
	set r=$na(@gn@($qs(r,1),$qs(r,2))) ;take the first 2 of the index in the link
	s listDb=##class(apptools.core.sys).ListDB(.info,"NotPre,NotTemp")
	for i=1:1 { q:'$d(@r@(i))   ;pass the loop through the entire report
		continue:$g(@r@(i,1))=""
		;by default, we give all sizes to Gigabytes
		set free=$g(@r@(i,8))
		set dir=$g(@r@(i,2))
		set name=$g(@r@(i,1))
		if 'all,(","_listDb_",")'[(","_name_",") continue
		if 'all,(dir)[("secondary/")||((dir)[("temp/")) continue
		set size=$g(@r@(i,4))
		if size["MB" {s size=$j(size/(1024),"",3) ;if in MB, then divide
		}
		elseif size["TB" {s size=size*1024  ;if TB then multiply
		}
		else {
			set size=+size  ;if GB then translate into the number
		}
		set dbname(dir)=size
		set dbname(dir,"name")=name
		set dbname(dir,"free")=+free
		write:'int prefix_"_"_name_" "_size_nl
		write:'int prefix_"_"_name_"_DiskFreeSpace "_(+free)_nl
	}
	write nl
	quit $$$OK
}

ClassMethod getListErrProducts(nspace) As %Status
{
	d ##class(apptools.core.Production).GetListErrProducts(1,nspace)
	q $$$OK
}

ClassMethod getProductions(day = "1") As %Status
{
	d ##class(apptools.core.Production).GetStatusProducts(day,.errors)
	s ns=""
	for { s ns=$o(errors(ns)) q:ns=""
		s co=+$g(errors(ns,"CountErrors"))
		w $s(co:"/",1:"\")_"server_"_$zu(110)_"_"_ns_" Errors: "_co_$$$NL
	}
	q $$$OK
}

XData Themecache
{
<data>
<![CDATA[<!-- @include client/css/themes/cache.css -->]]>
</data>
}

XData html
{
<data>
<![CDATA[
<!-- @include client/index.html -->]]>
</data>
}

XData css
{
<data>
<![CDATA[<!-- @include client/css/index.css -->]]>
</data>
}

XData js
{
<data>
<![CDATA[<!-- @include client/js/index.js -->]]>
</data>
}

}

