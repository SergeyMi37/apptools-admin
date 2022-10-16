Include apptools.core

/// JSON utility
Class apptools.core.json [ Abstract ]
{

/// Clobals ------------------------------------------------------------------------------
/// set change("Name")="read" 
/// do ##class(apptools.core.json).ImportGlobals("/tmp/glob.json",.json,.change)
ClassMethod ImportGlobals(filename = "", ByRef json, ByRef change, Filtr = "") As %Status
{
	set st=$$$OK
	Set json=##class(%Library.DynamicAbstractObject).%FromJSON(filename)
	set (orig,gn)=json.Globalname
	if $d(change) { 
		if $d(change("Name"),data) {
  			if data="copy" set gn=gn_"copy"
  			if data="read" write !,"Change the name of the global <"_gn_"> " read r set gn=$s(r="":gn,1:r)
		}
	}
	set AbstractObject=json.Instances
	;write !,gn
	set iter = AbstractObject.%GetIterator()
	   while iter.%GetNext(.key, .obj, .typeArray ) {
	      ;write "key = "_key_", obj = "_obj_", type = "_typeArray,! write $$Do^ZPretty(obj)
		set st=..ImportNodeRestore(obj, gn, orig,Filtr)
	}
	quit st
}

ClassMethod ImportNodeRestore(obj, gn, orig, Filtr = "", ByRef outvalue) As %Status
{

	set st=$$$OK
	set node=obj.%Get("_n")
	set value=obj.%Get("_v")
	if $e(node,1)="^" set node=$replace(node,orig,gn)
	if $e(node,1)="(" set node=gn_node
	if value'="""""",$e(value,1,3)'="$lb" set value=$c(34)_$replace(value,$c(34),$c(34,34))_$c(34)
	;write !,node_" = "_value
	;if Filtr'=""
	try {
		x "set "_node_"="_value
		set outvalue=@$zr
	} catch ex { 
		set st=ex.AsStatus()
	}
	quit st
}

/// todo set Filtr="%gn[""install""&&(@%gn'[""ERROR"")" ; 
/// do ##class(apptools.core.json).ExportGlobals("^ZPM.Dev.ModuleD","/tmp/zpm-glob.json",.json, $Get(Filtr)) write ##class(apptools.core.json).Pretty(json)
ClassMethod ExportGlobals(gn, filename = "", ByRef json, Filtr = "", erros) As %Status
{
	set (igg,ig)=gn
	set st=$$$OK
	set count=0,test=0,erros=0
	Set jsonarray=##class(%DynamicArray).%New()
	#; The first line
	if ig'="",$g(@ig)'="" set st=..GlobalsNode(ig,@ig,.count,.jsonitem,ig) do:$isobject(jsonitem) jsonarray.%Push(jsonitem) set:'st erros=erros+1
	// For local interest arrays viewing - direct
	for { set ig=$q(@ig) 
		quit:ig=""||(ig'[$e(igg,1,*-1))
		if $g(Filtr)'="" continue:$$ExpTestFiltr(ig,Filtr)
		set node=$e($p(ig,$e(igg,1,*-1),2),2,*)
		set st=..GlobalsNode(node,@ig,.count,.jsonitem,ig)
		set:'st erros=erros+1
		do:$isobject(jsonitem) jsonarray.%Push(jsonitem)
		;Quit:count>MaxNode
	}
	Set json=##class(%DynamicObject).%New()
	do json.%Set("Globalname",gn) 
	do json.%Set("Version",$zv)
	do json.%Set("Namespace",$namespace)
	do json.%Set("Instances",jsonarray)
	;w json
	if filename'="" do json.%ToJSON(filename)
	if erros quit $$$ERROR($$$GeneralError,"Found possible errors while restoring: "_erros)
	quit $$$OK
	##; Filter conditions on a node and values
ExpTestFiltr(%gn,Filtr) set %test=0
	xecute "i '("_Filtr_") set %test=$t"   
 	quit %test
}

/// Set the global node to json
ClassMethod GlobalsNode(node As %String = "", val As %String = "", ByRef count, ByRef js, gn) As %Status
{
	set js=##class(%DynamicObject).%New()
	set valorig=val
	set:$lv(val) val=##class(%Global).Quote(val)
	;write !,node_"="_val
	set count=count+1
	do js.%Set("_n",node)
	do js.%Set("_v",val) 
	;tested for restore
	set st=..ImportNodeRestore(js, "^||rest", "^||rest",,.outval)
	if $g(outval)'=valorig w !,"Errors possible restore "_node_" = "_val
	quit $$$OK
}

/// Class  ------------------------------------------------------------------------------------------------
/// write ##class(apptools.core.json).ExportClassInstances("%Library.SQLConnection","select * FROM %Library.sys_SQLConnection WHERE (1=1)","/tmp/gateways.json")
/// write ##class(apptools.core.json).ExportClassInstances("Security.Users","select * from Security.Users where Enabled['1'","/tmp/users.json",.js) write ##class(apptools.core.json).Pretty(js)
ClassMethod ExportClassInstances(class, sql = "", filename = "", ByRef json, exec = "", JsonAsString = 0) As %Status
{
	set st=$$$OK
	new %appTemp,%appObj,%appClass,%appClassProp,%appClassPropVal,%appClassPropType,%appClassSave,%appClassPropSet
	do ##class(apptools.core.LogInfoPane).GetClassDef(class,,.classdef,0,"1001")
	set stn=$O(classdef("Storages",""))
	set gn=$GET(classdef("Storages",stn,"DataLocation"))
	if $E(gn,1)'="^",$E(class,1)="^" set gn=class
	
	Set jsonarray=##class(%DynamicArray).%New()
	if sql'="" {
		set myQuery = ##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
		set st=myQuery.Prepare(sql)
		if 'st quit st
		set st=myQuery.Execute()
		if 'st quit st
		set ColCount=myQuery.GetColumnCount()
		while (myQuery.Next()) {
			set id=myQuery.Get("ID")
   			set %appClassSave=1
			do ..GetOneObject(class,id,.classdef,.jsonitem,$g(exec))
			if $G(%appClassSave),$isobject(jsonitem) do jsonarray.%Push(jsonitem)
		}
	}
	Set json=##class(%DynamicObject).%New()
	do json.%Set("Classname",class) 
	do json.%Set("StorageDataLocation",gn) 
	do:sql'="" json.%Set("Sql",sql)
	do json.%Set("Version",$zv)
	do json.%Set("Namespace",$namespace)
	do json.%Set("Instances",jsonarray)
	if filename'="" {
		if 'JsonAsString {
			do json.%ToJSON(filename)
		}
		else {
			set str=##class(apptools.core.json).Pretty(json)
			set stream = ##class(%Stream.TmpCharacter).%New()
			do stream.Write(str)
			s File = ##class(%Stream.FileCharacter).%New()
			s File.TranslateTable="UTF8"
			s File.Filename=filename
			s st=File.CopyFromAndSave(stream)
			quit st
		}
	}
	;write source
	quit $$$OK
}

ClassMethod GetOneObject(class, id, ByRef cls, ByRef json, exec = "") As %Status
{
	s ob=$classmethod(class,"%OpenId",id)
	quit:'$isobject(ob) $$$ERROR($$$GeneralError,"Error Object")
	set prop=""
   	set %appClass=class
   	set %appObj=ob
	Set json=##class(%DynamicObject).%New()
	for i=1:1 { set prop=$order(cls("Properties",prop)) quit:prop=""
		try {
			set val=$property(ob,prop)
	   		set %appClassProp=prop
	   		set %appClassPropVal=val
	   		set %appClassPropType=$G(cls("Properties",prop,"Type"))
	   		set %appClassPropSet=1
      		if $G(exec)'="" { 
				xecute "do "_exec
      		}
      		if $g(%appClassPropSet) {
				if '$isobject(%appClassPropVal)	do json.%Set(%appClassProp,%appClassPropVal)
				else  set jsobj=..GetJSONObject(%appClassPropVal) do json.%Set(%appClassProp,jsobj)
      		}
		}
		catch e {}
	}
	quit $$$OK
}

ClassMethod GetJSONObject(oid) As %Status
{
	quit:'$isobject(oid) ""
	set class=oid.%ClassName(1)
	do ##class(apptools.core.LogInfoPane).GetClassDef(class,,.classdef,0,"1")
	set prop=""
	Set json=##class(%DynamicObject).%New()
	do json.%Set("_class",class)
	try {do json.%Set("_id",oid.%Id())} catch e {}
	for i=1:1 { set prop=$order(classdef("Properties",prop)) quit:prop=""
		try {
			set val=$property(oid,prop)
			if '$isobject(val)	do json.%Set(prop,val)
			else  set jsobj=..GetJSONObject(val) do json.%Set(prop,jsobj)
		}
		catch e {}
	}
	quit json
}

/// !!!set change("Name")="read" write ##class(apptools.core.json).ImportClassInstances("/tmp/gateways.json",.js,.change)
/// write ##class(apptools.core.json).ImportClassInstances("/tmp/users.json",.js) write ##class(apptools.core.json).Pretty(js) //write $$Do^ZPretty(js) //install pretty-json
ClassMethod ImportClassInstances(filename = "", ByRef json, ByRef change) As %Status
{
	set st=$$$OK
	Set json=##class(%Library.DynamicAbstractObject).%FromJSON(filename)
	set class=json.Classname
	set AbstractObject=json.Instances
	set iter = AbstractObject.%GetIterator()
	   while iter.%GetNext(.key, .obj, .typeArray ) {

	      if $isobject(obj) {
	      	set newobj=$classmethod(class,"%New")
	      	set oiter = obj.%GetIterator()
	   		while oiter.%GetNext(.propname, .propvalue, .typeObj ) {
	      		if $d(change) { 
	      			if $g(change("*"))="read" {
		      			do Change(propname,.propvalue)
	      			}
	      			elseif $d(change(propname),data) {
		      			if data="copy" set propvalue=propvalue_"_copy"
		      			if data="read" do Change(propname,.propvalue)
	      			}
	      		}
	      		if typeObj'="object" set $property(newobj,propname)=propvalue
	   		}
	   		set st=newobj.%Save()
	      }
	}
	quit st
Change(propname,propvalue)
		write !,"Change the value of a field '"_propname_"' <"_propvalue_"> " read r set propvalue=$s(r="":propvalue,1:r)
	quit
}

/// w ##class(apptools.core.json).WriteJSONFromSQL("select * FROM %Library.sys_SQLConnection WHERE Connection_Name='postgres'")
ClassMethod WriteJSONFromSQL(sql As %String) As %Status
{
	#dim sc As %Status = $$$OK
	set provider = ##class(%ZEN.Auxiliary.altJSONSQLProvider).%New()
	set provider.maxRows = $$$MaxCacheInt
	set provider.%Format = $$$formatJSONSQL
	set provider.sql = sql
	if $isobject($g(%request)) {
		set provider.pageSize = %request.Get("size", 25)
		set provider.currPage = %request.Get("page", 1)
	}
	set sc = provider.%DrawJSON()
	return sc
}

/// From https://github.com/isc-at/ZPretty Author Robert Cemper
/// write $$Do^ZPretty(js) /// zpm "install pretty-json"
/// write ##class(apptools.core.json).Pretty("{""key"":123,""key2"":321}")
ClassMethod Pretty(input, fil, nl) As %String
{
#;ZPretty ; make JSON readable
#; input= JSON string | stream | %DynamicAbstractObject
#; indent filler  ; "" => no indent         
#define fill "  "
#; New line code   ; "" => no Lines
#define crlf $c(13,10)
 S fil=$g(fil,$$$fill),nl=$g(nl,$$$crlf), sc=1,res="",indt=""
 I $iso(input),input.%IsA("%Library.DynamicAbstractObject") S obj=input
 E  S obj=##class(%Library.DynamicAbstractObject).%FromJSON(input)
 S stc=0,ito=obj.%GetIterator(),sep=""
    ,jtyp=$s(obj.%IsA("%Library.DynamicObject"):"object",1:"array")
    ,ist(stc)=ito, cst(stc)=obj, tst(stc)=jtyp
 I $i(stc)
 S res=res_$s(jtyp="object":"{",1:"["), indt=indt_fil
 F { S isito=ito.%IsA("%Iterator.Object")
    I ito.%GetNext(.key,.val) {
        S jtyp=$CASE(obj.%GetTypeCodeOf(key),0:"null"
                        ,1:"boolean",2:"boolean",3:"number",4:"number"
                        ,6:"array",7:"object",8:"string",9:"number"
                        ,10:"illegalvalue"
                        ,11:"number",12:"oref",13:"unassigned"
                        ,14:"number",15:"number",16:"string"
                        ,18:"number",19:"number",20:"string"
                        ,31:"unassigned",:"UNKNOWN")
        S res=res_sep_nl_indt, sep="," }
	Else {
        S indt=$e(indt,1,*-$l(nl)), res=res_nl_indt, res=res_$s(isito:"}",1:"]")
        Q:'$i(stc,-1)
        S ito=ist(stc), obj=cst(stc), jtyp=tst(stc), sep=","
        Continue }
    I isito S res=res_""""_key_""":"
    I (jtyp="object") || (jtyp="array") {
        S ist(stc)=ito, cst(stc)=obj, tst(stc)=jtyp, sep=""
        I $i(stc)
        S ito=val.%GetIterator(),obj=val, indt=indt_fil
        	,res=res_$s(jtyp="object":"{",1:"[")
    } ElseIf jtyp="string" { S res=res_""""_$zcvt(val,"O","JSON")_""""
    } ElseIf jtyp="boolean" { S res=res_$s(val:"true",1:"false")
    } ElseIf jtyp="null" { S res=res_"null"
    } Else { I $e(val)="." S val="0"_val
        I $e(val,1,2)="-." S val="-0."_$e(val,3,*)
        S res=res_val } }
 Quit res
}

}

