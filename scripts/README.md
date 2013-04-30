create_mcf.sh is a bash script that can build a micro cf VM automatically.

By default it gets the master branch of cf-release & micro, but you can set the environment variable to change it.

e.g.

`export CF_RELEASE_BRANCH=release-candidate`

`export MICRO_GIT=https://github.com/{yourfork}/micro.git`

`export MICRO_BRANCH={yourbranch}`

And then adding -E when running the script. (It will preserve the environment variables from the current user).

`sudo -E ./create_mcf.sh`