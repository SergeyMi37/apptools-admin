Include apptools.core

/// 404 not found
Class apptools.lte.page404 Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "404 Page not found";

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set path=par("=path=")
 set par("=Brand-Text=")="404 Page not found"
 set par("=Logo-image=")=path_"adminlte/dist/img/ApptoolsLogo.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"adminlte/dist/img/ApptoolsLogo","png")
 set par("=Message-default=")="Error 404: class "_$GET(par("input-class="))_" not found "
 set par("=Tab=")="Error"
 quit ..RepaceParameter(.h, .par)
 quit $$$OK
}

/// what modes are available
ClassMethod GetAllApps(opt) As %Status
{
 	quit $$$OK
}

}

