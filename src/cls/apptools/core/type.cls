Include apptools.core

/// Utility types
Class apptools.core.type [ Abstract, DependsOn = apptools.core.msg ]
{

/// To return the date in the format 3 
/// apptools.core.type_Date3(DateFrom)
ClassMethod Date3(h As %String) As %String [ SqlProc ]
{
	return $zd(h,3)
}

/// To count the number of seconds to YYYY-MM-DD HH:MM:SS or the $HOROLOG
/// w ##class(apptools.core.type).GetYYYYMM("2018-07-06 08:14:47",-1)
/// w ##class(apptools.core.type).GetYYYYMM($h,-1)
ClassMethod GetYYYYMM(h, plusMM = 0) As %String
{
	i h["-" s h=..GetHorYYYYMMDD(h)
	s MM=$p($zd(+h,3),"-",2)+plusMM,YYYY=$p($zd(+h,3),"-",1)
	i MM<1 s MM=12+MM,YYYY=YYYY-1 ;running for less than 12 plusMM
	i MM>12 s MM=MM-12,YYYY=YYYY+1
	i $l(MM)=1 s MM="0"_MM
	q YYYY_"-"_MM
}

/// To count the number of seconds to YYYY-MM-DD HH:MM:SS or the $HOROLOG
/// w ##class(apptools.core.type).GetCountSec("2018-07-06 08:14:47")
/// w ##class(apptools.core.type).GetCountSec($h)
ClassMethod GetCountSec(h) As %String
{
	i h["-" s h=..GetHorYYYYMMDD(h)
	i h'["," q ""
	q $p(h,",",1)*86400+$p(h,",",2)
}

/// w ##class(apptools.core.type).GetTextMonth("05")
ClassMethod GetTextMonth(mm) As %String
{
	q $s(+mm="1":$$$aText("January",""),+mm="2":$$$aText("February",""),+mm="3":$$$aText("March",""),+mm="4":$$$aText("April",""),+mm="5":$$$aText("may",""),+mm="6":$$$aText("June",""),+mm="7":$$$aText("July",""),+mm="8":$$$aText("August",""),+mm="9":$$$aText("September",""),+mm="10":$$$aText("October",""),+mm="11":$$$aText("November",""),1:$$$aText("December",""))
}

/// To month
/// w ##class(apptools.core.type).GetMonth($h)
ClassMethod GetMonth(h) As %String
{
	q $p($zd(h,3),"-",2)
}

/// Translate YYYY-MM-DD HH:MM:SS in $HOROLOG
/// write ##class(apptools.core.type).GetHorYYYYMMDD("2018-07-06 08:14:47")
/// write ##class(apptools.core.type).GetHorYYYYMMDD("06.07.2018 08:14:47")
ClassMethod GetHorYYYYMMDD(dt) As %String
{
	try{ 
		s d=$p(dt," ")
		set:d["." d=$p(d,".",3)_"-"_$p(d,".",2)_"-"_$p(d,".",1)
		s d=$zdh($p(d," "),3)
		;s c=$zth($p(dt," ",2),1)
		set c=$s($p(dt," ",2)="":0,1:$zth($p(dt," ",2),1))
		s res=d_","_c
	}
	catch e { s res="" }
	q $g(res)
}

/// Translate DD.MM.YYYY in $HOROLOG
/// write ##class(apptools.core.type).GetHorDDMMYYYY("06.07.2018 08:14:47")
/// write ##class(apptools.core.type).GetHorDDMMYYYY("2018-07-06 08:14:47")
/// write ##class(apptools.core.type).GetHorDDMMYYYY("23/05/2023 08:14:47")
ClassMethod GetHorDDMMYYYY(dt) As %String
{
	try{ 
		set c=$s($p(dt," ",2)="":0,1:$zth($p(dt," ",2),1))
		set d=$p(dt," ")
		if d["." {set dt=$p(d,".",3)_"-"_$p(d,".",2)_"-"_$p(d,".",1)
		}
		elseif d["/" {set dt=$p(d,"/",3)_"-"_$p(d,"/",2)_"-"_$p(d,"/",1)
		}
		set d=$zdh($p(dt," "),3)
		set res=d_","_c
	}
	catch e { s res="" }
	q $g(res)
}

/// To check the validity and display the date
/// w ##class(apptools.core.type).GetValidZD(+$h)
ClassMethod GetValidZD(hr) As %String
{
	try{ s res=$tr($zd(hr,4),"/",".") }
	catch e { s res="" }
	q res
}

/// To year format 2018
/// w ##class(apptools.core.type).GetYear($h)
ClassMethod GetYear(h) As %String
{
	q $p($zd(h,3),"-",1)
}

/// To get a date in the format 2018-04-03T16:40:30
/// w ##class(apptools.core.type).GetDateTime($h)
ClassMethod GetDateTime(h, delim = "T") As %String
{
	try {
		set ret=$zd(h,3)_delim_##class(apptools.core.type).GetValidZT(h)
	} catch e {}
	quit $g(ret)
}

/// To check the validity and display the time
/// w ##class(apptools.core.type).GetValidZT($h)
ClassMethod GetValidZT(hr) As %String
{
	try{ s res=$zt(+$p(hr,",",2),1) }
	catch e { s res="" }
	q res
}

/// Translate the date to the format DD.MM.YY
/// w ##class(apptools.core.type).getDDMMYY("2016-05-05")
ClassMethod getDDMMYY(pStringDate As %String) As %String
{
	try {
		i pStringDate?1n.n s pStringDate=$zd(pStringDate,3)
		i pStringDate["." s date=pStringDate s:$p(date,".",3)?4n date=$p(date,".",1,2)_"."_$e($p(date,".",3),3,4)
		i pStringDate["-" s date=$p(pStringDate,"-",3)_"."_$p(pStringDate,"-",2)_"."_$e($p(pStringDate,"-",1),3,4)
		i pStringDate["/" s date=$p(pStringDate,"/",2)_"."_$p(pStringDate,"/",1)_"."_$e($p(pStringDate,"/",3),3,4)
	} catch e {}
	q $g(date)
}

/// Translate the date to the format DD.MM.YYYY
/// w ##class(apptools.core.type).getDDMMYYYY("2016-05-05")
ClassMethod getDDMMYYYY(pStringDate As %String) As %String
{
	try {
		i pStringDate?1n.n s pStringDate=$zd(pStringDate,3)
		i pStringDate["." s date=pStringDate
		i pStringDate["-" s date=$p(pStringDate,"-",3)_"."_$p(pStringDate,"-",2)_"."_$p(pStringDate,"-",1)
		i pStringDate["/" s date=$p(pStringDate,"/",2)_"."_$p(pStringDate,"/",1)_"."_$p(pStringDate,"/",3)
	} catch e {}
	q $g(date)
}

/// Translate the date to the format YYYY-MM-DD FORMAT=3 passing a formula of the type "CurrentDay+1"
/// w ##class(apptools.core.type).GetInpretDate("CurrentDay+1","12:00")
ClassMethod GetInpretDate(pStringDate As %String, time = "") As %String
{
	try {
		i pStringDate["CurrentDay" s pStringDate=$replace(pStringDate,"CurrentDay","$h")
		i pStringDate["$h"||(pStringDate["$H") {
			s %Date=""
			x "s %Date="_pStringDate
			s pStringDate=%Date
		}
		i pStringDate?1n.n s date=$zd(pStringDate,3) q
		i pStringDate["." s date=$p(pStringDate,".",3)_"-"_$p(pStringDate,".",2)_"-"_$p(pStringDate,".",1)
		i pStringDate["-" s date=pStringDate q
		i pStringDate["/" s date=..AddZerro($p(pStringDate,"/",3))_"-"_..AddZerro($p(pStringDate,"/",1))_"-"_..AddZerro($p(pStringDate,"/",2))
	} catch e {}
	q $g(date)_$s($g(date)'=""&&(time'=""):" "_time,1:"")
}

/// Translate the date to the format YYYY-MM-DD FORMAT=3
/// w ##class(apptools.core.type).getYYYYMMDD(+$h)
ClassMethod getYYYYMMDD(pStringDate As %String) As %String
{
	try {
		i pStringDate?1n.n s date=$zd(pStringDate,3) q
		i pStringDate["." s date=$p(pStringDate,".",3)_"-"_$p(pStringDate,".",2)_"-"_$p(pStringDate,".",1)
		i pStringDate["-" s date=pStringDate q
		i pStringDate["/" s date=..AddZerro($p(pStringDate,"/",3))_"-"_..AddZerro($p(pStringDate,"/",1))_"-"_..AddZerro($p(pStringDate,"/",2))
	} catch e {}
	q $g(date)
}

ClassMethod AddZerro(m As %String) As %String
{
	if $l(m)=1 q "0"_m
	q m
}

/// Interpreterpath string with the current date type
/// Str= DateFrom=(CurrentDay-2)&DateTo=(CurrentDay-1)
/// The result of the computed expression value "added?DateFrom=06.06.2018&DateTo=07.06.2018"
/// w ##class(apptools.core.type).InterpretCurrentDay("added?DateFrom=(CurrentDay-2)&DateTo=(CurrentDay-1)",.res)
ClassMethod InterpretCurrentDay(Str As %String, Result As %String) As %Status
{
	#dim tSC As %Status = $$$OK
	#dim e As %Exception.AbstractException
	
	s exp=$p(Str,"?",2)
	q:exp="" "0"
	s exp="s "_$replace(exp,"CurrentDay",+$h)
	s exp=$replace(exp,"&DateTo",",%tempTo")
	s exp=$replace(exp,"DateFrom","%tempFrom")
	try {
		x exp
		s Result=$p(Str,"?",1)_"?DateFrom="_$tr($zd(%tempFrom,4),"/",".")_"&DateTo="_$tr($zd(%tempTo,4),"/",".")
		k %tempFrom,%tempTo
	} Catch e {
		Set tSC=e.AsStatus()
	}
	q tSC
}

/// Parse a string of CGI variable 
/// w ##class(apptools.core.type).ParseURL("aaa=111&bbb=222")
ClassMethod ParseURL(str As %String, ByRef out, del = "&") As %Status
{
	f i=1:1:$l(str,del) {
		continue:$p(str,del,i)=""
		continue:$p($p(str,del,i),"=")=""
		s out($p($p(str,del,i),"="))=$p($p(str,del,i),"=",2,*)
	}
}

/// Output the js code to select a file in a new window and download it to the server
/// ##class(apptools.core.type).UploadFilesJS(%id)
ClassMethod UploadFilesJS(id, %id) As %Status
{
	s onclick="win=window.open('apptools.core.UploadCSP.cls?idreturn="_id_"&ServerDirPath="_$zconvert($g(%id("filesStore")),"O","URL")_"', 'winupload', 'location=no,left=200,top=300,width=800,height=300,scrollbars=no,status=no,toolbar=no,menubar=no');"
	q $$$appButton("appButtonUpload"_id,"onclick="""_$g(onclick)_"""",$$$aText("Download file",""))
}

/// To obtain the table name from the Class
/// w ##class(apptools.core.type).GetTableName("apptools.sss.user")
ClassMethod GetTableName(SelectClass) As %String
{
	set (tab,table)=$p(SelectClass,".",*)
	//If the table name is the key words, frame it in quotation marks
	set:$SYSTEM.SQL.IsReservedWord(table) table = """"_table_""""
	set tab=$tr($p(SelectClass,"."_tab,1,*-1),".","_")_"."_table
	q tab
}

/// The number to the normal mind
/// w ##class(apptools.core.type).GetValidNumeric("14,650.00")
ClassMethod GetValidNumeric(price) As %String
{
	i price[","&&(price[".") s price=$tr(price,",")
	i price["," s price=$tr(price,",",".")
	q $tr(price," "_$c(160)) ;remove the spaces
}

/// Digit combining enclosing keycap ;https://apps.timwhitlock.info/emoji/tables/unicode
/// w ##class(apptools.core.type).UD("45")
ClassMethod UD(num) As %String
{
	set ret=""
	for i=1:1 quit:$e(num,i)=""  set ret=ret_$wc($zhex("003"_(+$e(num,i))))_$wc($zhex("20E3"))
	quit ret
}

/// w ##class(apptools.core.type).TagPre("va")
ClassMethod TagPre(val = "") As %String
{
	quit "write ""<pre> "" "_val
}

}

