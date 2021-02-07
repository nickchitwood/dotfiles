# Design notes inside of comparison function

installed:

- pkg: Package name
- loc: Source for package[Sync database, aur, local]

database:

- pkg: Package name
- loc: Source for package[Sync database, aur, local]
- scope: Where should this be installed?[host, global, ignore]
- cat: Package categories

## Sync function

1. This should create a diff list, removing installed packages from the database list with a matching pkg and scope
   a. Offer to install remaining packages with a global scope that are missing
2. This should then look for installed apps that are not in the database
   a. If it is in installed and database, but in the database as ignore or host, offer to change to global
   b. Otherwise, add to database either as either host, global, or ignore, and ask for category
