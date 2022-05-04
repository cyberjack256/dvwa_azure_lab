#!/bin/bash

name="" #Your Name (e.g., "Jack")
email="" #Your Email (e.g., "Jack@gmail.com")
oauthtoken="" # Your Access Token (e.g., "fjklajfldjslkjfa;ldkfjas8937487325")
username="" # Your Username (e.g.,"cyberjack256")
repo="" # Your Repo (e.g, "dvwa_azure_lab")


#gitconfig [--global || --local]
git config --local user.name "$name"
git config --local user.email "$email"

git config --local --list
git config --global --list

git clone https://$oauthtoken@github.com/$username/$repo.git