Include apptools.core

/// Withdraw the necessary actions
Class apptools.core.Action Extends %CSP.Page [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// s par=##class(apptools.core.Action).GetParam(.%request,"ns",param)
ClassMethod GetParam(req, paramName, param, del = "&") As %Status
{
 if $d(req) { 
 	q $tr(req.Get(paramName),"#")
 }
 else { set val=$p($p(param,(del_paramName_"="),2),del,1)
 	quit val
 }
}

/// Main method generate the content of page
ClassMethod OnPage(param) As %Status
{
	set $zt="Err"
 	#dim %request as %CSP.Request

	if '$d(%request) {
		d ##class(apptools.core.type).ParseURL(param,.appPar,"&")
		if $g(appPar("appAct"))'="" {
			d ..RunMethod($p(appPar,":",1),$p(appPar,":",2),$p(appPar,":",3),.appPar)
			q $$$OK
		}
		if $g(appPar("appClass"))'="" {
			d ..RunMethod($g(appPar("appNsp")),$g(appPar("appClass")),$g(appPar("appMethod")),.appPar)
			q $$$OK
		}
		
		q $$$OK
	}

 	;set $$$AppL("MSW","req")=$$$AppObJs(%request)
 	;merge $$$AppL("MSW","%request.Data")=%request.Data
	;set $$$AppL("MSW","%request.AppData")=%request.AppData

 	if %request.Get("appAct")'="" { ;AppAct=NameSpace:Packet.ClassName:Method:@Par1=Val1@Par2=Val2...
 		set appPar=$p(%request.Get("appAct"),"AppAct=",2,*)
		set i=""
		for { set i=$o(%request.Data(i)) quit:i=""
			set:$o(%request.Data(i,""),-1)'="" appPar("%request.Data",i)=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
		}
		d ..RunMethod($p(appPar,":",1),$p(appPar,":",2),$p(appPar,":",3),.appPar)
		q $$$OK
 	} else {
	 	set appNsp=%request.Get("appNsp")
		set appMethod=%request.Get("appMethod")
		set appClass=%request.Get("appClass")
		set appPar=%request.Get("appPar")
		set appJson=%request.Get("appJson")
		set i=""
		for { set i=$o(%request.Data(i)) quit:i=""
			if i["appNsp",appNsp="" s appNsp=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appMethod",appMethod="" s appMethod=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appClass",appClass="" s appClass=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appPar",appPar="" s appPar=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appJson" s appJson=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			set:$o(%request.Data(i,""),-1)'="" appPar("%request.Data",i)=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
		}
		;if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
		;set NSpace=$zu(5)

	 	if $isobject(%request.Content) { 
		 	set stream=%request.Content
			set sc=##class(apptools.core.files).Stream2String(%request.Content,.str)
			if 'sc quit sc
		 	if $g(str)["{" d ..ParseJson(.str,.appClass,.appMethod,.appPar) ;m appPar("%request.Content")=str  m appPar("%request")=$$$AppObJs(%request)
		 	;merge $$$AppL("MSW","Content")=str
	 	}
	  	i $g(appJson)["{" d ..ParseJson(.appJson,.appClass,.appMethod,.appPar) ;m appPar("%request")=$$$AppObJs(%request)
  	}
 	
	if appMethod="" {
		$$$jsstart
 		write "alert('"_$$$aText("The appMethod parameter is empty","")_"');"
 		$$$jsstop
 		zw jsobj
 		m a=%request.Data
 		zw a
 		w
		quit $$$OK
	}
	elseif appMethod="ShowJson" {
		if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
		d ..ShowJson(appPar)
	}
	elseif appMethod="ShowXML" {
		if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
		d ..ShowXML(appPar)
	}
	else {
		d ..RunMethod(appNsp,appClass,appMethod,.appPar)
	}
	
	quit $$$OK
Err 
	write $zconvert($ze,"O","HTML")
	quit $$$OK
}

/// To execute the method
ClassMethod RunMethod(appNsp, appClass, appMethod, appPar) As %Status
{
	if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
	set NSpace=$zu(5)
		set:appClass="" appClass="apptools.core.Action"
		if $e(appPar,1)="{" {
			;Parse json TODO
		}
		elseif appPar["~" {
			do ##class(apptools.core.type).ParseURL(appPar,.appPar,"~")  ;parse in array
		}
		elseif appPar["&" {
			d ##class(apptools.core.type).ParseURL(appPar,.appPar,"&")
		}
		Do $CLASSMETHOD(appClass,appMethod,.appPar)
}

/// Show a formatted json 
ClassMethod ShowJson(appPar, json) As %Status
{
	set gn=$zconvert(appPar,"I","URL")
	try {
		write "<h3>"_gn_" in NameSpace :"_$zu(5)_"</h3>"
		if '$d(@gn) w $$$appError("Global node does not exist") q
		write "<pre>" write $g(@gn) write "</pre>" 
	} catch e { w $ze }
	quit $$$OK
}

/// Show formatted XNL
ClassMethod ShowXML(appPar, json) As %Status
{
	set gn=$zconvert(appPar,"I","URL")
	try {
		write "<h3>"_gn_" in NameSpace "_$zu(5)_"</h3>"
		if '$d(@gn) w $$$appError("Global node does not exist") q
		write $zconvert($g(@gn),"O","HTML")
	} catch e { write $ze }
	quit $$$OK
}

/// To disassemble the drain to Json
ClassMethod Test(appPar, json) As %Status
{
	write "ClassMethod Test."
	zwrite appPar
	quit $$$OK
}

/// To disassemble the drain to Json
ClassMethod ParseJson(jsonStr, appClass, appMethod, appPar) As %Status
{
 try {
	set appClass={}.$$$jsonFromJSON(jsonStr).appClass
	set appMethod={}.$$$jsonFromJSON(jsonStr).appMethod
	set appPar={}.$$$jsonFromJSON(jsonStr).appPar
	set appPar("jsonStr")=jsonStr
	}
 catch e { 
 	write $zconvert($ze,"O","HTML")
 }
 quit $$$OK
}

/// Write Action Js 
/// w ##class(apptools.core.Action).WriteWinOpenREST(%request)
ClassMethod WriteWinOpenREST(req) As %String
{
  	if req.URL[(req.Application_"get-html")||(req.URL[(req.Application_"post-json")) { ;||(req.URL[(req.Application_"a")) { //is static content
  		q req.Application_"post-json"
  	} else {
  		q ""
  	}
}

/// Write Action Js 
/// w ##class(apptools.core.Action).WriteActJs(%request,pref_"MainForm",mhead,..%ClassName(1),pref_"FirstHead",key)
ClassMethod WriteAppAct(req, fornId, resultDivId, ns, classname, method, CGIVar = "") As %Status
{
  	;s $$$AppL("MML","%request-WriteActJs-")=$$$AppObJs(req)
  	set:CGIVar'["'" CGIVar=CGIVar_"'"
  	if req.URL[(req.Application_"get-html")||(req.URL[(req.Application_"post-json"))||(req.URL[(req.Application_"a")) { //is static content
  		q "AppRpc('"_fornId_"','"_resultDivId_"','"_ns_":"_classname_":"_method_":"_CGIVar_",'"_req.Application_"post-json');"
  	} else {
	  	q "AppAct('"_fornId_"','"_resultDivId_"','AppAct="_ns_":"_classname_":"_method_":"_CGIVar_");"
  		
  	}
	quit ""
}

/// Write Action Js 
/// w ##class(apptools.core.Action).WriteActJs(%request,pref_"MainForm",mhead,..%ClassName(1),pref_"FirstHead",key)
ClassMethod WriteActJs(req, fornId, resultDivId, classname, method, CGIVar = "", ns = {$namespace}) As %Status
{
  	;s $$$AppL("MML","%request-WriteActJs-")=$$$AppObJs(req)
  	set:CGIVar'["'" CGIVar=CGIVar_"'"
  	
  	quit:req.URL[".cls" "ActionJs('"_fornId_"','"_resultDivId_"','"_classname_"','"_method_"','"_CGIVar_");"
  	
  	if req.URL[(req.Application_"get-html")||
  		(req.URL[(req.Application_"post-json"))||
  		(req.URL[(req.Application_"a")) { //is static content
  		set:ns="" ns=$namespace
  		quit "AppRpc('"_fornId_"','"_resultDivId_"','"_ns_":"_classname_":"_method_":"_CGIVar_",'"_req.Application_"post-json');"
  	} else {
  		quit "ActionJs('"_fornId_"','"_resultDivId_"','"_classname_"','"_method_"','"_CGIVar_");"
  	}
	quit ""
}

/// Write Action Js 
/// w ##class(apptools.core.Action).GetElemParseForm(form,.Par,pref_"text")
ClassMethod GetElemParseForm(form, Par, divIdname, convert = 1, multi = "") As %Status
{
 if form'="" {
	set aray=[].$$$jsonFromJSON(form)
	for i=0:1:aray.$$$jsonSize()-1 {
		set item = aray.$$$jsonGet(i)
		if $isobject(item) {
			;s $$$AppL("MML","%request-GetElemForm-item")=$zconvert(item.value,"I","UTF8")
			set value=item.value
			if convert s value=$zconvert(item.value,"I","UTF8")
			;if item.name=divIdname set val=value
			if item.name'="" {
				set Par("%request.Data",item.name)=value
				if multi=item.name set multi(i)=value 
			}
		}
	}
 }
 quit $$$OK
}

/// Write Action Js 
/// w ##class(apptools.core.Action).GetElemForm(%request,.Par,pref_"text")
ClassMethod GetElemForm(req, Par, divIdname, ByRef multi = "") As %Status
{
  	;s $$$AppL("MML","%request-GetElemForm-")=$$$AppObJs(req)
	;s $$$AppL("MML","%request.Cont")=$$$AppObJs(req.Content)

  	if req.URL[(req.Application_"get-html")||(req.URL[(req.Application_"post-json")) {
  		if $isobject(req.Content) {
	  		set stream=req.Content
			set sc=##class(apptools.core.files).Stream2String(req.Content,.str)
			if 'sc quit sc
			;s ^tmpPar3(111)=str
			if $g(str)["{" {
				set form={}.$$$jsonFromJSON(str).params.form
   				;s $$$AppL("MML","%request-GetElemForm-aray")=form
				do ..GetElemParseForm(form,.Par,divIdname,,.multi)
			}
		 	;merge $$$AppL("MSW","Content")=str
  			;s val=req.Content.$$$jsonGet(name)
  		}
  	} else {	
  	}
	quit $g(Par("%request.Data",divIdname))
}

/// 
/// if ##class(apptools.core.Action).GetVarFromGN(gn,name,.val) zw val
ClassMethod GetVarFromGN(gn, name, ByRef val) As %Status
{
  if '$d(@gn@(name)) quit $$$ERROR($$$GeneralError,"Not found")
  MERGE val=@gn@(name)
  ;w "GetVarFromGN "_$zr_"="_$g(val)
  quit $$$OK
}

/// 
/// do ##class(apptools.core.Action).SetVarFromGN(gn,name,.val) zw val
ClassMethod SetVarFromGN(gn, name, ByRef val) As %Status
{
	KILL @gn@(name)
	MERGE @gn@(name)=val
   ;w "SetVarFromGN "_$zr_"="_$g(val)
  	quit $$$OK
}

}

