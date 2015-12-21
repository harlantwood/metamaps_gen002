Here are the steps to get up and running using a Mac and OS/X. You will need a terminal open for most of this process.

### Install homebrew and rvm

The first, and probably longest, step is to install the Apple Developer Tools. Open a terminal, run this command, and follow the on screen prompts:

    xcode-select --install

To install Homebrew, which is a package manager for OS/X, run the following command (taken from http://brew.sh):

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

To install rvm, which helps you download and manage ruby packages ("gems"), run these commands (taken from https://rvm.io):

    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    \curl -sSL https://get.rvm.io | bash -s stable

### Install metamaps dependencies

Now that you have your package managers, you are ready to go. Run this command to install required packages:

    brew install postgresql node imagemagick
    rvm install 2.1.3 --with-gcc=clang
    rvm gemset create metamaps_gen002

Now clone the git repository:

    git clone https://github.com/metamaps/metamaps_gen002.git --branch develop

The repository will take a moment to download. When that finishes, enter the metamaps directory. rvm will ask you to install ruby 2.1.3, so do so. Once in

    cd metamaps_gen002
    gem install bundler
    bundle install

### Configure the PostgreSQL database

Metamaps needs a database to run. We use PostgreSQL, which you installed in an earlier step. Now set it up like so:

    ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
    createuser postgres -P -s -d
  
When createuser asks you for a password, set it to "3112". Now create the database configuration file by copying the example:

    cp config/database.yml.default config/database.yml

### Run the server

Now that the database is ready, run these three commands to populate the database with initial data:

    rake db:create
    rake db:schema:load
    rake db:fixtures:load

And finally, start the server. While this command is running, you can open a browser and access Metamaps at http://localhost:3000.

    rails s 
