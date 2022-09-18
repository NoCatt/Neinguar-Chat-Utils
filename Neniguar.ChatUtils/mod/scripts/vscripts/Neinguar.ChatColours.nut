untyped

global function NeinguarChatColoursInit

table<string,int>ColourVals ={
["@green"] =  82,
["@red"] =    196,
["@blue"] =   51,
["@purple"] = 128,
["@grey"] =   244,
["@gray"] =   244,
["@black"] =  0,
["@white"] =  15,
["@orange"] = 208,
["@pink"] =   207,
["@yellow"] = 11
}

array<string> Banned_words = []
array<string> AdminNames = []
array<string> HostNames = []

bool MessageFilter = true
bool shouldBlock = true
bool shouldInform = true
bool ShouldShamePlayer = true
bool AnnounceAdmin
bool AnnounceHosts

string ResponseOnBlock = "Your message contains offensive speach and was not send to the chat"
string ShameMessage = "I am really bad at this game but my mom doesnt buy me a new one"
string ResponseOnReplace = "Your message contains offensive speach and was altered"


string RGB_OPEN
string RGB_CLOSE
string RGB_DIVIDE


void function NeinguarChatColoursInit() {
    AddCallback_OnReceivedSayTextMessage( AddChatColours )
    AddCallback_OnClientConnected(OnClientConnected)
    foreach (key,value in ColourVals) {
        printt("Registered: "+ key+ " with value: "+ value)
    }

    Banned_words = GetConVarStringArray("BannedWords")
    AdminNames = GetConVarStringArray("AdminNames")
    HostNames =  GetConVarStringArray("HostNames")


    MessageFilter = GetConVarBool( "messageFilter" )
    shouldBlock = GetConVarBool( "shouldBlock" )
    shouldInform = GetConVarBool( "shouldInform" )
    ShouldShamePlayer = GetConVarBool( "shouldShame" )
    AnnounceAdmin = GetConVarBool("AnnounceAdmin")
    AnnounceHosts = GetConVarBool("AnnounceHost")

    ResponseOnBlock = GetConVarString( "ResponseOnBlock" )
    ResponseOnReplace = GetConVarString( "ResponseOnReplace" )
    ShameMessage = GetConVarString( "ShameMessage" )

    RGB_OPEN = GetConVarString("FSU_RGB_OPEN") // stole that from my mod of FSU thus the name, i still made it 
    RGB_CLOSE = GetConVarString("FSU_RGB_CLOSE")
    RGB_DIVIDE = GetConVarString("FSU_RGB_DIVIDE")
}

ClServer_MessageStruct function AddChatColours ( ClServer_MessageStruct message ){
string LowerMessage  = message.message.tolower()
  string noSpaceMessage = StringReplace(message.message.tolower(), " ", "", true, true) // wow what a great way to write readable and cool code, anyway thats all the spaces removed
  bool OnOffense = false
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
            message.message = StringReplace(message.message.tolower(), word.tolower(), GetAmoutOfStars(word), true, true)
            OnOffense = true
            continue
        }

    }
    if(OnOffense){ // so that it filters out all the bad words and only get 1 message not like 5
        if(shouldInform)
            Chat_ServerPrivateMessage(message.player ,ResponseOnReplace   , false)
        if(ShouldShamePlayer)
            Chat_Impersonate(message.player, ShameMessage, false)
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
    bool IsRGB = IsTextColoursRGB(s)
    if(IsRGB){
     array<int> RGB = ExtraxtRGBVal(s)
     if(RGB.len()== 0)
      return s
     ReturnMessage = "\x1b[38;2;"+RGB[0] +";"+RGB[1]+";"+RGB[2]+"m" + RemoveRGBDeclaration(s)
    }
    else{
      int colour = GetColourInt(s)
      if(colour == 69) return "\x1b[38;5;"+colour+"m" + s + "\x1b[0m"
      ReturnMessage = "\x1b[38;5;"+colour+"m" + RemoveColourDeclaration(s) 
    }
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

array<string> function GetConVarStringArray(string convar){
    return split(GetConVarString(convar), ",")
}

void function OnClientConnected(entity player){
    if( HostNames.find( player.GetPlayerName() ) !=-1 && AnnounceHosts){
        Chat_ServerBroadcast("The server host: \x1b[38;5;51m"+player.GetPlayerName()+"\x1b[0m just joined the server")
        return
    }
    if( AdminNames.find( player.GetPlayerName() ) !=-1 && AnnounceAdmin){
        Chat_ServerBroadcast("A server admin: \x1b[38;5;51m"+player.GetPlayerName()+"\x1b[0m just joined the server")
        return
    }
        
}

bool function IsTextColoursRGB(string s){
  // s should be of @(r,g,b)Text 
  if(s.find(RGB_OPEN) == 1)
    return true
  return false
}

array<int> function ExtraxtRGBVal(string s){
  try{
  var startIndex = s.find( RGB_OPEN )
  var endIndex = s.find( RGB_CLOSE)
  if( !startIndex || !endIndex)
    return []
  string sub = s.slice( expect int(startIndex)+1, expect int(endIndex) )
  array<string> splitted = split(sub, RGB_DIVIDE)
  int r = splitted[0].tointeger()
  int g = splitted[1].tointeger()
  int b = splitted[2].tointeger()
  array<int>ReturnArray = [r,g,b]
  foreach(indx,int colour in ReturnArray){
    if(colour > 255)
      ReturnArray[indx] = 254
    if(colour < 0)
      ReturnArray[indx] = 0
  }
  return ReturnArray
  }
  catch(ex){
    return[]
  }
}

string function RemoveRGBDeclaration(string s){
  if(s.find(RGB_CLOSE)== null)
    return s
  return s.slice(s.find(RGB_CLOSE)+1)
}