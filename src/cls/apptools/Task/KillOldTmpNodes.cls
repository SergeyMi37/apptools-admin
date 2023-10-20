/// Task Kill Old TmpNodes - Regular cleaning of temporary globals
Class apptools.Task.KillOldTmpNodes Extends %SYS.Task.Definition
{

/// Globals for cleaning Possible Separated by commas
Property GlobalNameTmp As %String(MAXLEN = "") [ InitialExpression = "^tmpLog" ];

/// how many days to leave ?
Property LastDays As %String(MAXLEN = "") [ InitialExpression = "2" ];

Method OnTask() As %Status
{
	s st=$$$OK 
	set gns=..GlobalNameTmp
	for i=1:1:$l(gns,",") {
		if $p(gns,",",i)="" continue
		set gn=$p(gns,",",i)
		do ##class(apptools.Task.KillOldTmpNodes).KillOldNodes(..LastDays,gn)	
	}
    q st
}

/// do ##class(apptools.Task.KillOldTmpNodes).KillOldNodes(2,"^tmpLogInfo")
ClassMethod KillOldNodes(day = 2, gn = "^tmpSPGZ", write = 0) As %String
{
	do DISABLE^%NOJRN
	set curday=+$h
	do chekkill(gn)
	set u1="" 
	for { set u1=$Order(@gn@(u1)) quit:u1=""
		do chekkill($na(@gn@(u1)))
		set u2=""
		for { set u2=$Order(@gn@(u1,u2)) quit:u2=""
		 do chekkill($na(@gn@(u1,u2)))
		}
	}
	do ENABLE^%NOJRN	
	quit "kill="_$g(kill)_", nokill="_$g(nokill)
chekkill(gname)
			if $Data(@gname@(-3,"timestamp"),ts) {
				set hor=$listget(ts,1)
				if hor[" " set d=+$zdh($p($listget(ts,1)," "),3)
				else  set d=hor
				if (curday-d)>day {
					write:write !,"удаляем "_gname
					KILL @gname
					if $i(kill)
				}
				else {
					write:write !,"оставляем "_gname
					if $i(nokill)
				}
			}

 quit $$$OK
}

}

