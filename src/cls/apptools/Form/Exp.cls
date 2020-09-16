Include apptools.core

Class apptools.Form.Exp Extends apptools.core.AutoPage
{

Parameter CSPURL = "apptools.Form.Exp.cls";

Parameter PAGENAME = "Objects Explorer";

Parameter PARENTPAGE = "apptools.core.AutoPage.cls";

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	quit ##class(apptools.Form.Explorer).%New()
}

}

