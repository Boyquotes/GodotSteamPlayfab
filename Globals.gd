extends Node

#Steam Variables
var OWNED = false
var ONLINE = false
var STEAM_ID = 0
var STEAM_NAME = ""
#Lobby Variables
var DATA
var LOBBY_ID = 0
var LOBBY_MEMBERS = []
var LOBBY_INVITE_ARG = false

func _ready():
	var INIT = Steam.steamInit()
	if INIT['status'] != 1:
		print('Failed to initialise Steam. ' + str(INIT['verbal']) + "Shutting down...")
		get_tree().quit()
		
	ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()
	OWNED = Steam.isSubscribed()
	
	if not OWNED:
		print("User does not own this game")
		get_tree().quit()
		
	print("User %s logged in successful" % STEAM_ID)
		
func _process(delta):
	Steam.run_callbacks()
