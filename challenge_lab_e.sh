#!/bin/bash

# Detta program använder sig av dialog för att skapa dialogrutor istället för
# att administratören manuellt ska mata in alla kommandon via shell.
# Redirections av felmeddelande till /dev/null används ofta för att få
# bort irriterande blinkande meddelanden i botten av skärmen vid körning
# av dialog. 
#
# Redirection av STDERR används om det utdata från ett kommando antingen
# ska sättas in i en variabel eller om kommandot som körs inte genererar
# ett meddelande vid lyckad körning. "No news is good news".
#
# Redirection av både STDERR och STDOUT görs när ett kommando ger utdata vid
# både lyckad och misslyckad körning, men redirection på detta sätt används 
# INTE tillsammans med variabler.
#
# Nedan följer alla funktioner. Längst ned hittas huvudmenyn

function uname_check { # KLAR. ETT ARGUMENT
	# Kontrollerar om användarnamnet är godkänt enligt manualen för useradd.
	# Om inte, skriv felmeddelande i dialog och returnera 1.
	if echo "$1" | grep -Ee "^[a-z_][a-z0-9_-]*\$?" &> /dev/null; then
		return 0
	fi
	dialog --title "Error" \
		--clear \
		--msgbox "\"$1\" is not a valid username." 9 38
	return 1
}

function uname_exists { # KLAR. ETT ARGUMENT
	# Kontrollerar om användarnamnet redan finns i systemet.
	# Om inte, returnera 1.
	if cut /etc/passwd -f1 -d: | grep -x "$1" &> /dev/null; then 
		return 0
	fi
	return 1
}

function uname_exist_mess { # KLAR. TVÅ ARGUMENT
	# Första argumentet är namnet som ska skrivas i felmeddelandet.
	# Andra argumentet avgör vilket meddelande som ska skrivas ut.
	case "$2" in
	0)	dialog --title "Error" \
			--clear \
			--msgbox "Username \"$1\" doesn't exist." 9 38 ;;
	1)	dialog --title "Error" \
			--clear \
			--msgbox "Username \"$1\" already exists." 9 38 ;;		
	*)	return 1 ;;
	esac
	return 0
}

function gname_check { # KLAR. ETT ARGUMENT
	# Kontrollerar om namnet är godkänt enligt manualen för groupadd.
	# Om inte, skriv felmeddelande och returnera 1.
	if echo "$1" | grep -Ee "^[a-z_][a-z0-9_-]*\$?" &> /dev/null; then
		return 0
	fi
	dialog --title "Error" \
		--clear \
		--msgbox "\"$1\" is not a valid group name." 9 38
	return 1
}

function gname_exist { # KLAR. ETT ARGUMENT
	# Om gruppnamnet finns, returnera 0. Annars returnera 1.
	if cut /etc/group -f1 -d: | grep -x "$1" &> /dev/null; then
		return 0
	fi
	return 1
}

function gname_exist_mess { # KLAR. TVÅ ARGUMENT
	# Utskrift av felmeddelanden.
	# Första argumentet är namnet som ska skrivas i felmeddelandet.
	# Andra argumentet avgör vilket meddelande som ska skrivas ut.
	case "$2" in
		0)	dialog --title "Error" \
				--clear \
				--msgbox "Group \"$1\" doesn't exist." 9 38 ;;
		1)	dialog --title "Error" \
				--clear \
				--msgbox "Group \"$1\" already exists." 9 38 ;;
		*)	return 1 ;;
	esac
	return 0
}

function form_check { # KLAR. TVÅ ARGUMENT
	# Kontrollerar att alla fält är ifyllda i en form som används av dialog.
	# Tar två argument. Informationen och antalet fält.
	if [ $(echo "$1" | wc -l) -lt "$2" ]; then
		dialog --title "Error" \
			--clear \
			--msgbox "Insufficient data in the fields. Exiting." 8 38
		return 1
	fi
	return 0
}

function trail_fslash_rem { # KLAR. ETT ARGUMENT. SKICKAR TILLBAKA DEN NYA STRÄNGEN.
	# Tar bort forwars slash på slutet, om sådant finns.
	# Använder sedan echo för att skicka tillbaka den modifierade strängen.
	if echo "$1" | grep /$ &> /dev/null && [ $(echo "$1" | wc -c) -gt 2 ]; then
		CHAR_COUNT=$(echo "$1" | wc -c)
		(( CHAR_COUNT -= 2 ))
		NEWVAR=$(echo "$1" | cut -c-"$CHAR_COUNT")
		echo "$NEWVAR"
	else
		echo "$1"
	fi
}

function group { # KLAR
	# Menyval i gruppalternativ
	INPUT=$(dialog --title "Group menu" \
			--clear \
			--output-fd 1 \
			--cancel-label "Exit" \
			--menu "Select a group option below." 12 60 5 \
			'Add' "Create a new group" \
			'Remove' "Remove a group" \
			'List' "List system groups" \
			'View' "List user associations for group" \
			'Modify' "Modify user memberships of groups")
		# Knapptryckscase
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	case "$INPUT" in
		Add) group_add ;;
		Remove) group_remove ;;
		List) group_list ;;
		View) group_view ;;
		Modify) group_modify ;;
	esac
}

function user { # KLAR
	# Menyval i användaralternativ
	INPUT=$(dialog --title "User menu" \
			--clear \
			--output-fd 1 \
			--cancel-label "Exit" \
			--menu "Select a user option below." 12 60 5 \
			'Add' "Create a user" \
			'Remove' "Remove a user" \
			'List' "List system users" \
			'View' "View specific user properties" \
			'Modify' "Modify user properties")
	# Knapptryckscase
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	case "$INPUT" in
		Add) user_add ;;
		Remove) user_remove ;;
		List) user_list ;;
		View) user_view ;;
		Modify) user_modify ;;
	esac
}

function folder { # KLAR
	# Menyval i mappalternativ
	INPUT=$(dialog --title "Folder menu" \
		--clear \
		--output-fd 1 \
		--cancel-label "Exit" \
		--menu "Select a folder option below." 12 60 5 \
		'Add' "Create a new folder" \
		'Remove' "Remove a folder" \
		'List' "View folder contents" \
		'View' "View folder attributes" \
		'Modify' "Modify folder attributes")
	
	# Knapptryckscase
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	case "$INPUT" in
		Add) folder_add ;;
		Remove) folder_remove ;;
		List) folder_list ;;
		View) folder_view ;;
		Modify) folder_modify ;;
	esac			
}

function group_remove { # KLAR
	# Tar bort en vald grupp
	INPUT=$(dialog --title "Remove group" \
		--clear \
		--output-fd 1 \
		--inputbox "Enter the groupname of the group you want to remove" 10 10)
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	groupdel "$INPUT" &> /dev/null
	
	# Case för olika felkoder.
	case $? in
		0) dialog --title "Success!" \
				--msgbox "The group \"$INPUT\" has now been removed successfully" 9 30 ;;
		6) dialog --title "Error" \
				--msgbox "The group \"$INPUT\" doesn't exist." 9 30 ;;
		8) GID_OUTPUT=$(grep ^"$INPUT" /etc/group | cut -f3 -d: 2> /dev/null)
			OUTPUT_P=$(cut /etc/passwd -f1,4 -d: | grep "$GID_OUTPUT" | cut -f1 -d: 2> /dev/null)
			dialog --title "Error" \
				--msgbox "The group \"$INPUT\" is the primary group of:\n$OUTPUT_P\n\nNo deletion is done." 15 35 ;;
		*) dialog --title "Error" \
				--msgbox "Something went wrong" 9 30 ;;
	esac
}

function user_remove { # KLAR
	# Tar bort en användare.
	INPUT=$(dialog --title "Remove user" \
		--clear \
		--output-fd 1 \
		--inputbox "Enter the username of the user you want to remove" 10 10)
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	userdel -r "$INPUT" &> /dev/null
	# Case för olika felkoder
	case $? in
		0) dialog --title "Success!" \
				--msgbox "The user \"$INPUT\" has now been removed successfully" 9 30 ;;
		6) dialog --title "Error" \
				--msgbox "The user \"$INPUT\" doesn't exist." 9 30 ;;
		8) dialog --title "Error" \
				--msgbox "The user \"$INPUT\" is currently logged in. Cannot remove user." 9 30 ;;
		*) dialog --title "Error" \
				--msgbox "Something went wrong." 9 30 ;;
	esac
}

function folder_remove { # KLAR
	# Tar bort en mapp.
	FOLDER=$(dialog --title "Remove user" \
	--clear \
	--output-fd 1 \
	--dselect / 10 10)
	case $? in
	1) return ;;
	255) return ;;
	esac
	
	# Är det en mapp? Om NEJ, gå ur funktionen.
	if ! [ -d "$FOLDER" ]; then
		dialog --title "Error" \
			--msgbox "The folder \"$FOLDER\" doesn't exist." 8 30
			return
	fi
	
	rmdir "$FOLDER" &> /dev/null
	# Case för olika felkoder.
	# Ber också att admin bekräftar borttagning av en mapp som innehåller något.
	case $? in
	0) dialog --title "Success!" \
			--msgbox "The user \"$FOLDER\" has been removed successfully." 9 30 ;;
	1) dialog --title "Error" \
			--yesno "The folder \"$FOLDER\" isn't empty. Are you sure you want to remove it?" 9 30
		case $? in
			0) rm -rf "$FOLDER" &> /dev/null
				dialog --title "Success!" \
					--msgbox "The folder \"$FOLDER\" has been removed successfully." 9 30 ;;
			1) dialog --title "Aborted"
					--msgbox "Folder \"$FOLDER\" was not removed" 9 30 ;;
			255) dialog --title "Aborted"
					--msgbox "Folder \"$FOLDER\" was not removed" 9 30 ;;
		esac ;;
	esac
}

function group_add { # KLAR
	# Lägger till en grupp i systemet.
	while true; do
		INPUT=$(dialog --title "Add a group" \
			--cancel-label "Exit" \
			--output-fd 1 \
			--clear \
			--inputbox "Enter a group name for the group you wish to add to the system.\n\nThe group name must start with a letter or underscore and contain no spaces or special characters" 12 60)

		# Kontrollerar att inmatningen är korrekt. Denna används senare i en annan funktion, så därför måste den finnas med
		# även om groupadd har inbyggd kontroll.
		case $? in
			0)	if ! gname_check "$INPUT"; then
					break
				fi ;;
			1) break ;;
			255) break ;;
		esac
		
		# Skapa grupp med det inmatade gruppnamnet.
		# Använd returvärdet för olika meddelanden.
		groupadd "$INPUT" 2> /dev/null
		case $? in
			0)	dialog --title "Success" \
					--clear \
					--msgbox "Group \"$INPUT\" successfully added" 8 38 ;;
			9)	gname_exist_mess "$INPUT" "1" ;;
			*) dialog --title "Error" \
					--clear \
					--msgbox "Something went wrong. Failed to create group" 8 30 ;;
		esac
	done
}

function group_list { # KLAR
	# Listar alla grupper i systemet genom att klippa i /etc/group.
	GROUPLIST=$(cut /etc/group -f1 -d: 2> /dev/null)
	dialog --title "List system groups" \
		--clear \
		--msgbox "$GROUPLIST" 30 30
}

function group_view { # KLAR
	# Visar information om en viss grupp i systemet.
	# Användaren skriver in information i ett fält som
	# sedan skickas till en variabel som används på olika sätt.
	while true; do
		INPUT=$(dialog --title "List users associated with the specified group." \
			--cancel-label "Exit" \
			--output-fd 1 \
			--clear \
			--inputbox "Specify the group you wish to view user associations for." 9 60)

		# Kontrollerar knapptryckning. Om 0 (OK), kalla på funktionen och om den returnerar 0, break.
		case $? in
			0)	if ! gname_check "$INPUT"; then
					break
				fi ;;
			1) break ;;
			255) break ;;
		esac

		# Kontrollerar om gruppen finns. Om ja, gå vidare och visa informationen
		# genom användningen av olika variabler. Primary och supplementary groups
		# stoppas in i olika variabler som används för visning i dialog.
		gname_exist "$INPUT"
		case $? in
			0) GID_OUTPUT=$(grep ^"$INPUT" /etc/group | cut -f3 -d: 2> /dev/null)
				OUTPUT_P=$(cut /etc/passwd -f1,4 -d: | grep "$GID_OUTPUT" | cut -f1 -d: 2> /dev/null)
				OUTPUT_S=$(grep ^"$INPUT" /etc/group | cut -f4 -d: | tr "," "\n" 2> /dev/null)
				dialog --title "Success" \
					--cr-wrap \
					--clear \
					--msgbox "Group: \"$INPUT\"\n\nPrimary group user: \n$OUTPUT_P\n\nSupplementary group user: \n$OUTPUT_S" 15 30 ;;
			1) gname_exist_mess "$INPUT" 0 ;;
			2) dialog --title "Error" \
					--clear \
					--msgbox "Something went wrong." 8 30 ;;
		esac
	done
}

function group_modify { # KLAR
	# Menyval för modifiering av medlemskap i grupper.
	# Admin väljer att ta bort eller lägga till medlemskap.
	INPUT=$(dialog --title "Modify group memberships" \
		--cancel-label "Exit" \
		--clear \
		--output-fd 1 \
		--menu "Select an option below:" 9 30 2 \
		'Add membership' "" \
		'Remove membership' "")
	
	case $? in
		1) return ;;
		255) return ;;
	esac

	case "$INPUT" in
		"Add membership") supp_group_add ;;
		"Remove membership") supp_group_remove ;;
	esac
}

function supp_group_add { # KLAR
	# Denna funktion lägger till supplementary groups till en specificerad användare.
	# Den nollställer även variabler innan dessa används.
	UNAME=""
	GROUP_NAME=""
	
	INPUT=$(dialog --title "Add membership" \
		--cancel-label "Exit" \
		--output-fd 1 \
		--clear \
		--form "Enter a group name and a username you wish to add to the group" \
		10 43 2 \
		"Supp. Group  :" 1 1 ""	1 17 20 0 \
		"Username     :" 2 1 ""	2 17 20 0)
		
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	# Kontroll av att alla fält är ifyllda. Om INTE, return.
	if ! form_check "$INPUT" 2; then
		dialog --title "Error" \
		--msgbox "Error form check" 8 35
		return
	fi
	
	# Läger till det inmatade gruppnamnet i en variabel och kontrollerar
	# om det är godkänt och om det redan finns.
	# Om någon INTE någon av funktionerna returnerar 0, gå ur funktionen.
	GROUP_NAME=$(echo "$INPUT" | head -1 2> /dev/null)
	if ! gname_check "$GROUP_NAME"; then
		return
	elif ! gname_exist "$GROUP_NAME"; then
		gname_exist_mess "$GROUP_NAME" 0
		return
	fi

	# Lägger till det inmatade användarnamnet i en variabel och kontrollerar
	# om det är godkänt och om det redan finns.
	# Om någon av funktionerna INTE returnerar 0, gå ur funktionen.
	UNAME=$(echo "$INPUT" | head -2 | tail -1 2> /dev/null)
	if ! uname_check "$UNAME"; then
		return
	elif ! uname_exists "$UNAME"; then
		uname_exist_mess "$UNAME" 0
		return
	fi
		
	# Lägger till användaren i gruppen. Om det misslyckas, skriv ut errormeddelande.
	usermod -aG "$GROUP_NAME" "$UNAME"
	case $? in
		0) dialog --title "Success" \
				--clear \
				--msgbox "User \"$UNAME\" successfully joined group \"$GROUP_NAME\"" 8 38 ;;
		*) dialog --title "Error" \
				--clear \
				--msgbox "Something went wrong." 8 38 ;;
	esac
}

function supp_group_remove { # KLAR.
	# Denna funktion tar bort en supplementary group från en specificerad användare.
	# Nollställer variabler innan påbörjad operation.
	UNAME=""
	GROUP_NAME=""
	INPUT=$(dialog --title "Remove membership" \
		--cancel-label "Exit" \
		--output-fd 1 \
		--clear \
		--form "Specify a supplementary group from which you want to remove a specified user." \
		10 43 2 \
		"Supp. Group  :" 1 1 ""	1 17 20 0 \
		"Username     :" 2 1 ""	2 17 20 0)
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	# Kontroll av att fält är ifyllda. Om INTE, return.
	if ! form_check "$INPUT" 2; then
		dialog --title "Error" \
		--msgbox "Error form check" 8 35
		return
	fi
	
	# Läger till det inmatade gruppnamnet i en variabel och kontrollerar
	# om det är godkänt och om det redan finns.
	# Om någon INTE någon av funktionerna returnerar 0, gå ur funktionen.
	GROUP_NAME=$(echo "$INPUT" | head -1 2> /dev/null)
	if ! gname_check "$GROUP_NAME"; then
		return
	elif ! gname_exist "$GROUP_NAME"; then
		gname_exist_mess "$GROUP_NAME" 0
		return
	fi
	
	# Lägger till det inmatade användarnamnet i en variabel och kontrollerar
	# om det är godkänt och om det redan finns.
	# Om någon av funktionerna INTE returnerar 0, gå ur funktionen.
	UNAME=$(echo "$INPUT" | head -2 | tail -1 2> /dev/null)
	if ! uname_check "$UNAME"; then
		return
	elif ! uname_exists "$UNAME"; then
		uname_exist_mess "$UNAME" 0
		return
	fi
	
	PRIMARY_GROUP=$(id -ng "$UNAME")
	# Kontrollerar att den valda gruppen inte är primary group för den valda användaren.
	# Om så är fallet, skriv felmeddelande och gå ur funktionen.
	if [ "$GROUP_NAME" = "$PRIMARY_GROUP" ];then
			dialog --title "Error" \
				--clear \
				--msgbox "Group \"$GROUP_NAME\" is the primary group of the user \"$UNAME\". Exiting." 8 30
		return
	fi
	
	# GROUP_COUNT innehåller antalet supplementary groups som en användare ska vara med i efter en lyckad operation.
	# Utför också aritmetik.
	# Aritmetik: (antalet grupper - primary group - en supplementary group). Används senare i "cut" med flaggan för fält.
	# Om antalet grupper är fler än 0, utför if-satsen, annars skriv felmeddelande.
	GROUP_COUNT=$(($(id -nG "$UNAME" | wc -w 2> /dev/null) - 2))
	if [ "$GROUP_COUNT" -ge 0 ]; then
		# GROUPLIST innehåller de grupper minus det gruppnamn som vi har valt att ta bort från användaren.
		# Listar alla grupper en användare är medlem i. 
		# Klipper ut fälten med supplementary groups. 
		# Översätter space till newline.
		# Tar bort den gruppen som användaren inte ska vara med i längre.
		# Översätter newline till kommatecken för att vara kompatibelt med usermod.
		# Tar bort överblivet kommatecken med hjälp av GROUP_COUNT från tidigare.
		GROUPLIST=$(id -nG "$UNAME" | cut -f2- -d" " | tr " " "\n" | grep -v "$GROUP_NAME" | tr "\n" "," | cut -f1-"$GROUP_COUNT" -d"," 2> /dev/null)

		# Slutresultat. Sätt alla supplementary groups till användaren.
		# Om det blir fel med usermod, skriv felmeddelande. Annars skriv output.
		usermod -G "$GROUPLIST" "$UNAME"
		case $? in
			0) dialog --title "Success" \
					--clear \
					--msgbox "Membership in \"$GROUP_NAME\" successfully removed from user \"$UNAME\"." 8 38 ;;
			*) dialog --title "Error" \
					--clear \
					--msgbox "Something went wrong." 8 38 ;;
		esac
	else
		dialog --title "Error" \
			--clear \
			--msgbox "User \"$UNAME\" is not a member of any supplementary groups." 8 38
	fi
}

function user_add { # KLAR
	# Denn funktion lägger till en användare i systemet.
	while true; do
		UNAME=$(dialog --title "Add a user" \
			--cancel-label "Exit" \
			--output-fd 1 \
			--clear \
			--inputbox "Enter a username for the user you wish to add to the system.\n\nThe username must start with a letter or underscore and contain no spaces or special characters" 11 60)

		# Kontrollera vilken knapp användaren trycker på. 
		# Om "Exit" eller "Escape" trycks in så återvänder programmet till huvudmenyn.
		case $? in
			0)	if ! uname_check "$UNAME"; then
					break
				fi ;;
			1) break ;;
			255 ) break ;;
		esac

		# Lägger till användare till systemet med en egen hemkatalog och /bin/bash som standardshell.
		# Om detta inte går, skriv felmeddelande.
		useradd -s /bin/bash -m "$UNAME" 2> /dev/null
		case $? in
			0) dialog --title "Success" \
					--clear \
					--msgbox "User \"$UNAME\" successfully added" 8 38 ;;
			9) dialog --title "Error" \
					--clear \
					--msgbox "Username already exists or the group \"$UNAME\" already exists. Choose another username." 8 38 ;;
			*) dialog --title "Error" \
					--clear \
					--msgbox "Something went wrong." 8 38 ;;
		esac
	done
}

function user_list { # KLAR
	# Listar alla användare i systemet.
	INPUT=$(cut /etc/passwd -f1 -d: 2> /dev/null)
	dialog --title "List users" \
		--clear \
		--msgbox "$INPUT" 30 30
}

function user_view { # KLAR
	# Visar information om en vald användare.
	while true; do
		UNAME=$(dialog --title "List user information." \
			--cancel-label "Exit" \
			--output-fd 1 \
			--clear \
			--inputbox "Specify the user you wish to list the information of." 10 30)

		# Kontrollerar knapptryckning. Om Ok, fortsätt med funktionen, annars går funktionen ur loopen
		# och tillbaka till huvudmenyn. Kontrollerar också om godkända karaktärer används.
		case $? in
			0) if ! uname_check "$UNAME"; then
					break
				fi ;;
			1) break ;;
			255 ) break ;;
		esac

		# Kontrollerar om användaren finns. Om ja, fortsätt med funktionen. Annars skriv error och tvinga användaren att skriva in det igen.
		id "$UNAME" &> /dev/null
		case $? in
			0) # Specificera alla nödvändiga variabler.
				# Klipepr ut olika delar av /etc/passwd och greppar så att
				# informationen kan visas i ett meddelande på ett snyggt sätt.
				USER_ID=$(cut /etc/passwd -f1,3 -d: | grep -m1 ^"$UNAME" | cut -f2 -d: 2> /dev/null)
				GROUP_ID=$(cut /etc/passwd -f1,4 -d: | grep -m1 ^"$UNAME" | cut -f2 -d: 2> /dev/null)
				GROUP_NAME=$(grep -m1 "$GROUP_ID" /etc/group | cut -f1 -d: 2> /dev/null)
				COMMENT=$(cut /etc/passwd -f1,5 -d: | grep -m1 ^"$UNAME" | cut -f2 -d: 2> /dev/null)
				HOME_FOLDER=$(cut /etc/passwd -f1,6 -d: | grep -m1 ^"$UNAME" | cut -f2 -d: 2> /dev/null)
				SHELL=$(cut /etc/passwd -f1,7 -d: | grep -m1 ^"$UNAME" | cut -f2 -d: 2> /dev/null)
				
				# Räkna antalet supplementary groups. Alltså antalet grupper minus en.
				GROUP_COUNT=$(($(id -nG "$UNAME" | wc -w 2> /dev/null) - 1))
				
				# Om det finns en eller fler supplementary groups, skriv dessa till GROUPLIST.
				if [ "$GROUP_COUNT" -gt 0 ]; then
					GROUPLIST=$(id -nG "$UNAME" | cut -f2- -d" " | tr " " "\n" 2> /dev/null)
				else
					GROUPLIST=""
				fi
				dialog --title "Success" \
					--cr-wrap \
					--no-collapse \
					--clear \
					--msgbox "Username    :    $UNAME\nUser-ID     :    $USER_ID\nGroup-ID    :    $GROUP_ID \"$GROUP_NAME\"\nComments    :    $COMMENT\nHome Folder :    $HOME_FOLDER\nShell       :    $SHELL\n\nSupplementary Groups:\n$GROUPLIST" 20 55 ;;
			1) dialog --title "Error" \
					--clear \
					--msgbox "User \"$UNAME\" doesn't exist." 9 30 ;;
		esac
	done
}

function user_modify { # KLAR
	# Funktionen visar ett menyval och gör en kontroll av det inmatade användarnamnet.
	while true; do
		UNAME=$(dialog --title "Modify user" \
			--cancel-label "Exit" \
			--output-fd 1 \
			--inputbox "Specify a user you wish to modify" 10 30)
		
		# Kontrollerar om användarnamnet är ett godkänt namn. Om inte, gå ur loopen.
		case $? in
			0) 	if ! uname_check "$UNAME"; then
					break
				fi ;;
			1) break ;;
			255) break ;;
		esac

		# Kontrollerar om användaren finns i systemet. Om ja, fortsätt och visa menyer.
		id "$UNAME" &> /dev/null
		case $? in
			0)	INPUT=$(dialog --title "User modification" \
					--cancel-label "Exit" \
					--clear \
					--output-fd 1 \
					--menu "Select a user and group management option below:" 10 65 2 \
					'Modify attributes' "Modify user attributes" \
					'Change password' "Change user password")
				case $? in
					1) break ;;
					255) break ;;
				esac
				case "$INPUT" in
					'Modify attributes') user_attributes ;;
					'Change password') user_password ;;
				esac ;;
			1) uname_exist_mess "$UNAME" 0
				break ;;
			*) break ;;
		esac
	done
}

function user_attributes { # KLAR
	# Denna funktion tillåter en modifiering av en användares attribut.
	#
	# Variablerna nedanför kommer att fyllas med information om användaren.
	# Denna information kommer att visas i fälten så att det blir enkelt att
	# se vilka attribut som användaren redan har.
	UNAME=$(grep ^"$UNAME:" /etc/passwd | cut -f1 -d: 2> /dev/null)
	USER_ID=$(grep ^"$UNAME:" /etc/passwd | cut -f3 -d: 2> /dev/null)
	GROUP_ID=$(grep ^"$UNAME:" /etc/passwd | cut -f4 -d: 2> /dev/null)
	COMMENTS=$(grep ^"$UNAME:" /etc/passwd | cut -f5 -d: 2> /dev/null)
	HOME_FOLDER=$(grep ^"$UNAME:" /etc/passwd | cut -f6 -d: 2> /dev/null)
	SHELL=$(grep ^"$UNAME:" /etc/passwd | cut -f7 -d: 2> /dev/null)
	
	# Tomma variabler som kommer att fyllas med det som användaren skriver in.
	NEW_UNAME=""
	NEW_UID=""
	NEW_GID=""
	NEW_COMMENTS=""
	NEW_HOME_FOLDER=""
	NEW_SHELL=""
	
	INPUT=$(dialog --title "Modify user attributes" \
		--cancel-label "Exit" \
		--clear \
		--output-fd 1 \
		--form "Modify the desired attributes.\nThose already showing are those that the user already has." \
		15 41 6 \
		"Username   :" 1 1 "$UNAME" 	1 17 18 0 \
		"User ID    :" 2 1 "$USER_ID" 	2 17 18 0 \
		"Group ID   :" 3 1 "$GROUP_ID" 	3 17 18 0 \
		"Comments   :" 4 1 "$COMMENTS" 	4 17 18 0 \
		"Home       :" 5 1 "$HOME_FOLDER" 5 17 18 0 \
		"Shell      :" 6 1 "$SHELL" 	6 17 18 0)
		
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	# Sätter de inmatade värdena till nya variabler.
	NEW_UNAME=$(echo "$INPUT" | head -1 2> /dev/null)
	NEW_UID=$(echo "$INPUT" | head -2 | tail -1 2> /dev/null)
	NEW_GID=$(echo "$INPUT" | head -3 | tail -1 2> /dev/null)
	NEW_COMMENTS=$(echo "$INPUT" | head -4 | tail -1 2> /dev/null)
	NEW_HOME_FOLDER=$(echo "$INPUT" | head -5 | tail -1 2> /dev/null)
	NEW_SHELL=$(echo "$INPUT" | head -6 | tail -1 2> /dev/null)
	
	# Om användarnamnet inte är godkänt, return.
	if ! uname_check "$NEW_UNAME"; then
		return
	fi
	
	# Modifierar en användares användarnamn.
	usermod -l "$NEW_UNAME" "$UNAME" &> /dev/null
	case $? in
		9)	uname_exist_mess "$NEW_UNAME" 1
			return ;;
	esac
	
	# Ändrar user ID.
	usermod -u "$NEW_UID" "$NEW_UNAME" &> /dev/null
	case $? in
		4) dialog --title "Error" \
				--clear \
				--msgbox "The chosen user ID already exists. No change will occur" 8 35
			NEW_UID="$USER_ID"
			return ;;
	esac
	
	# Ändrar group ID.
	usermod -g "$NEW_GID" "$NEW_UNAME" &> /dev/null
	case $? in
		6) gname_exist_mess "$NEW_GID" "0"
			NEW_GID="$GROUP_ID"
			return ;;
	esac
	
	# Lägger till eller tar bort kommentarer.
	usermod -c "$NEW_COMMENTS" "$NEW_UNAME" &> /dev/null
	
	# Kontrollerar om en ny home folder önskas. Om så är fallet,
	# kontrollera om den mappen redan finns och ge en yes/no dialog.
	if [ "$NEW_HOME_FOLDER" != "$HOME_FOLDER" ]; then
		if ls -d "$NEW_HOME_FOLDER"; then
			dialog --title "Warning" \
				--clear \
				--yesno "The selected home folder already exists.\n\nAre you sure you want to proceed??" 8 35
			if $?; then
				usermod -md "$NEW_HOME_FOLDER" "$NEW_UNAME" &> /dev/null
			fi
		fi
	fi
	
	# Matchar det inmatade värdet för shell mot de som redan finns
	# för att se om inmatningen är korrekt.
	if tail +2 /etc/shells | grep -x "$NEW_SHELL"; then
		usermod -s "$NEW_SHELL" "$NEW_UNAME" &> /dev/null
	else
		dialog --title "Error" \
			--clear \
			--msgbox "Shell doesn't exist. No change will occur." 8 35
		NEW_SHELL="$SHELL"
	fi
	
	# Slutligen, resultatet.
	dialog --title "Status" \
		--clear \
		--msgbox "The changes made are the folowing.\n\nUsername: \"$UNAME\" changed to \"$NEW_UNAME\"\nUser ID: \"$USER_ID\" ----> \"$NEW_UID\"\nGroup ID: \"$GROUP_ID\" ----> \"$NEW_GID\"\nComments: \"$COMMENTS\" ----> \"$NEW_COMMENTS\"\nHome folder: \"$HOME_FOLDER\" ----> \"$NEW_HOME_FOLDER\"\nShell: \"$SHELL\" ----> \"$NEW_SHELL\"" 15 60
}

function user_password { # KLAR
	# Denna funktion låter administratören ändra eller lägga till ett lösenord
	# för en vald användare.
	# Skriv in lösenordet i två fält, och använder pipes för att skicka informationen
	# till passwd.
	while true; do
		INPUT=$(dialog --title "Change user password" \
			--clear \
			--output-fd 1 \
			--passwordform "Please enter new password for user \"$UNAME\".\nThe two fields must match." \
			12 35 2 \
			"New password     : " 1 1 "" 1 19 10 0 \
			"Re-type password : " 2 1 "" 2 19 10 0)
		
		# Kontrollera knapptryckning.
		case $? in
			1) return ;;
			255) return ;;
		esac
		
		# Kontrollerar om alla fält är ifyllda.
		if [ $(echo "$INPUT" | wc -l) -lt 2 ]; then
			dialog --title "Error" \
				--msgbox "Not enough data the fields. Please fill out both fields." 10 30
				INPUT=""
				return
		else
			break # Går ur loopen och fortsätter med funktionen för att sätta ett lösenord på användaren.
		fi
	done
	# Pipar in lösenordet till kommandot passwd och använder användarnamnet som argument.
	echo "$INPUT" | passwd "$UNAME" &> /dev/null
	case $? in
		0) dialog --title "Success" \
				--clear \
				--msgbox "Successfully changed the password of user \"$UNAME\"" 10 30 ;;
		10) dialog --title "Error" \
				--clear \
				--msgbox "Passwords do not match." 10 30 ;;
		*) dialog --title "Error" \
				--clear \
				--msgbox "Unable to change password." 10 30 ;;
	esac
}

function folder_add { # KLAR
	# Denna funktion lägger till en mapp i systemet.
	while true; do
		INPUT=$(dialog --title "Add a folder" \
			--cancel-label "Exit" \
			--output-fd 1 \
			--dselect / 14 60)

		case $? in
			1) break ;;
			255 ) break ;;
		esac
		
		# Om mappen redan finns, skriv felmeddelande och börja om.
		mkdir "$INPUT" 2> /dev/null
		case $? in
			0) dialog --title "Success" \
				--clear \
				--msgbox "Folder \"$INPUT\" successfully added" 8 38 ;;
			1) dialog --title "Error" \
				--clear \
				--msgbox "Folder \"$INPUT\" already exists." 8 30 ;;
			*) dialog --title "Error" \
				--clear \
				--msgbox "Something went wrong. Failed to create folder" 8 30 ;;
		esac
	done
}

function folder_list { # KLAR
	# Denna funktion låter administratören navigera i filsystemet och
	# se innehållet i olika mappar.
	while true; do
		INPUT=$(dialog --title "List Folder contents" \
			--cancel-label "Exit" \
			--output-fd 1 \
			--fselect / 14 60)

		case $? in
			1) break ;;
			255) break ;;
		esac
		
		# Om administratören vill lista alla filer i en enda dialogruta så kan denne
		# markera mappen av intresse och trycka ok. Innehållet listas då i en msgbox.
		OUTPUT=$(ls -1 "$INPUT" 2> /dev/null) 
		case $? in
			0) dialog --title "Success" \
					--clear \
					--msgbox "$OUTPUT" 40 40 ;;
			1) dialog --title "Error" \
					--clear \
					--msgbox "Couldn't view folder contents" 8 30 ;;
			2) dialog --title "Error" \
					--clear \
					--msgbox "Wrong folder syntax" 8 30 ;;
		esac
	done
}

function folder_view { # KLAR
	# Denna funktion låter administratören se vilka rättigheter som finns
	# satta på mappen.
	while true; do
		INPUT=$(dialog --title "View Folder Attributes" \
			--cancel-label "Exit" \
			--output-fd 1 \
			--dselect / 14 60)
			
		case $? in
			1) break ;;
			255) break ;;
		esac
		
		# Om ls inte returnerar 0 så finns inte mappen. Error och break.
		if ! ls -ld "$INPUT" &> /dev/null; then
			dialog --title "Error" \
				--clear \
				--msgbox "Failed to view folder attributes.\n\nFolder doesn't exist." 8 45
				break
		fi
		
		# Tar bort trailing forward slash.
		INPUT=$(trail_fslash_rem "$INPUT" 2> /dev/null)
		
		# Kontrollera om SETUID är satt. Om ja, sätt variabeln till X.
		if ls -ld "$INPUT" | cut -c4 | grep -i "s" &> /dev/null; then
			SETUID="X"
		else
			SETUID="-"
		fi
		
		# Kontrollera om SETGID är satt. Om ja, sätt variabeln till X.
		if ls -ld "$INPUT" | cut -c7 | grep -i "s" &> /dev/null; then
			SETGID="X"
		else
			SETGID="-"
		fi
		
		# Kontrollera Sticky bit. Om ja, sätt X.
		if ls -ld "$INPUT" | cut -c10 | grep -i "t" &> /dev/null; then
			STICKY="X"
		else
			STICKY="-"
		fi
		
		# Konverterar s eller S till x eller - för att användas i msxbox senare.
		# Alla tre gör liknande saker.
		OWNER_PERMISSIONS=$(ls -ld "$INPUT" | cut -c2-4 | tr "s" "x" | tr "S" "-" 2> /dev/null)
		GROUP_PERMISSIONS=$(ls -ld "$INPUT" | cut -c5-7 | tr "s" "x" | tr "S" "-" 2> /dev/null)
		OTHER_PERMISSIONS=$(ls -ld "$INPUT" | cut -c8-10 | tr "t" "x" | tr "T" "-" 2> /dev/null)
		
		# Sätter ägare och grupp till variabler.
		OWNER=$(ls -ld "$INPUT" | cut -f3 -d" " 2> /dev/null)
		GROUP=$(ls -ld "$INPUT" | cut -f4 -d" " 2> /dev/null)
		
		# Följande behövs eftersom ett datum som t ex 2 januari har extra white space framför siffran.
		# Således ändras antal fält som behöver klippas ut.
		LINE_COUNT=$(ls -ld "$INPUT" | tr " " "\n" | wc -l 2> /dev/null)
		if [ "$LINE_COUNT" = "10" ];then 
			TIME_MODIFIED=$(ls -ld "$INPUT" | cut -f6-9 -d" " 2> /dev/null)
		else
			TIME_MODIFIED=$(ls -ld "$INPUT" | cut -f6-8 -d" " 2> /dev/null)
		fi
		case $? in
			0)	dialog --title "Sucess!" \
					--clear \
					--msgbox "Selected Folder: \"$INPUT\"\n\n                  Folder attributes\n\nLast modified:     $TIME_MODIFIED\nOwner:             $OWNER\nGroup:             $GROUP\nOwner Permissions: $OWNER_PERMISSIONS\nGroup permissions: $GROUP_PERMISSIONS\nOther permissions: $OTHER_PERMISSIONS\n\n                 Special Permissions\n\nSet UID:           $SETUID\nSet GID:           $SETGID\nSticky bit:        $STICKY" 20 60 ;;
			1)	dialog --title "Error" \
					--clear \
					--msgbox "Something went wrong.\n\nWrong syntax?" 8 35 ;;
		esac
	done
}

function folder_modify { # KLAR
	# Denna funktion ger menyvalet för modifiering av mappattribut.
	while true; do
		INPUT="" # Nollställ variabeln innan körning.
		INPUT=$(dialog --title "Select the folder you want to modify" \
			--cancel-label "Exit" \
			--output-fd 1 \
			--clear \
			--dselect / 14 60)

		case $? in
			1) break ;;
			255) break ;;
		esac
		
		# Om mappen finns, gå in i funktionen. Annars, skriv felmeddelande och gå ur loopen.
		if ls -ld "$INPUT" &> /dev/null; then
			folder_modify_attributes
		else
			dialog --title "Error" \
				--clear \
				--output-fd 1 \
				--msgbox "\nFolder doesn't exist." 8 45
				break
		fi
	done
}

function folder_modify_attributes { # KLAR
	# Fyll variabler med redan satta attribut så att administratören kan se
	# vilka attribut som redan är satta på mappen i formuläret längre ned.
	
	# Tar bort trailing forward slash för snygg presentation senare.
	INPUT=$(trail_fslash_rem "$INPUT" 2> /dev/null)
			
	# Kontrollera om SETUID är satt. Om ja, sätt variabeln till X.
	if ls -ld "$INPUT" | cut -c4 | grep -i "s" &> /dev/null; then
		SETUID="X"
	else
		SETUID="-"
	fi
	
	# Kontrollera om SETGID är satt. Om ja, sätt variabeln till X.
	if ls -ld "$INPUT" | cut -c7 | grep -i "s" &> /dev/null; then
		SETGID="X"
	else
		SETGID="-"
	fi
	
	# Kontrollera Sticky bit. Om ja, sätt X.
	if ls -ld "$INPUT" | cut -c10 | grep -i "t" &> /dev/null; then
		STICKY="X"
	else
		STICKY="-"
	fi
	
	# Konverterar s eller S till x eller - för att användas i msgbox senare.
	# Alla tre gör liknande saker.
	OWNER_PERMISSIONS=$(ls -ld "$INPUT" | cut -c2-4 | tr "s" "x" | tr "S" "-" 2> /dev/null)
	GROUP_PERMISSIONS=$(ls -ld "$INPUT" | cut -c5-7 | tr "s" "x" | tr "S" "-" 2> /dev/null)
	OTHER_PERMISSIONS=$(ls -ld "$INPUT" | cut -c8-10 | tr "t" "x" | tr "T" "-" 2> /dev/null)
	
	# Skriv ägare och grupp till variabler.
	OWNER=$(ls -ld "$INPUT" | cut -f3 -d" " 2> /dev/null)
	GROUP=$(ls -ld "$INPUT" | cut -f4 -d" " 2> /dev/null)
	
	# Räknar antal nya rader för att kunna visa datumet i dialog korrekt.
	# Behövs eftersom om ett datum är ensiffrigt istället för tvåsiffrigt så
	# finns det ett extra white space som måste tas om hand.
	LINE_COUNT=$(ls -ld "$INPUT" | tr " " "\n" | wc -l 2> /dev/null)
	if [ "$LINE_COUNT" = "10" ];then 
		TIME_MODIFIED=$(ls -ld "$INPUT" | cut -f6-9 -d" " 2> /dev/null)
	else
		TIME_MODIFIED=$(ls -ld "$INPUT" | cut -f6-8 -d" " 2> /dev/null)
	fi
	
	# Lägg till den valda mappen i en variabel för användning senare.
	FOLDER="$INPUT"
	
	# Själva dialogrutan för modifiering av attribut.
	# De gamla värdenä finns inmatade i fälten så att administratören
	# lätt kan se vad som redan är satt.
	INPUT=$(dialog --title "Modiy Folder Properties" \
				--output-fd 1 \
				--cancel-label "Exit" \
				--clear \
				--form "Selected Folder: \"$INPUT\"\n\nEnter folder properties in the fields below.\n\nPermissions:\nEnter as rwx, in that order. To remove, change a letter to a dash (r-x) like so.\n\nSpecial Permissions:\nSet them by entering an upper or lowercase X, and remove by entering a dash (-).\n\nThe Set UID isn't normally used on folders, so it can be seen but not set." \
				30 51 10 \
				"Time modified        :" 1 1 "$TIME_MODIFIED"		1 27 18 0 \
				"Owner                :" 2 1 "$OWNER" 				2 27 18 0 \
				"Group                :" 3 1 "$GROUP" 				3 27 18 0 \
				"                Permissions" 4 1 ""				4 0 0 0 \
				"Owner Permissions    :" 5 1 "$OWNER_PERMISSIONS" 	5 27 18 3 \
				"Group Permissions    :" 6 1 "$GROUP_PERMISSIONS" 	6 27 18 3 \
				"Other Permissions    :" 7 1 "$OTHER_PERMISSIONS" 	7 27 18 3 \
				"            Special Permissions" 8 1 ""			8 0 0 0 \
				"Set GID              :" 9 1 "$SETGID"				9 27 18 1 \
				"Sticky bit           :" 10 1 "$STICKY"				10 27 18 1)
	
	case $? in
		1) return ;;
		255) return ;;
	esac
	
	# Sorterar de inmatade värdena från INPUT till olika variabler. 
	NEW_TM=$(echo "$INPUT" | head -1 2> /dev/null)
	NEW_OWN=$(echo "$INPUT" | head -2 | tail -1 2> /dev/null)
	NEW_GR=$(echo "$INPUT" | head -3 | tail -1 2> /dev/null)
	NEW_OW_PER=$(echo "$INPUT" | head -4 | tail -1 | tr [:upper:] [:lower:] 2> /dev/null)
	NEW_GR_PER=$(echo "$INPUT" | head -5 | tail -1 | tr [:upper:] [:lower:] 2> /dev/null)
	NEW_OT_PER=$(echo "$INPUT" | head -6 | tail -1 | tr [:upper:] [:lower:] 2> /dev/null)
	
	# Special Permissions.
	NEW_SETGID=$(echo "$INPUT" | head -7 | tail -1 | tr [:upper:] [:lower:] 2> /dev/null)
	NEW_STICKY=$(echo "$INPUT" | head -8 | tail -1 | tr [:upper:] [:lower:] 2> /dev/null)
	
	
	# Modifierar tiden med det nya värdet.
	touch --date="$NEW_TM" "$FOLDER" &>  /dev/null
	
	# Felmeddelande om det inte lyckades.
	case $? in
		0) : ;;
		1) dialog --title "Error" \
				--clear \
				--msgbox "Couldn't change date, or the date is too early." 8 35
			return ;;
		2) dialog --title "Error" \
				--clear \
				--msgbox "Invalid date string." 8 35
			return ;;
		*) dialog --title "Error" \
				--clear \
				--msgbox "Something went wrong" 8 35
			return ;;
	esac
	
	# Ändrar ägaren av mappen till det som skrivits in.
	# Felmeddelande om det inte lyckas.
	chown "$NEW_OWN":"$NEW_GR" "$FOLDER"
	case $? in
		0) : ;;
		1)	dialog --title "Error" \
				--clear \
				--msgbox "No such user, group or directory" 8 35
			return ;;
		*)	dialog --title "Error" \
				--clear \
				--msgbox "Something went wrong" 8 35
			return ;;
	esac
	
	# Delar upp strängen för permissions i olika delar.
	# Om dessa är ett streck "-" så sätts variablerna som tomma.
	# ------------ OWNER Permissions -----------------
	NEW_OW_PER_R=$(echo "$NEW_OW_PER" | cut -c1 2> /dev/null)
	if [ "$NEW_OW_PER_R" = "-" ]; then
		NEW_OW_PER_R=""
	fi
	
	NEW_OW_PER_W=$(echo "$NEW_OW_PER" | cut -c2 2> /dev/null)
	if [ "$NEW_OW_PER_W" = "-" ]; then
		NEW_OW_PER_W=""
	fi
	
	NEW_OW_PER_X=$(echo "$NEW_OW_PER" | cut -c3 2> /dev/null)
	if [ "$NEW_OW_PER_X" = "-" ]; then
		NEW_OW_PER_X=""
	fi
	
	# Kombinera till en variabel och sätt dessa på mappen med chmod.
	# Felmeddelande om det inte lyckas.
	# Samma sak görs med de andra rättigheterna också.
	NEW_OW_PER="$NEW_OW_PER_R""$NEW_OW_PER_W""$NEW_OW_PER_X"
	chmod u="$NEW_OW_PER" "$FOLDER"
	
	case $? in
		1) dialog --title "Error" \
			--clear \
			--msgbox "Invalid syntax." 8 35
			return ;;
	esac

	# --------- GROUP Permissions ---------
	NEW_GR_PER_R=$(echo "$NEW_GR_PER" | cut -c1 2> /dev/null)
	if [ "$NEW_GR_PER_R" = "-" ]; then
		NEW_GR_PER_R=""
	fi
	
	NEW_GR_PER_W=$(echo "$NEW_GR_PER" | cut -c2 2> /dev/null)
	if [ "$NEW_GR_PER_W" = "-" ]; then
		NEW_GR_PER_W=""
	fi
	
	NEW_OW_PER_X=$(echo "$NEW_GR_PER" | cut -c3 2> /dev/null)
	if [ "$NEW_GR_PER_X" = "-" ]; then
		NEW_GR_PER_X=""
	fi
	
	NEW_GR_PER="$NEW_GR_PER_R""$NEW_GR_PER_W""$NEW_GR_PER_X"
	chmod g="$NEW_GR_PER" "$FOLDER" &> /dev/null
	
	case $? in
		1) dialog --title "Error" \
			--clear \
			--msgbox "Invalid syntax." 8 35
			return ;;
	esac	
	
	#------------ OTHER Permissons --------------
	NEW_OT_PER_R=$(echo "$NEW_OT_PER" | cut -c1 2> /dev/null)
	if [ "$NEW_OT_PER_R" = "-" ]; then
		NEW_OT_PER_R=""
	fi
	
	NEW_OT_PER_W=$(echo "$NEW_OT_PER" | cut -c2 2> /dev/null)
	if [ "$NEW_OT_PER_W" = "-" ]; then
		NEW_OT_PER_W=""
	fi
	
	NEW_OT_PER_X=$(echo "$NEW_OT_PER" | cut -c3 2> /dev/null)
	if [ "$NEW_OT_PER_X" = "-" ]; then
		NEW_OT_PER_X=""
	fi
	
	NEW_OT_PER="$NEW_OT_PER_R""$NEW_OT_PER_W""$NEW_OT_PER_X"
	chmod o="$NEW_OT_PER" "$FOLDER"

	case $? in
		1) dialog --title "Error" \
			--clear \
			--msgbox "Invalid syntax." 8 35
			return ;;
	esac	
	
	##################################
	# ------------- Set GID ---------#
	##################################
	# Om NEW_SETGID INTE är X och det INTE är lika med -, sätt det som det gamla värdet.
	# Kort sagt, tvinga admin att skriva in ett x eller ett -.
	# Om NEW_SETGID är x, sätt det på mappen, annars ta bort det.
	if [ "$NEW_SETGID" != "x" ] && [ "$NEW_SETGID" != "-" ]; then
		NEW_SETGID="$SETGID"
	elif [ "$NEW_SETGID" = "x" ]; then
		chmod g+s "$FOLDER" &> /dev/null
	else
		chmod g-s "$FOLDER" &> /dev/null
	fi
	
	###################################
	# ----------- Sticky bit -------- #
	###################################
	# Samma sak som med NEW_SETGID ovanför.
	if [ "$NEW_STICKY" != "x" ] && [ "$NEW_STICKY" != "-" ]; then
		NEW_STICKY="$STICKY"
	elif [ "$NEW_STICKY" = "x" ]; then
		chmod o+t "$FOLDER" &> /dev/null
	else
		chmod o-t "$FOLDER" &> /dev/null
	fi
	
	# Slutligen, visa resultatet.
	case $? in
		0)	dialog --title "Sucess!" \
				--clear \
				--msgbox "Selected Folder: \"$FOLDER\"\n\n                  Folder attributes\n\nLast modified:     $NEW_TM\nOwner:             $NEW_OWN\nGroup:             $NEW_GR\nOwner Permissions: $NEW_OW_PER\nGroup permissions: $NEW_GR_PER\nOther permissions: $NEW_OT_PER\n\n                 Special Permissions\n\nSet GID:           $NEW_SETGID\nSticky bit:        $NEW_STICKY" 20 60 ;;
		1)	dialog --title "Error" \
				--clear \
				--msgbox "Something went wrong. Exiting" 8 35
				return ;;
	esac
}

################
#     MAIN     #
################
# Huvudmenyn i dialog.
while true; do
	INPUT=$(dialog --title "Group, User and Folder Manager" \
		--cancel-label "Exit" \
		--output-fd 1 \
		--clear \
		--menu "Select a management option below:" 10 60 3 \
			'Group' "Group options" \
			'User' "User options" \
			'Folder' "Folder options")

	# Rensa skärmen och gå ur loopen om Exit väljs.
	case $? in
		1) clear
			break ;;
		255) clear
			break ;;
	esac

	# Menyval i case-sats
	case "$INPUT" in
		Group) group ;;
		User) user ;;
		Folder) folder ;;
	esac
done

# BUGS
# Perhaps.
