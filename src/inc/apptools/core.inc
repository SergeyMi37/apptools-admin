ROUTINE apptools.core [Type=INC]
#Include %occMessages
#include %occReference

/// Returns a line with given formatting, clearing the formatting at the end of the line
#define FormattedLine(%formatCode, %line) $$$ControlSequence(%formatCode)_%line_$$$ControlSequence($$$ResetAll)

/// Creates the control sequence for the formatting based on the code
#define ControlSequence(%code) $Char(27)_"["_%code_"m"

#; Codes to add to convert format types
#define Reset 20
#define Background 10

#; All font formats (bold, underline etc.)
#define Bold 1
#define Bright 1
#define Dim 2
#define Underlined 4
#define Blink 5
#define Reverse 7
#define Hidden 8

#; All font format resets
#define ResetAll 0
#define ResetFontFormat(%format) ($$$Reset + %format)

#; Text colour conversions
#define BackgroundColor(%fgColor) ($$$Background + %fgColor)

#; All text colors in foreground
#define Default 39
#define Black 30
#define Red 31
#define Green 32
#define Yellow 33
#define Blue 34
#define Magenta 35
#define Cyan 36
#define White 97

#;App. -> apptools.
#;apptools.core.LogMacro -> apptools.core

#; Escape sequence for coloring the font in terminal do ##class(apptools.core.msg).EscColor()
#define escClear $c(27)_"[0m"
#define escBg $Case(##class(apptools.core.msg).ZPMColorScheme(),"white":47,"dark":40,:0)
#define escGreen(%t) $Select($$$escBg=0:%t,1:$c(27)_"[1;32;"_$$$escBg_"m"_%t_$$$escClear)
#define escBlue(%t) $Select($$$escBg=0:%t,1:$c(27)_"[1;36;"_$$$escBg_"m"_%t_$$$escClear)
#define escDefault(%t) $Select($$$escBg=0:%t,1:$c(27)_"[1;3"_$Select($$$escBg:0,1:7)_";"_$$$escBg_"m"_%t_$$$escClear)
#define escYellow(%t) $Select($$$escBg=0:%t,1:$c(27)_"[1;33;"_$$$escBg_"m"_%t_$$$escClear)
#define escViolet(%t) $Select($$$escBg=0:%t,1:$c(27)_"[1;35;"_$$$escBg_"m"_%t_$$$escClear)
#define escSeq(%e,%t) $Select($$$escBg=0:%t,1:$c(27)_"["_%e_"m"_%t_$$$escClear)

#;%from - id form for serialize elements
#;%to - id div output result
#;%ns - namespase class
#;%class - classname
#;%method - method executed
#;%arg - string cgi variables 
#define onclick(%from,%to,%ns,%class,%method,%arg) ##class(apptools.core.Action).WriteActJs(%request,%from,%to,%class,%method,%arg,%ns) 
#define SetHeightContent(%id,%d) $$$jsstart w $$$NL write "$('#"_%id_"MainContent').height($(window).height()-($('#"_%id_"MainHeader').height()+$('#t1').height()+"_%d_"));"_$$$NL $$$jsstop w $$$NL

#;Include %msql $$$MaxStringLength
#;		;2016.2<= set title={}.%FromJSON(json).title 
#;		;2016.1 set title={}.$fromJSON(json).title
#;		set title={}.$$$jsonFromJSON(json).title
#define R(%property) %request.Content.##Expression(%property)
#define RG(%property) %request.Get(%property)
#define StackPlace 		$st($st(-1),"PLACE")
#define CurrentClass 	##Expression($$$quote(%classname))
#define CurrentMethod 	##Expression($$$quote(%methodname))
#define slash $s($zversion(1)=3:"/",1:"\")
#define FileTempDir	$zu(140,17)

#define formatJSON 		"aelotwc"
#define formatJSONSQL	"tw"
#define formatDate		3
#define formatTime		7

#define toJSONClassMethod "toJSON"
#define updateClassMethod "updateIdFromObject"
#define IsNewJSON ##Expression($$$comClassDefined("%Library.DynamicAbstractObject"))

#if $$$IsNewJSON
    #define NewDynObj {}
    #define NewDynDTList []
    #define NewDynObjList $$$NewDynDTList
    #define Insert(%obj,%element) do %obj.%Push(%element)
    #define DynObjToJSON(%obj) w %obj.%ToJSON()
    #define ListToJSON(%obj) $$$DynObjToJSON(%obj)
    #define ListSize(%obj) %obj.%Size()
    #define ListGet(%obj,%i) %obj.%Get(%i-1)
    #define jsonClassIsLatestVersion %ClassIsLatestVersion 	
    						//usage: obj.$$$jsonClassIsLatestVersion()
    #define jsonExtends %Extends							
    						//usage: {}.$$$jsonExtends(classname) 
    #define jsonFromJSON %FromJSON							
    						//usage: {}.$$$jsonFromJSON(string) 
    #define jsonGetIterator %GetIterator 					
    						//usage: obj.$$$jsonGetIterator()
	#define jsonGetNext %GetNext 					
    						//usage: iterator.$$$jsonGetNext(.key, .value)
	#define jsonIsA %IsA									
    						//usage: obj.$$$jsonIsA(className)
    #define jsonToJSON %ToJSON								
    						//usage: obj.$$$jsonToJSON()
    #define jsonGet %Get									
    #define jsonNew %New									
    						//usage: obj.$$$jsonGet(key)
    #define jsonIsDefined %IsDefined						
    						//usage: obj.$$$jsonIsDefined(key) 
    #define jsonRemove %Delete								
    						//usage: obj.$$$jsonRemove(key)
    #define jsonSet %Set									
    						//usage: obj.$$$jsonSet(key, val)
    #define jsonSize %Size									
    						//usage: obj.$$$jsonSize()
    #define jsonPop %Pop									
    						//usage: obj.$$$jsonPop()
    #define jsonPush %Push									
    						//usage: obj.$$$jsonPush(val) 
	#define jsonAbstractClass %Library.AbstractDynamicObject
	#define jsonObjectClass %Library.DynamicObject
	#define jsonArrayClass %Library.DynamicArray
	
	#define jsonInitialArrayIndex 1
	
	#define jsonGetTypeOf %GetTypeOf
    						//usage: obj.$$$jsonGgetTypeOf()
#else
    #define NewDynObj ##class(%ZEN.proxyObject).%New()
    #define NewDynDTList ##class(%ListOfDataTypes).%New()
    #define NewDynObjList ##class(%ListOfObjects).%New()
    #define Insert(%obj,%element) do %obj.Insert(%element)
    #define DynObjToJSON(%obj) do %obj.%ToJSON()
    #define ListToJSON(%obj) do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(%obj)
    #define ListSize(%obj) %obj.Count()
    #define ListGet(%obj,%i) %obj.GetAt(%i)

   #define jsonClassIsLatestVersion $classIsLatestVersion 	
    						//usage: obj.$$$jsonClassIsLatestVersion()
    #define jsonExtends $extends							
    						//usage: {}.$$$jsonExtends(classname) 
    #define jsonFromJSON $fromJSON							
    						//usage: {}.$$$jsonFromJSON(string) 
    #define jsonGetIterator $getIterator 					
    						//usage: obj.$$$jsonGetIterator()
    #define jsonGetNext $getNext 					
    						//usage: iterator.$$$jsonGetNext(.key, .value)
    #define jsonIsA $isA									
    						//usage: obj.$$$jsonIsA(classname)
    #define jsonToJSON $toJSON								
    						//usage: obj.$$$jsonToJSON()
    #define jsonGet $get									
    #define jsonNew $new									
    						//usage: obj.$$$jsonGet(key)
    #define jsonIsDefined $isDefined						
    						//usage: obj.$$$jsonIsDefined(key) 
    #define jsonRemove $remove								
    						//usage: obj.$$$jsonRemove(key)
    #define jsonSet $set									
    						//usage: obj.$$$jsonSet(key, val)
    #define jsonSize $size									
    						// usage: obj.$$$jsonSize()
    #define jsonPop $pop									
    						//usage: obj.$$$jsonPop()
    #define jsonPush $push									
    						//usage: obj.$$$jsonPush(val) 
 	#define jsonAbstractClass %Library.AbstractObject
	#define jsonObjectClass %Library.Object
	#define jsonArrayClass %Library.Array
	#define jsonInitialArrayIndex 0
	#define jsonGetTypeOf $getTypeOf
    						//usage: obj.$$$jsonGgetTypeOf()
#endif


#def1arg jsonIsAbstract %IsA(##Quote($$$jsonAbstractClass))
							//usage: obj.$$$jsonIsAbstract
#def1arg jsonIsObject %IsA(##Quote($$$jsonObjectClass))
							//usage: obj.$$$jsonIsObject
#def1arg jsonIsArray %IsA(##Quote($$$jsonArrayClass))
							//usage: obj.$$$jsonIsArray

#define MethodArguments ##Expression(##class(apptools.core.Log).GetMethodArguments(%classname,%methodname))

#define LogEvent(%type, %message) Do ##class(apptools.core.Log).AddRecord($$$CurrentClass,$$$CurrentMethod,$$$StackPlace,%type,$$$MethodArguments,%message)
#define LogNone(%message) 		$$$LogEvent("NONE", %message)
#define LogError(%message) 		$$$LogEvent("ERROR", %message)
#define LogFatal(%message) 		$$$LogEvent("FATAL", %message)
#define LogWarn(%message) 		$$$LogEvent("WARN", %message)
#define LogInfo(%message) 		$$$LogEvent("INFO", %message)
#define LogStat(%message) 		$$$LogEvent("STAT", %message)
#define LogDebug(%message) 		$$$LogEvent("DEBUG", %message)
#define LogRaw(%message) 		$$$LogEvent("RAW", %message)

#; To obtain the date and time in $h
#define LoggedDT(%h) $s(%h[",":$tr($zd(%h,4),"/",".")_" "_$zt(+$p(%h,",",2),1),1:"")

#; the macro saves the node in the global call stack and all local variables 
#; Example of usage: /apptools/apptools.core.LogInfo.cls?WHAT=?
#; If you need a trap for a particular process, to assign s ^logFIO(0)=Number of process
#define LogEventAddGN(%debubGN, %message) s %AppLogId=##class(apptools.core.Log).AddRecord($$$CurrentClass,$$$CurrentMethod,$$$StackPlace,"DEBUG",%debubGN,%message)
#define logdevGN 	"^log"
#define MgtPortalSettings 	"^CacheTemp.MgtPortalSettings"
#define AppLogTab(%type,%message,%desc) Do ##class(apptools.core.Log).AddRecord($$$CurrentClass,$$$CurrentMethod,$$$StackPlace,%type,%desc,%message)
#define AppLog(%dev,%node,%list,%mode) s zsr=$zr,zsG=$$$logdevGN_%dev  if $g(@zsG@(0))=$j||($g(@zsG@(0))="") { s @zsG@(1,$i(@zsG),%node)=%list,zsGzr=$zr if %mode["t" { $$$LogEventAddGN(zsGzr,%list) } if %mode["s" {s zsG=$na(@($qs(zsGzr,0)_"stack")@($qs(zsGzr,2))),@zsG=$lb($ze,$h,$tl,$io,$j,$zu(110),##class(apptools.core.LogInfoPane).GetPathStack(),##class(apptools.core.Log).GetClientAddress()) S zs1="",zsG=$na(@zsG@("varList")),zsii=0 k @zsG s:%mode["e" @zsG@("%%%$$LOG^%ETN")=$$LOG^%ETN  if %mode["v" { f { s zs1=$O(@zs1) q:zs1=""  continue:$e(zs1,1,2)="zs"&&(zs1'="zs")  if $d(@zs1)'["0",$isobject(@zs1) { s @zsG@(zs1)=##class(apptools.core.Log).SerializeObject(@zs1,$na(@zsG@(zs1))),zsii=zsii+1 } elseif $d(@zs1)>9 {s:$d(@zs1)=11 @zsG@(zs1)=@zs1,zsii=zsii+1 MERGE @zsG@(zs1)=@zs1 if zs1="%zlog" {s zs2="" for {s zs2=$o(@zs1@(zs2)) q:zs2=""   s @zsG@(zs1,zs2)=##class(apptools.core.Log).SerializeObject($G(@zs1@(zs2)),$na(@zsG@(zs1,zs2)),%mode)   }}}	 elseif $d(@zs1)=1 {s @zsG@(zs1)=@zs1,zsii=zsii+1}} s @zsG=zsii KILL zsii,zsG,zs1,zs2}else{KILL zsii,zsG,zs1,zs2,zsGzr}} try{ if $d(@zsr) KILL zsr} catch e { KILL zsr}}
#; To add an active link to the panel
#define addAppLog(%text,%title,%input,%target) "<a title='"_%title_"' "_$g(%target)_" href=""apptools.core.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_$zconvert(%input,"O","URL")_""">"_%text_"</a>"
#define addAppL(%text) "<a target="""_$ZCRC(%text,7)_""" href=""apptools.core.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_$zconvert(%text,"O","URL")_""">"_%text_"</a>"
#define addLoadLogInfo(%text,%title,%input,%http) "<a title='"_%title_"' target=LogInfo"_$tr($zts,",.")_" href="""_%http_"apptools.core.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_$zconvert(%input,"O","URL")_""">"_%text_"</a>"
#define addLoadLogInfoNSP(%text,%title,%input,%http,%nsp) "<a title='"_%title_"' target=_blank href="""_%http_"apptools.core.LogInfo.cls?NSP="_%nsp_"&WHAT="_$zconvert(%input,"O","URL")_""">"_%text_"</a>"

#; To obtain the date and time YYYY-MM-DD HH:MM:SS
#define AppDT(%h) $zd(+%h,3)_" "_##class(apptools.core.type).GetValidZT(%h)
#define AppObJs(%ob)  $s($isobject(%ob):##class(apptools.core.Log).WriteJSONFromObject(%ob),1:%ob)
#define ApplogGN(%fio) ("^log"_$zconvert($e(%fio,1,3),"U"))
#;define AppL(%fio,%node) @$$$ApplogGN(%fio)@($i(@$$$ApplogGN(%fio)),$$$AppDT($h)_" "_%node)
#define AppL(%fio,%node) @$$$ApplogGN(%fio)@($i(@$$$ApplogGN(%fio)),$$$AppDT($h)_" ("_$classname()_")."_%node)

#define forAll(%in,%gn) s gn%in=$na(%gn) s %in="" f { s %in=$o(@gn%in@(%in)) q:%in=""
#define forAllk(%in,%kn,%gn) s gn%in=$na(%gn) s %in="" f %kn=1:1 { s %in=$o(@gn%in@(%in)) q:%in=""
#define forEnd  }

#; keep the name of the current region
#define NspGoto(%cur,%ns)  s %cur=$zu(5) try {zn %ns} catch e {} 
#; to return to the current region
#define NspReturn(%cur)  zn %cur
#;---------- layout
#;
#define appSpan(%id,%attr,%val) "<span "_%attr_" id='"_%id_"' name='"_%id_"'>"_%val_"</span>"
#define appStyleInput " style='border: none;	background: none;	color: inherit;	padding: .222em 0;	margin: .2em 0;	vertical-align: middle;	margin-left: .4em;	margin-right: .4em;' "
#define appInputHidden(%id,%attr,%val) "<input type=hidden "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'>"
#define appText(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input "_$$$appStyleInput_" type=text "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'></span>"
#define appAutocomplete(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input id='"_%id_"' name='"_%id_"' "_%attr_" "_$$$appStyleInput_" autocomplete='off' value='"_%val_"'>"
#define appAutocomplete2(%id,%attr,%val) "<input id='"_%id_"' name='"_%id_"' "_%attr_" class='ui-autocomplete-input' autocomplete='off' value='"_%val_"'>"
#define appInput(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input autocomplete='off' "_$$$appStyleInput_" "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'></span>"
#define appButton(%id,%attr,%val) $s($g(%ui):"<button class='uk-button uk-button-primary uk-margin-small-right' type='button' "_%attr_" id='"_%id_"' name='"_%id_"' >"_%val_"</button>",1:"<input class='ui-button ui-corner-all ui-widget' type=button id='"_%id_"' name='"_%id_"' "_%attr_" value='"_%val_"'>")
#define appTextarea(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><textarea autocomplete='off' "_$$$appStyleInput_" "_%attr_" id='"_%id_"' name='"_%id_"' >"_%val_"</textarea></span>"
#define appDate(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input autocomplete='off' "_$$$appStyleInput_" type=date "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'></span>"
#define appDateTime(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input autocomplete='off' "_$$$appStyleInput_" type=datetime-local "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'></span>"
#;define appCheck(%id,%attr,%val) "<input class='ui-button ui-corner-all ui-widget' type=checkbox id='"_%id_"' name='"_%id_"' "_%attr_" value='"_%val_"'>"
#define appCheck(%id,%attr,%val) "<input class='bigbox' type=checkbox id='"_%id_"' name='"_%id_"' "_%attr_" value='"_%val_"'>"
#; Selects
#define appSelect(%id,%attr,%for,%onchange,%width) "<SELECT ONCHANGE='"_%onchange_"' id='"_%id_"' name='"_%id_"' "_%attr_" > "_%for_" </SELECT><script type='text/javascript'> $( '#"_%id_"' ).selectmenu({ change: function( event, data ) { "_%onchange_" }, width:"_%width_" }).selectmenu('menuWidget'); $('#"_%id_"-menu' ).css( 'max-height','500px'); </script>"
#define appMultiSelect(%id,%attr,%for) "<select "_%attr_" id='"_%id_"' name='"_%id_"' multiple='multiple'> "_%for_" </select><script type='text/javascript'> $('#"_%id_"').multiselect({showSelectedValues: true}); </script>"

#define appError(%val) "<div class='ui-widget'><div class='ui-state-error ui-corner-all' style='margin-top: 20px; padding: 1em;'><p><span class='ui-icon ui-icon-alert' style='float: left; margin-right: 3em;'></span>"_%val_"</p></div></div>"
#define appMsg(%val) "<div class='ui-widget'><div class='ui-state-highlight ui-corner-all' style='margin-top: 20px; padding: 1em;'><p><span class='ui-icon ui-icon-info' style='float: left; margin-right: 3em;'></span>"_%val_"</p></div></div>"

#define appTableAttr "style=""border-radius: 10px; border: 1px solid #72a7cf"" cellpadding=2 cellspacing=0 class=""DetailTable"" bgcolor=""#c4d6d6"" width=""90%"""
#define appTable1(%n1) "<table "_$$$appTableAttr_"><tbody><tr><th>"_%n1_"</th></tr>"
#define appTableTrTd1(%n1) "<tr class=""trs"" ><td align=""center"" >"_%n1_"</td></tr>"
#define appTableEnd1 "</tbody></table>"_$s('$d(%DrawArray):"<script language='javascript'>$('.trs').hover(function(){ $(this).toggleClass( 'ui-widget-content' ) });</script>",1:"")

#define appTable2(%n1,%n2) "<table "_$$$appTableAttr_"><tbody><tr><th align=""left"" width=""5px"">"_%n1_"</th><th align=""left"" width=""50px"">"_%n2_"</th></tr>"
#define appTableTrTd2(%n1,%n2) "<tr class=""trs"" ><td align=""left"" >"_%n1_"</td><td>"_%n2_"</td></tr>"
#define appTableEnd2 "</tbody></table>"_$s('$d(%DrawArray):"<script language='javascript'>$('.trs').hover(function(){ $(this).toggleClass( 'ui-widget-content' ) });</script>",1:"")

#define appTable3(%n1,%n2,%n3) "<table "_$$$appTableAttr_"><tbody><tr><th align=""left"" width=""5px"">"_%n1_"</th><th align=""left"" width=""50px"">"_%n2_"</th><th align=""left"" width=""50px"">"_%n3_"</th></tr>"
#define appTableTrTd3(%n1,%n2,%n3) "<tr class=""trs"" ><td style=""text-align:left"" >"_%n1_"</td><td style=""text-align:left"" >"_%n2_"</td><td style=""text-align:left"" >"_%n3_"</td></tr>"
#define appTableEnd3 "</tbody></table>"_$s('$d(%DrawArray):"<script language='javascript'>$('.trs').hover(function(){ $(this).toggleClass( 'ui-widget-content' ) });</script>",1:"")

#define appTab3(%n1,%n2,%n3) "<table cellpadding=2 cellspacing=0 border=1 class=""DetailTable"" width=""90%""><tbody><tr><th align=""left"" width=""5px"">"_%n1_"</th><th align=""left"" width=""50px"">"_%n2_"</th><th align=""left"" width=""50px"">"_%n3_"</th></tr>"

#define jsbegin "<script language='javascript'>"_$$$NL
#define jsend "</script>"_$$$NL
#define jsstart write $$$jsbegin
#define jsstop write $$$jsend
#define styleurl "text-decoration:underline; color:blue; cursor:hand;"
#define blockui(%msg)  "$.blockUI( { message: '"_%msg_"' , css: { border: 'none', padding: '15px', backgroundColor: '#000', '-webkit-border-radius': '10px','-moz-border-radius': '10px', opacity: .5, color: '#fff' }} );"

#define Msg(%c,%t) "<span class='brand-text font-weight-light' style='color:"_%c_"'>"_%t_"</span><br>"
#define Message(%t) "<span style='color:green'><b>"_%t_"</b></span><br>"
#define MessErr(%t) "<span style='color:hotpink'><b>"_%t_"</b></span><br>"

#;	Localization
#define GNLangDOMAIN "AppTools"

#define GNEnsConf "^%apptools.Setting"
#define EnsProductStatusRun $g(@$$$GNEnsConf@("EnsProductStatusRun"),"Running")

/// Global history of command
#define HISTORYGN "^%apptools.History"
/// Global tempory data
#define TEMPORYGN "^mtempAppData"
/// Global projects in the system
#define PROJGN "^%apptools.Proj"
#define GNExtentions "^%apptools.Exten"
/// Global tempory data for Journals
#define TEMPJRNL "^%apptools.JRNL"
/// Limiting the number of nodes in a global or query result for output
#define MAXSHOW 10000

#;;; Parameters dependent on the installation server
#define GNLang "^%AppCacheMsg"
#; Path to CSP apps "/apptools/"
#define  PATHCSP $GET(@$$$GNEnsConf@("PATHCSP")) 
#; Mail Server Settings
#define  EMAILSERVERIP $GET(@$$$GNEnsConf@("EMAILSERVERIP"))
#define  EMAILSERVERPORT $GET(@$$$GNEnsConf@("EMAILSERVERPORT"))
#; Authorization in the mail server
#define  EMAILAUTH $GET(@$$$GNEnsConf@("EMAILAUTH")) 
#define  EMAILAUTHPASS $GET(@$$$GNEnsConf@("EMAILAUTHPASS"))
#; Technical support admin address
#define  EMAILSUPPORT $G(@$$$GNEnsConf@("EMAILSUPPORT")) 
#; Path for temporary xls file before sending to mail
#define  EMAILXLSPATH $G(@$$$GNEnsConf@("EMAILXLSPATH"))
#; Path to storing project sources
#define  EXPORTPROJPATH $G(@$$$GNEnsConf@("EXPORTPROJPATH")) 

#; --------------- Application section
#define GNmessages "^%apptools.cconsolelog"
#define DubledQuote(%s)	$replace(%s,"'","''")


#If $DATA(^%apptools.Proj("infoservice-focus"))
#define  TESTSERVER "-test"
#define DEVELOPER "mihaylenko_sv"
#; The module display links to the administrative application panel
#define  DRAWAllApp ##class(apptools.MVK.docbook).GetAllApp(0)
#define SDNum if $g(SDNum)'="" write:##class(apptools.core.sys).ClassExist("apptools.MVK.docbook") "<br>"_##class(apptools.MVK.docbook).FindSDRef(SDNum)
#define aText(%en,%ru) ##Expression(##class(apptools.core.msg).AddLangMsg(%en,%ru))
#define  MultiLang 1
#define  JSLibLocal 1

#Else 
#define  TESTSERVER " "
#define DEVELOPER "admin"
#; The module display links to the administrative application panel
#define  DRAWAllApp " "
#define SDNum  
#define aText(%en,%ru) %en
#define  MultiLang 0
#define  JSLibLocal 0

#EndIf

#; --------------- Icons - https://apps.timwhitlock.info/emoji/tables/unicode
#; Hammer and Pick
#define emojiHammerPick $wc($zhex("2692"))
#;  neutral face  
#define emojiNeutralFace $wc($zhex("1F610"))
#; pouting face
#define emojiPoutingFace $wc($zhex("1F621")) 
#; black down-pointing double triangle
#define emojiDoubleTriangle $wc($zhex("23EC")) 

#; https://fontawesome.com/v5/search?q=down&o=r&m=free
#define fasDownload "<i class=""fas fa-download""></i>"
#; >
#define fasAR "<i class=""fas fa-solid fa-angle-right""></i>" 
#define fasHist "<i class=""fas fa-history""></i>"
#; ...
#define fasPPP "<i class=""fas fa-ellipsis-h""></i>" 
#define fasCupe "<i class=""fas fa-solid fa-cube""></i>" 
#define fasAst "<i class=""fas fa-solid fa-asterisk""></i>"
#define fasLogin "<i class=""fas fa-sign-in-alt""></i>"
#define fasLogout "<i class=""fas fa-sign-out-alt""></i>" 
#define fasOpt "<i class=""fas fa-cog""></i>"

#define isGenerated(%code) ##class(%RoutineMgr).IsGenerated( %code )
#define isPercented(%code) ("%" = $Extract(%code))
#define isMapped(%code) ##class(%RoutineMgr).IsMapped( %code )
