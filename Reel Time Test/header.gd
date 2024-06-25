extends PanelContainer


func _update_banner_text(new_text):
	$Header/WelcomeBannerText.visible = false
	$Header/BannerText.visible = true
	$Header/BannerText/BannerText.text = new_text
	
func _ready():
	Server.connect("users_balance_updated", update_users_balance_onscreen)

func update_users_balance_onscreen():
	$Header/HBoxContainer2/VBoxContainer/Label2.text = str(Server.users_balance)
