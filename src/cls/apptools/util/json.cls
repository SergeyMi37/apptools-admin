Include %ZEN.Utils

Class apptools.util.json [ Not ProcedureBlock ]
{

/// set sc=##class(apptools.util.json).Test(.obj)
ClassMethod Test(ByRef out, aa) As %Status [ ProcedureBlock = 0 ]
{
	set o = ##class(%ZEN.proxyObject).%New()
	set a("name")=$zv
	 set a("zvname")=$zu(110)
	 for i=1:1:5 set a("zvname",i)=i_"sss"
	 d o.%CopyFromArray(.a)
	 s aa=##class(apptools.core.Log).WriteJSONFromObject(o)
	 q 1
	 s st=o.%SerializeObject(.out)
	 zw out
	q $$$OK
}

/// set sc=##class(apptools.util.json).Export($na(^SAMPLE.PersonD),.json) do json.%ToJSON()
ClassMethod Export(GlobalRoot As %String, Output JSON As %DynamicObject) As %Status [ ProcedureBlock = 0 ]
{
	if '$d(@GlobalRoot) quit $System.Status.Error(5001, "Nothing to export; "_GlobalRoot_" <undefined>")
	set root=$p(GlobalRoot,")",1,$l(GlobalRoot,")")-1),node=GlobalRoot s:root="" root=GlobalRoot
	set JSON=##class(%DynamicObject).%New()
	set JSON.globalName=$p(GlobalRoot,"(",1)
	set JSON.nodes=##class(%DynamicArray).%New()
	while $e(node,1,$l(root))=root {
		if $d(@node)#10 do ..addNode(node,.JSON)
		set node=$q(@node)
	}
	quit 1
}

ClassMethod addNode(node As %String, ByRef JSON As %DynamicObject) As %Status
{
	set nodeJSON=##class(%DynamicObject).%New()
	set data=@node,nodeJSON.data=##class(%CSP.Page).EscapeHTML(data)
	set subscripts=$p(node,"(",2,999),subscripts=$p(subscripts,")",1,$l(subscripts,")")-1)
	if ""'=subscripts {
		set nodeJSON.subscripts=##class(%DynamicArray).%New()
		set cp=1
		for {
			q:cp>$l(subscripts,",")
			set subscript=$p(subscripts,",",cp)
			f  {
				q:$l(subscript,"""")#2
				set cp=cp+1,subscript=subscript_","_$p(subscripts,",",cp)
			}
			set subArray=$i(subArray),subArray(subArray)=subscript
			set cp=cp+1
		}
		for i=1:1:subArray do nodeJSON.subscripts.%Push(##class(%CSP.Page).EscapeHTML(subArray(i)))
	}	
	do JSON.nodes.%Push(nodeJSON)
}

/// d ##class(apptools.util.json).GlobalToJSON("^tmp")
/// 
/// Write out the contents of the named global or % array <var>pGlobalName</var> in JSON format.
/// Subscripts become JSON property names and $List values become JSON arrays.<br/>
/// <var>pFormat</var> is a flags string that controls output formatting options.<br/>
/// The following character option codes are supported:<br/>
/// 1-9 : indent with this number of spaces (4 is the default with the 'i' format specifier)<br/>
/// b - line break before opening { of objects<br/>
/// i - indent with 4 spaces unless 't' or 1-9<br/>
/// n - newline (lf)<br/>
/// s - use strict JSON output - <strong>NOTE:</strong> special care should be taken when sending data to a browser, as using this flag 
/// may expose you to cross site scripting (XSS) vulnerabilities if the data is sent inside <code>&lt;script&gt;</code> tags. Zen uses
/// this technique extensively, so this flag should <strong>NOT</strong> be specified for jsonProviders in Zen pages.<br/>
/// t - indent with tab character<br/>
/// u - output pre-converted to UTF-8 instead of in native internal format<br/>
/// w - Windows-style cr/lf newline<br/>
/// <var>pNodeName</var> is the name of a special JSON property used to hold the top-level value of a global node.
ClassMethod GlobalToJSON(pGlobalName = "", pFormat As %String = "tw", pNodeName As %String = "^_", pLevel As %Integer = 0) As %Status
{
	Quit:$IsObject(pGlobalName) ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(pGlobalName,,,pFormat) // switch around; call global export from inside jsonProvider.%ObjectToJSON
	Quit:$Case($E(pGlobalName),"^":0,"%":0,:1) $$$ERROR($$$GeneralError,"Array name must start with % or ^.  Found '"_pGlobalName_"'")
	Set tSC = $$$OK
	Set tLF=$S(pFormat["w":$C(13,10), pFormat["n":$C(10), 1:"")
	If pFormat'=$TR(pFormat,"it123456789") { Set tN=+$ZStrip(pFormat,"<E'N"), $P(tTab,$S(pFormat["t":$C(9),1:" "),1+$S(tN:tN,pFormat["t":1,1:4))="" }
	Else { Set tTab="" }
	Set tIncludeWhitespace = (tLF_tTab'="")
	If pFormat["o" || 'pLevel {
		Set tPropCount = ""
		If (tIncludeWhitespace && pLevel) Set tIndent="", $P(tIndent,tTab,pLevel+1)="" Write $S(pFormat["b":tLF_tIndent,1:" ")
		Write "{"
	} Else {
		Set tPropCount = 0
	}
	Try {
		Set d = $D(@pGlobalName,tVal)
		If d#2 {
			// process node top value
			If d>1||'pLevel {
				Do nextProp
				Write $$$ZENJSONPROP(pNodeName,pFormat)_":" ; note: erroneously escapes $C(11) as \v
			}
			Do ..writeScalar(tVal,pFormat,pLevel)
		}
		If d>1||'pLevel {
			// process node child values
			Set k="" For { Set k=$O(@pGlobalName@(k))  Quit:""=k
				If k=pNodeName Set tSC=$$$ERROR($$$GeneralError,"Array subscript name collision with top node name '"_pNodeName_"'")  Quit
				Do nextProp
				Write $$$ZENJSONPROP(k,pFormat)_":"
				Set tSC=..GlobalToJSON($Name(@pGlobalName@(k)),pFormat,pNodeName,pLevel+1)  Quit:$$$ISERR(tSC)
			}
			If tPropCount'=0 {
				#; either we wrote at least one property or we wrote an empty '{' due to "o" mode or level zero
				If tIncludeWhitespace Set tIndent="", $P(tIndent,tTab,pLevel+1)="" Write tLF_tIndent
				Write "}"
			}
		}
	}
	Catch ex {
		Set tSC = ex.AsStatus()
		Write "null"
	}
	Quit tSC
nextProp
	If tPropCount=0 {
		If (tIncludeWhitespace && pLevel) Set tIndent="", $P(tIndent,tTab,pLevel+1)="" Write $S(pFormat["b":tLF_tIndent,1:" ")
		Write "{"
	} ElseIf tPropCount {
		Write ","
	} ; else tPropCount="" means we already did the starting '{' due to "o" mode
	Set tPropCount = tPropCount + 1
	If tIncludeWhitespace Set tIndent="", $P(tIndent,tTab,pLevel+2)="" Write tLF_tIndent
	Quit
}

ClassMethod writeScalar(pVal As %String, pFormat As %String, pLevel As %Integer, pForceStr As %Boolean = 0) [ Internal ]
{
	If ""=pVal||'$ListValid(pVal) {
		Write $S('pForceStr&&$$$ZENJSISNUM(pVal):$$$ZENJSNUM(pVal), 1:$$$ZENJSONSTR(pVal,pFormat)) ; note: erroneously escapes $C(11) as \v
	} Else {
		Write "["
		For i=1:1:$LL(pVal) {
			Write:i>1 ","
			If $LD(pVal,i) {
				Set tItem = $LI(pVal,i)
				Do ..writeScalar(tItem,pFormat,.pLevel,$ListValid(tItem)||$Case($E($LB($LI(pVal,i)),2), $C(1):1, $C(2):1, :0))
			} Else {
				Write "null"
			}
		}
		Write "]"
	}
}

ClassMethod GlobalsToJSONStream(ByRef pArrOfGlobalNames As %String, pStream As %Stream.Object, pFormat As %String = "tw", pNodeName As %String) As %Status
{
	Set tSC = $$$OK
	Do pStream.Write("{"_$C(13,10))
	Set k="" For i=1:1 { Set k=$O(pArrOfGlobalNames(k))  Quit:""=k
		Do:i>1 pStream.Write(","_$C(13,10))
		Do pStream.Write($$$ZENJSONPROP("^"_$E(k,1,*-4),pFormat)_":")
		Set tSC = ..GlobalToJSONStream("^"_$E(k,1,*-4),pStream,pFormat)  Quit:$$$ISERR(tSC)
	}
	Do pStream.Write($C(13,10)_"}")
	Quit tSC
}

/// remove; not needed if global support is integrated in jsonProvider
ClassMethod GlobalToJSONStream(pObject As %String, pStream As %Stream.Object, pFormat As %String, pNodeName As %String) As %Status [ ProcedureBlock = 0 ]
{
	New %ISCJSONStream, tSC, ex, tInitIO, tRedirected, tWasRedirected, tOldMnemonic
	Set tSC = $$$OK
	Set tRedirected = 0
	Try {
		Set tWasRedirected = 0
		Set tOldMnemonic = ""

		Set:'$IsObject($G(pStream)) pStream=##class(%Stream.TmpBinary).%New()

		Set tInitIO = $IO
		Set tWasRedirected = ##class(%Library.Device).ReDirectIO()
		Set tOldMnemonic = ##class(%Library.Device).GetMnemonicRoutine()
		Set %ISCJSONStream = pStream
		Use tInitIO::("^"_$ZNAME)
		Set tRedirected = 1
		Do ##class(%Library.Device).ReDirectIO(1)

		Set tSC = ..GlobalToJSON(.pObject,.pFormat,.pNodeName)
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	If tRedirected && ##class(%Library.Device).ReDirectIO(0) {
		Use tInitIO
	}
	If ($get(tOldMnemonic) '= "") {
		Set tOldMnemonic = "^"_tOldMnemonic
		Use tInitIO::(tOldMnemonic)
	}
	If $get(tWasRedirected) {
		Do ##class(%Library.Device).ReDirectIO(1)
	}
	Quit tSC
}

ClassMethod redirects() [ Internal, Private, ProcedureBlock = 0 ]
{
	Quit
#; Public entry points for redirection - any changes made here should
#; also be reflected in redirects() in the jsonSQLProvider class
wstr(s) Do %ISCJSONStream.Write(s) Quit
wchr(a) Do %ISCJSONStream.Write($char(a)) Quit
wnl Do %ISCJSONStream.Write($char(13,10)) Quit
wff Do %ISCJSONStream.Write($char(13,10,13,10)) Quit
wtab(n) New chars Set $piece(chars," ",n+1)="" Do %ISCJSONStream.Write(chars) Quit
rstr(len,time) Quit ""
rchr(time) Quit ""
}

ClassMethod SaveTrakLayout(pFile As %String = "", pFormat As %String) As %Status
{
	#dim tSC As %Status
	#dim tIO As %String
	Set tSC=$$$OK,$ZT="Trap",tIO=$IO
	Do {
		// Pick a default filename
		Set:pFile="" pFile=$system.Util.InstallDirectory()_"distlib/trak/misc/HSDBLayout.json"

		// Now, build a list of globals to export
		Write "Collecting globals, please be patient ...",!
		Do ..findLayoutGlobals(.tGlobals)

		Write "Exporting to ",pFile,!
		Set tFileStream = ##class(%IO.FileStream).%New()
		Do tFileStream.Open(pFile,"NEW",,,.tSC)  Quit:$$$ISERR(tSC)
		Set tFileStream.CharEncoding = "UTF8"
		Set tSC = ..GlobalsToJSONStream(.tGlobals, tFileStream, .pFormat) Quit:$$$ISERR(tSC)
		Do tFileStream.Close()
	} While (0)
Exit
	Do:$$$ISERR(tSC) $system.OBJ.DisplayError(tSC)
	Quit tSC
Trap
	Set $ZT="",tSC=$$$ERROR($$$CacheError,$ZE)
	Goto Exit
}

ClassMethod findLayoutGlobals(alist) [ Internal ]
{
	Do findGlobals("^epr*",				.alist)
	Do findGlobals("^oo*",				.alist)
	Do findGlobals("^websys.Dict*",		.alist)
	Do findGlobals("^websys.Pref*",		.alist) 
	Do findGlobals("^websys.Stan*",		.alist)
	Do findGlobals("^websys.Trans*",	.alist)
	Do findGlobals("^websys.Work*",		.alist)

	// Remove exceptions
	Kill alist("epr.CTChartItemTypeD.gbl")
	Kill alist("epr.CTChartItemTypeI.gbl")

	#; Include Layout Verison
	Set alist("HS.Layout.gbl")=""
	Quit

findGlobals(spec,list)
	If $E(spec,$L(spec))="*" {
		// Wildcards
		Set (spec,glo) = $E(spec,1,$L(spec)-1)
		For {
			If $D(@spec) {
				Set list($E(spec,2,$L(spec))_".gbl")=""
			}
			Set spec = $O(^$global(spec))
			Quit:spec=""
			Quit:$E(spec,1,$L(glo))'=glo
		}
	} Else {
		// Specific global
		Set:$D(@spec) list($E(spec,2,$L(spec))_".gbl")=""
	}
	Quit
}

/// Parse the input string <var>pJSON</var> containing JSON notation
/// and store it in a named global or % array <var>pGlobalName</var>.<br/>
/// <var>pJSON</var> could also be a character stream.<br/>
/// JSON objects nested within JSON arrays cannot be imported because JSON arrays are imported as $List values. A $List value can contain other $List elements but not object references or COS arrays.<br/>
/// <var>pNodeName</var> is the name of a special JSON property used to hold the top-level value of a global node.
/// <var>pCharsProcessed</var> and <var>pLevel</var> are used internally and do not have to be supplied.
/// Note that this method assumes well-formed JSON content; it does not perform complete error checking.
ClassMethod ParseJSONToGlobal(pJSON As %String, pGlobalName As %String, pNodeName As %String = "^_", Output pCharsProcessed As %Integer, pLevel As %Integer = 1, pFirstChar As %String = "") As %Status
{
#define WHITESPACE(%c) (((%c)=" ")||((%c)=$C(10))||((%c)=$C(13))||((%c)=$C(9)))
#define MATCHHEXCHARS(%hex,%n) (%hex ? %n(1N,1(1"A",1"B",1"C",1"D",1"E",1"F",1"a",1"b",1"c",1"d",1"e",1"f")))

	Set tSC = $$$OK
	Try {
		Set pCharsProcessed = 0
		Set p = 1
		Set tToken = ""
		Set tProperty = ""
		Set tValue = ""
		Set tState = 0
		Set tIsString = 0
		Set tPropQuoted = 0
		Set tQuote = ""
		Set tUnicodeHex = ""
		Set tHex = ""
		Set tArrayList ="" // used to accumulate $List arrays for storage into the global
		Set list = "" // passed ByRef in place of global name when we need to get back a child $List array
		Set tIO=$S('$IsObject(pJSON):"",1:+pJSON.%Extends("%IO.I.Stream"))
		
		While $$$ISOK(tSC) {
			// test end condition; get next character
			If $L(tIO) {
				If (pFirstChar'="") {
					Set ch = pFirstChar, pFirstChar = ""
				} Else {
					Quit:pJSON.AtEnd
					Set ch = $S(tIO:pJSON.Read(1,,.tSC), 1:pJSON.Read(1,.tSC))  Quit:$$$ISERR(tSC)
				}
			} Else {
				Quit:p>$L(pJSON)
				Set ch = $E(pJSON,p)
			}
			Set p = p + 1
			Set pCharsProcessed = pCharsProcessed + 1

			If (tState = 0) {
				If ch = "{" {
					// start of object
					Kill @pGlobalName ; invalid list
					Set tState = 1
				} ElseIf ch = "[" {
					Set tToken = ""
					Set tIsString = 0
					Set tState = 5
				} ElseIf '$$$WHITESPACE(ch) {
					Set tSC = $$$ERROR($$$GeneralError,"Expected { or [ at start of JSON text.")
					Quit
				}
			}
			ElseIf (tState = 1) {
				If ch = "}" {
					// end of object
					Quit
				} ElseIf ch = """" && 'tPropQuoted {
					Set tPropQuoted = 1
					Set tToken = ""
					Set tState = 2
				} ElseIf ch'="" && '$$$WHITESPACE(ch) {
					// start of property name
					Set tToken = ch
					Set tState = 2
				}
			}
			ElseIf (tState = 2) {
				// property name
				If ch = "\" {
					Set tState = "2a"
				} ElseIf tPropQuoted {
					If ch = """" {
						Set tPropQuoted = 0
					} Else {
						Set tToken = tToken _ ch
					}
				} Else {
					If ch = ":" {
						Set tProperty = tToken, tToken = ""
 //#define ZENJSONUNESCAPE(%str,%format)		$S(%format["s":$ZCVT(%str,"I",$$$ZENJSONTABLE(%format)),1:$ZCVT(%str,"I",$$$ZENJSTABLE(%format)))
						// Set tProperty = ..%UnescapeJSONString(tToken) ; unescaping done in states 2abc
						Set tState = 3
						Set tIsString = 0
					} ElseIf '$$$WHITESPACE(ch) {
						Set tToken = tToken _ ch
					}
				}
			}
			// NOTE: States 2a, 2b and 2c are defined as the last few states as we expect escaped property names to be very rare
			ElseIf (tState = 3) || (tState = 5) {
				// property or array value
				If ch = "," || (ch = "}") || (ch = "]") {
					// end of value
					Set tValue = $S(tIsString:tToken, 1:$Case(tToken,"null":"","true":1,"false":0,"":"",:+tToken))
					If tState = 3 {
						If tProperty=pNodeName { Set @pGlobalName = tValue }
						Else { Set:(tToken'="null"||tIsString)&&$L(tProperty) @pGlobalName@(tProperty) = tValue }
						Set tState = 1
						Quit:ch="}" // end of object
					} Else {
						Set:$L(tToken)||tIsString tArrayList = tArrayList _ $S(tToken="null"&&'tIsString:$LB(), 1:$LB(tValue))
						If ch = "]" {
							If ""=pGlobalName { Set pGlobalName = tArrayList }
							Else { Set @pGlobalName = tArrayList }
							Quit // end of array
						}
					}
					Set tToken = "", tProperty = "", tValue = "", tIsString = 0
				} ElseIf ch = "{" || (ch = "[") {
					// start of object- or list- valued property
					If $IsObject(pJSON) { Set tSubJSON = pJSON, tPoke = ch } // simulate stream unwind
					Else { Set tSubJSON = $E(pJSON,p-1,*), tPoke = "" }
					If tState = 3 {
						Set tSC = ..ParseJSONToGlobal(tSubJSON,$S(tProperty=pNodeName:pGlobalName, 1:$Name(@pGlobalName@(tProperty))),pNodeName,.tChars,pLevel+1,tPoke)  Quit:$$$ISERR(tSC)
					} Else {
						If ch = "{" Set tSC=$$$ERROR($$$GeneralError,"JSON object within JSON Array not supported for import into Global at '"_pGlobalName_"'")  Quit
						Set tSC = ..ParseJSONToGlobal(tSubJSON,.list,"",.tChars,pLevel+1,tPoke)  Quit:$$$ISERR(tSC)
						Set tArrayList = tArrayList _ $LB(list), list=""
					}
					Set tProperty = ""
					Set p = p + tChars - 1
					Set pCharsProcessed = pCharsProcessed + tChars - 1
				} ElseIf ch = """" || (ch = "'") {
					// start of string
					Set tToken = ""
					Set tIsString = 1
					Set tQuote = ch
					Set tState = 4
				} ElseIf '$$$WHITESPACE(ch) {
					// must be a numeric value, or true,false,or null
					Set tToken = tToken _ ch
				}
			}
			ElseIf (tState = 4) {
				// string literal
				If ch = "\" {
					// escape?
					Set tState = "4a"
				} ElseIf ch = tQuote {
					// end of quoted string
					Set tState = $S(""=tProperty:5, 1:3)
				} Else {
					Set tToken = tToken _ ch
				}
			}
			// NOTE: States 4a, 4b and 4c precede states 2a, 2b and 2c as we expect literal strings to need escaping more often than property names
			ElseIf (tState = "4a") {
				// \ in string
				If ch = "u" {
					Set tUnicodeHex = ""
					Set tState = "4b"
				} ElseIf ch = "x" {
					// add special case support for \xNN escape sequences that are valid in Javascript
					Set tHex = ""
					Set tState = "4c"
				} Else {
					// Support escape sequences defined in RFC 4627, as well as \' and also \v because ^NLS "JS" mode does it on output
					Set tToken = tToken _ $Case(ch, "\": "\", "'": "'", """": """", "/": "/", "b": $char(8), "f": $char(12), "n": $char(10), "r": $char(13), "t": $char(9), "v": $char(11), : "\" _ ch)
					Set tState = 4
				}
			}
			ElseIf (tState = "4b") {
				// in \uXXXX escape sequence
				Set tUnicodeHex = tUnicodeHex _ ch
				If $length(tUnicodeHex) = 4 {
					// Check that we do actually have a Hex value
					If $$$MATCHHEXCHARS(tUnicodeHex,4) {
						Set tUnicodeDecimal = $zhex(tUnicodeHex)
						Set tToken = tToken _ $char(tUnicodeDecimal)
					} Else {
						Set tToken = tToken _ "\u" _ tUnicodeHex
					}
					Set tState = 4
				}
			}
			ElseIf (tState = "4c") {
				// in \xNN escape sequence
				Set tHex = tHex _ ch
				If $length(tHex) = 2 {
					// Check that we do actually have a Hex value
					If $$$MATCHHEXCHARS(tHex,2) {
						Set tCodeDecimal = $zhex(tHex)
						Set tToken = tToken _ $char(tCodeDecimal)
					} Else { // Not a hex escape
						Set tToken = tToken _ "\x" _ tHex
					}
					Set tState = 4
				}
			}
			ElseIf (tState = "2a") {
				// \ in property name
				If ch = "u" {
					Set tUnicodeHex = ""
					Set tState = "2b"
				} ElseIf ch = "x" {
					// add special case support for \xNN escape sequences that are valid in Javascript
					Set tHex = ""
					Set tState = "2c"
				} Else {
					// Support escape sequences defined in RFC 4627, as well as \' and also \v because ^NLS "JS" mode does it on output
					Set tToken = tToken _ $Case(ch, "\": "\", "'": "'", """": """", "/": "/", "b": $char(8), "f": $char(12), "n": $char(10), "r": $char(13), "t": $char(9), "v": $char(11), : "\" _ ch)
					Set tState = 2
				}
			}
			ElseIf (tState = "2b") {
				// in \uXXXX escape sequence
				Set tUnicodeHex = tUnicodeHex _ ch
				If $length(tUnicodeHex) = 4 {
					#; Check that we do actually have a Hex value
					If $$$MATCHHEXCHARS(tUnicodeHex,4) {
						Set tUnicodeDecimal = $zhex(tUnicodeHex)
						Set tToken = tToken _ $char(tUnicodeDecimal)
					} Else {
						Set tToken = tToken _ "\u" _ tUnicodeHex
					}
					Set tState = 2
				}
			} ElseIf (tState = "2c") {
				// in \xNN escape sequence
				Set tHex = tHex _ ch
				If $length(tHex) = 2 {
					#; Check that we do actually have a Hex value
					If $$$MATCHHEXCHARS(tHex,2) {
						Set tCodeDecimal = $zhex(tHex)
						Set tToken = tToken _ $char(tCodeDecimal)
					} Else { // Not a hex escape
						Set tToken = tToken _ "\x" _ tHex
					}
					Set tState = 2
				}
			}
		}
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

ClassMethod ParseJSONToGlobals(pJSON As %String, ByRef pArrOfGlobalNames As %String, pNodeName As %String = "^_", Output pCharsProcessed As %Integer, pLevel As %Integer = 1, pFirstChar As %String = "") As %Status
{
	Set tRaw = '$D(pArrOfGlobalNames)
	Set tSC = $$$OK, p=1, pCharsProcessed=0, tIO=$S('$IsObject(pJSON):"",1:+pJSON.%Extends("%IO.I.Stream"))
	While $$$ISOK(tSC) {
		// test end condition; get next character
		If $L(tIO) {
			Quit:pJSON.AtEnd
			Set ch = $S(tIO:pJSON.Read(1,,.tSC), 1:pJSON.Read(1,.tSC))  Quit:$$$ISERR(tSC)
		} Else {
			If (p > $L(pJSON)) Quit
			Set ch = $E(pJSON,p)
		}
		Set p = p + 1
		Set pCharsProcessed = pCharsProcessed + 1
		
		If ch = "}" {
			Quit:$D(tGlobalName)
			Set tSC = $$$ERROR($$$GeneralError,"Found unexpected }")  Quit
		}
		If ch = "{" || (ch = ",") {
			Set tGlobalName = ""
			While $$$ISOK(tSC) {
				// test end condition; get next character of Global name
				If $L(tIO) {
					Quit:pJSON.AtEnd
					Set tGlobalName = tGlobalName _ $S(tIO:pJSON.Read(1,,.tSC), 1:pJSON.Read(1,.tSC))  Quit:$$$ISERR(tSC)
				} Else {
					If (p > $L(pJSON)) Quit
					Set tGlobalName = tGlobalName _ $E(pJSON,p)
				}
				Set p = p + 1
				Set pCharsProcessed = pCharsProcessed + 1
				Quit:":"=$E(tGlobalName,*)
			}
			Set tGlobalName=$ZStrip($E(tGlobalName,1,*-1),"<>WC")
			Set:$Case($E(tGlobalName),"""":1,"'":1,:0) tGlobalName=$E(tGlobalName,2,*-1)
			If tRaw {
				Set pArrOfGlobalNames($I(pArrOfGlobalNames))=tGlobalName
				Set tSC = ..ParseJSONToGlobal(pJSON,tGlobalName,pNodeName,.tChars,1,"")
				Set pArrOfGlobalNames(pArrOfGlobalNames,"c") = tChars
			} Else {
				Set tMappedName = $G(pArrOfGlobalNames(tGlobalName),"<empty>")
				If $Case($E(tMappedName),"^":0,"%":0,:1) {
					Set tSC = $$$ADDSC(tSC,$$$ERROR($$$GeneralError,"Array name must start with % or ^.  Found '"_tMappedName_"' mapped from '"_tGlobalName_"'"))
					Set tMappedName = "^CacheTmp.JSONJunk"  // import but ignore
				}
				Set:$L(tMappedName)>32 $E(tMappedName,20,20+($L(tMappedName)-32)) = ""
				Set tSC = ..ParseJSONToGlobal(pJSON,tMappedName,pNodeName,.tChars,1,"")
				Set pArrOfGlobalNames(tGlobalName,"c") = tChars
				Set pArrOfGlobalNames(tGlobalName,"m") = tMappedName
				Set:tMappedName="^CacheTmp.JSONJunk" pArrOfGlobalNames(tGlobalName,"x") = 1
			}
			Set p = p + tChars
			Set pCharsProcessed = pCharsProcessed + tChars
		}
	}
	Quit tSC
}

ClassMethod LoadTrakLayout(pFile As %String = "", ByRef pGlobals) As %Status
{
	// Now, build a list of globals to export
	//Set pGlobals("^HS.Layout")="^TLayout"
	If $D(pGlobals)<=1 {
		Write "Collecting globals, please be patient ...",!
		Kill pGlobals
		Do ..findLayoutGlobals(.pGlobals)
		Set k="" For { Set k=$O(pGlobals(k))  Quit:""=k
			Set test("^"_$E(k,1,*-4))="^T."_$E(k,1,*-4)
		}
	} Else {
		Merge test = pGlobals
	}
	Set tStream = ##class(%IO.FileStream).%New(pFile), tStream.CharEncoding = "UTF8", tStream.BuildCharPosMap = 0
	Set tSC = ..ParseJSONToGlobals(tStream,.test)
	
	Set k="" For { Set k=$O(test(k))  Quit:""=k
		If '$G(test(k,"x")) {
			Set diff = $$compareArrays^EnsUtil(k,test(k,"m"))
			If ""'=diff Set tSC = $$$ADDSC(tSC,$$$ERROR($$$GeneralError,"Imported global differs from original global at '"_k_"'")), test(k,"e") = tSC
		}
	}
	Kill pGlobals  Merge pGlobals=test
	Quit tSC
}

/// s j={"Name":"Li,Robert K.","SSN":"672-92-9664","DOB":"1975-01-12","Home":{"Street":"986 Washington Blvd","City":"Boston","State":"PA","Zip":"95802"},"Office":{"Street":"6012 First Place","City":"Reston","State":"MT","Zip":"77739"},"Spouse":{"Name":"Avery,Zelda H.","SSN":"323-13-7437","DOB":"1943-03-27","Home":{"Street":"196 Main Drive","City":"Youngstown","State":"WY","Zip":"53229"},"Office":{"Street":"4056 Franklin Court","City":"Bensonhurst","State":"IA","Zip":"27688"},"FavoriteColors":["Black"],"Age":77},"Age":45,"Title":"Associate Marketing Manager","Salary":10421}
/// write ##class(apptools.util.json).ZPretty(j)
/// ZPretty ; make JSON readable
/// #; input= JSON string | stream | %DynamicAbstractObject
/// #; indent filler  ; "" => no indent         
/// #define fill "  "
/// #; New line code   ; "" => no Lines
/// #define crlf $c(13,10)
ClassMethod ZPretty(input, fil = "  ", nl = {$c(13,10)}) As %String
{
 q $$Do(input,fil,nl)
Do(input,fil,nl) public {
    set sc=1,res="",indt=""
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
    Q res 
    }
}

}

