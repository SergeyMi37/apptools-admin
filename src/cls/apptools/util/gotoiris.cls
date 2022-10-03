Include apptools.core

/// Adaption to IRIS
Class apptools.util.gotoiris [ Abstract ]
{

/// d ##class(apptools.util.gotoiris).CompNS(ns)
ClassMethod compile(Class As %String = "", package As %String = "") As %Status
{
 q $$$OK
 s ^%qCacheObjectSys("strictchecking")=0
 k er d $system.OBJ.CompileAll("cfk-u-d",.er) zw er
 ;CompileAllNamespaces
 ;d $system.OBJ.CompileAllNamespaces()
 ;d $system.OBJ.CompilePackage(package,"cdfk-u")
 
 ;w $$defdir^%SYS.GLO($namespace) ;w $zu(12,"")

 ;zn "%SYS"
 ;d ##class(Config.CPF).PendingRestart(.r)
 ;d ##class(Config.CPF).Validate()
 ;d ##class(Config.CPF).Activate()
 ;zw ^SYS("CONFIG") ;Config.CPF
 ;^%SYS
 ;zw ^SYS("Security") - all users, privileges, roles, resources and applications
}

/// When going from Ensemble to IRIS
/// zn "app" w !,$System.Status.GetErrorText(##class(apptools.core.sys).DismountListDB("AAA"))
/// d ##class(apptools.util.gotoiris).RenameDB4IRIS("/opt2/isc/iris/mgr/AAA/")
/// zn "app" w !,$System.Status.GetErrorText(##class(apptools.core.sys).MountListDB("AAA"))
ClassMethod RenameDB4IRIS(dir) As %Status
{
	do ##class(apptools.core.files).GetAllDir(dir,,.L)
	set i=""
	for  { set i=$o(L(i)) quit:i=""
		set file=$lg(L(i),1)
		w !,file
		if $p(file,$$$slash,*)="CACHE.DAT" {
			s newfile=$replace(file,"CACHE","IRIS")
			If ##class(%File).Rename(file,newfile) w !,"renamed ",newfile
		}
		elseif $p(file,$$$slash,*)="cache.lck" {
			If ##class(%File).Delete(file) w !,"removed "_file
		}
	}
}

/// Recompilation to IRIS namespace
/// d ##class(apptools.util.gotoiris).CompNS("AAA")
ClassMethod CompNS(ns) As %Status
{
	zn ns
	d ##class(%EnsembleMgr).EnableNamespace(ns,1)
	w !,"Compilation started, please wait..."
	k err d $system.OBJ.CompileAll("cfk-u-d",.err) zw err
	q $$$OK
}

/// IRIS area processing package after copying the database from Ensemble
/// d ##class(apptools.util.gotoiris).RecovNS("AAA")
ClassMethod RecovNS(ns) As %Status
{
	set st=##class(apptools.core.sys).DismountListDB(ns)
	if st {
		d ##class(apptools.util.gotoiris).RenameDB4IRIS("/opt/isc/iris/mgr/"_ns_"/")
		set st=##class(apptools.core.sys).MountListDB(ns)
		if st {
			d ##class(apptools.util.gotoiris).CompNS(ns)
		} else {
			w !,$System.Status.GetErrorText(st)
		}
	} else {
		w !,$System.Status.GetErrorText(st)
	}
}

}

