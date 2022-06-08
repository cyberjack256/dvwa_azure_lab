#!/bin/bash

name="Jack" #Your Name (e.g., "Jack")
email="cyberjack256@gmail.com" #Your Email (e.g., "Jack@gmail.com")
oauthtoken="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" # Your Access Token (e.g., "fjklajfldjslkjfa;ldkfjas8937487325")
username="cyberjack256" # Your Username (e.g.,"cyberjack256")
repo="dvwa_azure_lab" # Your Repo (e.g, "dvwa_azure_lab")


#gitconfig [--global || --local]
git config --local user.name "$name"
git config --local user.email "$email"

git config --local --list
git config --global --list

git clone https://$oauthtoken@github.com/$username/$repo.git