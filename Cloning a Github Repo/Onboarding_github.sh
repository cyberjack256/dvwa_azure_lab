#!/bin/bash

name="name" #Your Name (e.g., "Jack")
email="email@email.com" #Your Email (e.g., "Jack@gmail.com")
oauthtoken="FakEtoKen283947893743" # Your Access Token (e.g., "fjklajfldjslkjfa;ldkfjas8937487325")
username="username" # Your Username (e.g.,"cyberjack256")
repo="dvwa_azure_lab" # Your Repo (e.g, "dvwa_azure_lab")

git clone https://$oauthtoken@github.com/$username/$repo.git
