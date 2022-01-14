Include apptools.core

Class apptools.Chart.ChartPanel Extends apptools.core.LogInfoPane
{

Parameter XMLTYPE = "apptools.Chart.ChartPanel";

/// Drawing graphs
Method DrawBODY(pInstance As PageInstance) As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
 	quit ..Drawcanvas(.pInstance)
}

ClassMethod Drawcanvas(pInstance = "") As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
 	write ##class(apptools.core.LogInfoPane).AddJsScripts("chart")
	set $ZT="errors"
	;set nsp=%request.Get("NSP")
	set nsp=##class(apptools.core.Action).GetParam(.%request,"NSP",pInstance)
	if nsp'="" try {zn nsp set NSpace=nsp } catch e {}
	set NSpace=$zu(5)

	set arg("header")="Error"
	set arg("labels")="[""Error""]"
	set arg("type")="bar" ;line
	set arg("datasets")="{   label: """_$$$aText("Error display on the graph","")_""", borderColor: 'rgb(255, 199, 132)',  data: [30],  }"

	set days=365 ;1000
	;if %request.Get("days") S days=%request.Get("days")
	set days=##class(apptools.core.Action).GetParam(.%request,"days",pInstance)
	set panel=##class(apptools.core.Action).GetParam(.%request,"panel",pInstance)
	if panel'="" {
		set class=$p($p(panel,"(",2),")"),method=$p($p(panel,")",2),".",2)
		set st=$classmethod(class,method,.arg,days)
	}
	set ChartId="Chart"_($p($h,",",2))
	&html< <canvas id='#(ChartId)#' style="background:white" ></canvas>
	>
	$$$jsstart
 	write "var ctx = document.getElementById('"_ChartId_"').getContext('2d');"
 	write "var chart = new Chart(ctx, {   type: '"_$g(arg("type"),"bar")_"',"
    // The data for our dataset
    write "data: {  labels: "_$g(arg("labels"))_","   // ["January", "February", "March", "April", "May", "June", "July"],
    write "   datasets: ["_$g(arg("datasets"))
    write " ] },  options: {    hover: { mode: 'index' }, tooltips: { mode: 'index' }	, title: { display: true, text: '"_$tr($g(arg("header")),"'""")_"'  }    } });"
	$$$jsstop
	quit $$$OK
errors
 	write !,$ze
 	quit $$$OK
}


/// d ##class(apptools.Chart.ChartPanel).ColorRGBa(32,0.2)
ClassMethod ColorRGBa(num, alfa = 1)
{
 
	set c=$e(+num,*)
	;i +num>9 
	;the same light alfa=1 because the opacity: 100% *
	if c=0 quit "rgba(255, 0, 0, "_alfa_")" ;pure red
	if c=1 quit "rgba(255, 99, 132, "_alfa_")" ;red
    if c=2 quit "rgba(255, 159, 64, "_alfa_")" ;orange
    if c=3 quit "rgba(255, 206, 86, "_alfa_")" ;yellow
    if c=4 quit "rgba(0, 255, 0, "_alfa_")" ;pure green
    if c=5 quit "rgba(75, 192, 192, "_alfa_")" ;green
    if c=6 quit "rgba(12, 164, 240, "_alfa_");" ;blue
    if c=7 quit "rgba(0, 0, 255, "_alfa_")" ;clear blue
    if c=8 quit "rgba(54, 162, 235, "_alfa_")" ;blue
    if c=9 quit "rgba(153, 102, 255, "_alfa_")" ;purple
}

/// Complete the chart objects
ClassMethod FinishArg(res, data, labels, arg)
{
	set datasets=""
	set a="" for num=1:1 { set a=$o(res(a)) quit:a=""
		set data(a)=$e(data(a),1,*-1)_"], }"
		set datasets=datasets_data(a)_","
	}
	set datasets=$e(datasets,1,*-1)
	set labels=$e(labels,1,*-1)_"]"
	set arg("datasets")=datasets
	set arg("labels")=labels
	quit 1
}

/// Dynamics of consumption of license on the basis of regular job 
/// with legacy method: s st=##class(apptools.core.sys).SaveQuery("%SYSTEM.License:Counts")
/// d ##class(apptools.Chart.ChartPanel).ChartLicUsed(.arg,1200,.res)
ClassMethod ChartLicUsed(arg, days, res, gn = "^%apptools.Task")
{
 set par=$p(days,",",2,999)
 set days=+days
 set ToDay=$zd($h,3),FromDay=$zd($h-days,3)
 set arg("header")=$$$aText("The dynamics of license spending based on a regular job in a date range ","")_FromDay_" - "_ToDay
 set arg("type")="line"
 set GN=$na(@gn@("%SYSTEM.License:Counts"))
 set dt=""
 for i=1:1:10 { set dt=$o(@GN@(dt),1) quit:dt=""
 	write !,dt," ",$g(@GN@(dt,4,2))
 }
}

/// Search in the Protocol cconsole.log important events
/// d ##class(apptools.Chart.ChartPanel).ChartAlert(.arg,1200,.res)
ClassMethod ChartAlert(arg, days, res, list, mm)
{
 	set method="class(apptools.core.files).Alert" 
	do ##class(apptools.core.files).FindContextInLog(days,method,.res) // to parse a Protocol to calculate important events
	set df=$p(res," ",1)
	set dt=$p(res," ",2)
	set arg("header")=$$$aText("Important system events in the date range ","")_df_" - "_dt
	set arg("type")="line"
	set labels="["
	for yyyy=$p(df,".",3):1:$p(dt,".",3) {
		for m=1:1:12 {
			if yyyy=$p(df,".",3),m<$p(df,".",2)  continue
			if yyyy=$p(dt,".",3),m>$p(dt,".",2)  continue
			if m?1n s mm="0"_m
			else  s mm=m
			set labels=labels_""""_##class(apptools.core.type).GetTextMonth(mm)_"."_yyyy_""","
			set a="" f num=1:1 { s a=$o(res(a)) q:a=""
				if '$d(color(a)) s color(a)=num
				if '$d(data(a)) s data(a)="{  label: """_a_""", borderColor: '"_..ColorRGBa(color(a),1)_"',  data: ["
				set data(a)=data(a)_+$g(res(a,yyyy,mm))_","
			}

		}
	}
 do ..FinishArg(.res, .data, .labels, .arg)
 quit $$$OK
}

/// Retrospective database sizes
/// d ##class(apptools.Chart.ChartPanel).ChartDbSize(.arg,1200,.res,.list,.mm)
ClassMethod ChartDbSize(arg, days, res, list, mm)
{
	set method="class(apptools.core.files).ExpansionDB" 
	do ##class(apptools.core.files).FindContextInLog(days,method,.res) //to disassemble the Protocol to calculate the monthly growth of the database in megabytes
	do ##class(apptools.core.rest).getDBsize("dbsize",.list) //to calculate the current database size in gigabytes
	//let's go back in time taking masany growth
	s df=$p(res," ",1)
	s dt=$p(res," ",2)
	s arg("header")=$$$aText("Dynamics of database growth in the date range ","")_df_" - "_dt
	s arg("type")="line"
	s labels="["
	s datasets="{  label: """_$$$aText("Error display on the graph","")_""", borderColor: '"_..ColorRGBa(0,1)_"',  data: [30],  }"
	s bd="",(max,free,maxbd)=0
	f num=1:1 { s bd=$o(list(bd)) q:bd=""  
		s list(bd)=list(bd)*1024
		i list(bd)>max s max=list(bd),free=list(bd,"free")*1024,maxbd=list(bd,"name")
		s order(list(bd))=bd //Rangiroa size
		s color(bd)=num
	}
	s list("free","name")="Disk Free Size + "_$g(maxbd)
	s list("free")=max+free
	s order(max+free)="free"
	s color("free")=0
	;zw order	zw list
	//translate into megabytes
	s mm=$p(dt,".",2)
	f yyyy=$p(dt,".",3):-1:$p(df,".",3) {
		for {
			i mm?1n s mm="0"_mm
			;w !,yyyy,"-",mm
			s bd=""	f { s bd=$o(list(bd)) q:bd=""   continue:bd="total"
				s mm(yyyy,mm,bd)=list(bd) ;,1,2) ;the current size of the gig
				i $d(res(bd,yyyy,mm)) {
					s list(bd)=list(bd)-($g(res(bd,yyyy,mm))) //subtract monthly increase in moving Gigi
					i list(bd)<0 s list(bd)=0
				}
			}
			s mm=mm-1
			i mm<1 s mm=12 q
			i yyyy=$p(df,".",3),mm<$p(df,".",2) q

		}
	}
	s yyyy="" f { s yyyy=$o(mm(yyyy)) q:yyyy=""
		f mon=1:1:12 { 
			s mm=mon i mm?1n s mm="0"_mm
			continue:'$d(mm(yyyy,mm))
			s labels=labels_""""_##class(apptools.core.type).GetTextMonth(mm)_"."_yyyy_""","
			s bd2="" f { s bd2=$o(order(bd2),-1,bd) q:bd2=""
				i '$d(data(bd)) s data(bd)="{  label: """_list(bd,"name")_""", borderColor: '"_..ColorRGBa(color(bd),1)_"',  data: ["
				s data(bd)=data(bd)_$g(mm(yyyy,mm,bd))_","
			}
		}
	}
	s datasets=""
	s bd2="" f { s bd2=$o(order(bd2),-1,bd) q:bd2=""
		s data(bd)=$e(data(bd),1,*-1)_"], }"
		s datasets=datasets_data(bd)_","
	}
	s datasets=$e(datasets,1,*-1)
	s labels=$e(labels,1,*-1)_"]"
	s arg("datasets")=datasets
	s arg("labels")=labels
	q 1
}

/// Plot the error of the ensemble Protocol Ens_Util.Log where Type='2' 
ClassMethod ChartEnsUtilLog(arg, days, res, list)
{
 s ns=$p(days,",",2,999)
 s days=+days
 s ToDay=$zd($h,3),FromDay=$zd($h-days,3)
 s sql="select Convert(VarChar,TimeLogged, 103) as days,count(*) as erro from Ens_Util.Log where Type='2' and TimeLogged>'"_FromDay_"' and TimeLogged<'"_ToDay_"' and (Text not like '%ErrFTP%' and Text not like '%"_$$$aText("Not implemented","")_"%' and text not like '%"_$$$aText("The key is not defined uniquely","")_"%' and text not like '%Could not get%') group by Convert(VarChar,TimeLogged, 103)"
 f i=1:1:$l(ns,",") {
	 s nspace=$p(ns,",",i)
	 continue:nspace=""
	 $$$NspGoto(curNs,nspace)
	 i nspace=$zu(5) {
		s gn="^||tmpCount" ;_$tr(nspace,"-")
		;w "<br>"_gn
		s res(nspace)=""
		d ##class(apptools.core.sys).SaveSQL(sql,gn)
		f ii=1:1 {  q:'$d(@gn@(ii))
			s count=+$lg($g(@gn@(ii)),2)
			s dat=$lg($g(@gn@(ii)),1)
			s dd=$p(dat,"/",1),mm=$p(dat,"/",2)
			s res(nspace,$p(dat,"/",3)_"-"_mm_"-"_dd)=count
		}
	 }
	 $$$NspReturn(curNs)
 }
 s arg("header")=$$$aText("Number of Ens_Util errors.Log in date range","")_FromDay_" - "_ToDay
 s arg("type")="line"
 s labels="["
 for day=$h-days:1:+$h {
	s labels=labels_""""_$zd(day,3)_""","
	s a="" f num=1:1 { s a=$o(res(a)) q:a=""
		i '$d(color(a)) s color(a)=num
		i '$d(data(a)) s data(a)="{  label: """_a_""", borderColor: '"_..ColorRGBa(color(a),1)_"',  data: ["
		s data(a)=data(a)_+$g(res(a,$zd(day,3)))_","
	}
 }
 d ..FinishArg(.res, .data, .labels, .arg)
 q 1
}

}

