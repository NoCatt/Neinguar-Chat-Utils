# Neingaur Chat Utils

This server side mod allows you the server owner to blacklist words, those word are either cencored or the entire message is blocked, you can change those settings in the convars
#
shouldBlock is a boolean for wether you would like to block message with one (or more) of the offensive words, if this is set to false the message will be sent to the chat but it will replace the word with "*" <br />
#
ShouldInformPlayer is a boolean that determins if the player who has send the message with an offensive word gets notified of the block/alteration of their message <br />
#
ResponseOnBlock is the message the player will recive if Block is true and ShouldInformPlayer is true <br />
#
ResponseOnReplace is the message that the player will get if Block is false and ShouldInfromPlayer is true <br />
#
ShouldShameUnfriendlyPlayer is a boolean that determines if a message is sent to the chat that looks like the player who wrote the offensive message send <br />
#
MessageToShamePlayers is the message that will look like the player who send the original offensive message wrote, preferable this should make them look bad <br />
#
The Mod also allows players to type in colours, this is achieved by them typing @colour-name and then their text <br />
With only the @ symbol they can make one word blue, this is supposed to be used for names