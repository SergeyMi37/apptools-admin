/// Utilities for working in Telegram
Class apptools.core.telebot [ Abstract ]
{

ClassMethod TS(val = "") As %String
{
	set ret=$zts
	quit $ZDT($NOW()+0,3,1,3)_" "_##class(apptools.core.type).GetValidZT($h)_" "_ret_" --- "_$zu(110)_" "_$zv
}

ClassMethod GetMe(botId) As %DynamicObject
{
	s ret=..ExecuteRequest(..GetRequestObj(), "getMe",botId)
	q ret
}

/// $wc($zhex("1F6A8"))	;U+0038 U+20E3 =8;  U+0031 U+20E3 =1 ;* U+2744 snow  X - $wc($zhex("274C"))  ;https://apps.timwhitlock.info/emoji/tables/unicode
/// w ##class(apptools.core.telebot).Send(5111112,"13333333:AHEАWAASDDDpepSSAA","Not recognized !!! Пример кириллицы "_$wc($zhex("1F6A8")))
ClassMethod Send(chatId As %String, botId, text As %String, obj = 0) As %Integer
{
	if (obj'=0) {
		;set obj = {"remove_keyboard":true}
		set res = ..SendMessage(chatId,text,botId,obj)
	} else {
		set res = ..SendMessage(chatId,text,botId)
	}
	
	if (res.ok) {
		return res.result."message_id"
	}
	return $$$ERROR($$$GeneralError, "Error while sending a message")
}

ClassMethod GetRequestObj() As %Net.HttpRequest
{
	#dim request as %Net.HttpRequest
	set request = ##class(%Net.HttpRequest).%New()
	set request.Server = "api.telegram.org"
	set request.SSLConfiguration = ..CheckSSLCertificate("TelegramSSL")
	set request.Https = 1 
	return request
}

ClassMethod ExecuteRequest(request As %Net.HttpRequest, method As %String, botId = "") As %DynamicObject
{
	set st = request.Post("bot"_botId_"/"_method)
	if ($$$ISERR(st)) {
		throw ##class(%Exception.StatusException).CreateFromStatus(st)
	}
	return ##class(%Library.DynamicObject).%FromJSON(request.HttpResponse.Data)
}

ClassMethod SendMessage(chatId As %Integer, text As %String, botId, replyMarkup As %DynamicObject = 0) As %DynamicObject
{
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	do request.InsertFormData("chat_id",chatId)
	do request.InsertFormData("text",text)
	do request.InsertFormData("parse_mode","HTML") ;HTML ;MarkdownV2 ;Markdown https://core.telegram.org/bots/api#markdownv2-style
	
	if (replyMarkup'=0) {
		do request.InsertFormData("reply_markup",replyMarkup.%ToJSON())
	}
	return ..ExecuteRequest(request, "sendMessage",botId)
}

ClassMethod GetUpdates(botId, offset As %Integer = "", limit As %Integer = 100, timeout As %Integer = 0) As %DynamicObject
{
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	if (offset'="") {
		do request.InsertFormData("offset",offset)
	}
	do request.InsertFormData("limit",limit)
	do request.InsertFormData("timeout",timeout)
	return ..ExecuteRequest(request, "getUpdates",botId)
}

/// The method checks for the existence of the configured SSL configuration
/// and creates an empty configuration with that name if this yet
/// to connect to a https server, that's enough
ClassMethod CheckSSLCertificate(name) As %String
{
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  
  IF '##class(Security.SSLConfigs).Exists(name) {
    DO ##class(Security.SSLConfigs).Create(name)
  }
  QUIT name
}

}

