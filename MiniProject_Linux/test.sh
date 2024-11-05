#!/bin/bash

function display_usage {
	echo "Usage: $0 [OPTIONS]"
	echo "options:"
	echo " -c, --create Create a new user account."
	echo " -d, --delete Delete an existing user account."
	echo " -r, --reset Reset password for an existing account"
	echo " -p, --permission Set chmod permission for user on specified file."
	echo " -l, --list List all user accounts on the system."
	echo " -e, --exit Display options and exit."
}

function create_user {
	read -p "Enter the new username: " username

	if id "$username" &>/dev/null; then
		echo "Error: The username '$username' already exists. Please enter new username"
		return 1
	fi

	read -s -p "Enter the password for the $username: " password

	if sudo useradd -m -p "$password" "$username"; then
		echo "User account "$username" is successfully created."
	else
		echo "Error: Failed to create user account '$username'."
		return 1
	fi
}

function delete_user {
	read -p "Enter the username to delete: " username

	if id "$username" &>/dev/null; then
		if sudo userdel -r "$username" 2>/dev/null; then
			echo "User account "$username" is successfully deleted."
		else
			echo "Error: Failed to delete user account "$username"."
			return 1
		fi
	else
		echo "Error: The username "$username" does not exist. Please check for valid username"
		return 1
	fi
}

function reset_password {
	read -p "Enter the username to reset password: " username

	if id "$username" &>/dev/null; then
		read -s -p "Enter the new password for $username: " password

		echo "$username:$password" | sudo chpasswd

		echo "Password for user "$username" has been reset successfully."
	else
		echo "Error: The username "$username" does not exist. Please check for valid username."
	fi
}

function set_permission {
	read -p "Enter the username to set permission for: " username
	if ! id "$username" &>/dev/null; then
		echo "Error: The username '$username' does not exist."
		return 1
	fi
	
	read -p "Enter the file path: " file_path
	if [ ! -e "$file_path" ]; then
		echo "Error: The file '$file_path' does not exist."
		return 1
	fi

	read -p "Enter the chmod permission (e.g., 755): " permission
	if chmod "$permission" "$file_path"; then
		echo "Permission for '$file_path' set to '$permission' for user '$username'."
	else
		echo "Error: Failed to set the permission on '$file_path'."
	fi
}

function list_users {
	echo "User accounts on this system are: "
	cat /etc/passwd | awk -F: '{print "-" $1 "(UID: "$3")"}'
}


case "$0" in
        */c) create_user  ;;
        */d) delete_user  ;;
        */r) reset_password  ;;
        */p) set_permission  ;;
        */l) list_users  ;;
        */e) display_usage; exit 0  ;;
        *) display_usage; exit 1  ;;
esac


#if [ $# -eq 0 ]; then
#	display_usage
#	exit 1
#fi

#while [ "$#" -gt 0 ]; do
#	case "$1" in
#		--create) create_user;;
#		--delete) delete_user;;
#		--reset) reset_password;;
#	        --permission) set_permission;;
#		--list) list_users;;
#		--exit) display_usage; exit 0;;
#		*) echo "Unknown option: $1"; display_usage; exit 1;;
#	esac
#	shift
#done
