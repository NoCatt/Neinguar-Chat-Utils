global function NeinguarChatColoursInit

table<string,int>ColourVals ={
["@green"] =  82,
["@red"] =    196,
["@blue"] =   51,
["@purple"] =128,
["@grey"] = 7,
["@black"] = 0,
["@white"] = 15,
["@orange"] = 208,
["@pink"] = 207
//["@aquamarine"] = 111 // place holder
}


bool MessageFilter = true
array<string> Banned_words = ["Faggot","Nigger"]
bool shouldBlock = true
bool shouldInform = true
string ResponseOnBlock = "Your message contains offensive speach and was not send to the chat"
bool ShouldShamePlayer = true
string ShameMessage = "I am really bad at this game but my mom doesnt buy me a new one"
string ResponseOnReplace = "Your message contains offensive speach and was altered"


void function NeinguarChatColoursInit() {
    AddCallback_OnReceivedSayTextMessage( AddChatColours )
    foreach (key,value in ColourVals) {
        printt("Registered: "+ key+ " with value: "+ value)
    }
    MessageFilter = GetConVarBool( "messageFilter" )
    shouldBlock = GetConVarBool( "shouldBlock" )
    shouldInform = GetConVarBool( "shouldInform" )
    ShouldShamePlayer = GetConVarBool( "shouldShame" )
    ResponseOnBlock = GetConVarString( "ResponseOnBlock" )
    ResponseOnReplace = GetConVarString( "ResponseOnReplace" )
    ShameMessage = GetConVarString( "ShameMessage" )
}

ClServer_MessageStruct function AddChatColours ( ClServer_MessageStruct message ){
    string LowerMessage  = message.message.tolower()
  string noSpaceMessage = StringReplace(message.message.tolower(), " ", "", true, true) // wow what a great way to write readable and cool code, anyway thats all the spaces removed
  if(MessageFilter){
    foreach(string word in Banned_words)
    {
        if( LowerMessage.find( word.tolower() ) == null && noSpaceMessage.find( word.tolower() ) == null)
            continue

        if(shouldBlock){
            message.shouldBlock = true
            if(shouldInform)
                Chat_ServerPrivateMessage(message.player , ResponseOnBlock , false)
            if(ShouldShamePlayer)
                Chat_Impersonate(message.player,ShameMessage,false)
            return message
        } else{
            message.message = StringReplace(LowerMessage, word.tolower(), GetAmoutOfStars(word), true, true)
            if(shouldInform)
                Chat_ServerPrivateMessage(message.player ,ResponseOnReplace   , false)
            if(ShouldShamePlayer)
                Chat_Impersonate(message.player, ShameMessage, false)
            return message
        }

    }
   }
    message.message = AddMessageHighlighting(message.message)
    return message
}

string function AddMessageHighlighting(string message) {
    array<string>SplitMessage = split(message, " ")
    foreach (i, string s in SplitMessage ){
        if( StringStartWith(s, "@") )
            SplitMessage[i] = AddColour(s)
    }
    return ArrayToString(SplitMessage)
}

string function AddColour(string s){
    string ReturnMessage = ""
    int colour = GetColourInt(s)
    if(colour == 69) return "\x1b[38;5;"+colour+"m" + s + "\x1b[0m"
    ReturnMessage = "\x1b[38;5;"+colour+"m" + RemoveColourDeclaration(s) 
    return ReturnMessage
}

string function RemoveColourDeclaration(string s){
    foreach(key, value in ColourVals)
        if(StringStartWith(s, key)) return StringReplace(s, key, "", true, true)
    return s
}


int function GetColourInt(string s){
    foreach(key,value in ColourVals)
        if(s.find(key)==0)return value
    return 69 
}

bool function StringStartWith(string s, string char){
    return (s.find(char) == 0) ? true:false
}

string function ArrayToString(array<string> args){
    string s = ""
    foreach(string word in args)
        s = s + word +" "
    return s
}

string function GetAmoutOfStars(string word) {
    string reply = ""
    for (int a; a < word.len() ; a++ ) {
     reply = reply + "*"
    }
    return reply
}