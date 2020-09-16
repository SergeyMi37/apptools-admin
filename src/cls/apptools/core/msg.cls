Include apptools.core

Class apptools.core.msg [ Abstract ]
{

/// Add two languages to global translation
/// Samples ##Expression(##class(apptools.core.sys).AddLangMsg(%en,%ru))
ClassMethod AddLangMsg(en, other) As %String
{
	s otherLang="ru"
	;s @$$$GNLang@($$$GNLangDOMAIN) = otherLang
	s @$$$GNLang@($$$GNLangDOMAIN,"en",$zcrc(en,7)) = en
	s:other'="" @$$$GNLang@($$$GNLangDOMAIN,otherLang,$zcrc(en,7)) = other
	q "$s("_$zcrc(en,7)_":$g("_$$$GNLang_"("""_$$$GNLangDOMAIN_""",$get("_$$$GNEnsConf_"(""Language""),$mvv(58)),"_$zcrc(en,7)_"),"""_en_"""),1:"""_other_""")"
}

/// Get description of parameters, propertis or methodes
/// write ##class(apptools.core.msg).man("apptools.Tabs.security).LockDown")
/// do ##class(apptools.core.msg).man("apptools.core.Log",.doc) zw doc ;# get full class description 
ClassMethod man(ClassNameItem, ByRef d) As %String
{
	set cn=$p(ClassNameItem,")")
	q:cn="" ""
	set item=$p(ClassNameItem,").",2)
	do ##class(apptools.core.LogInfoPane).GetClassDef(cn,"",.d,0)
	if item="" q $g(d("ClassName",cn))
	for it="Methods","Properties","Parameters"	if $g(d(it,item,"Description"))'="" s ret=$g(d(it,item,"Description"))
	q $g(ret)
}

}

