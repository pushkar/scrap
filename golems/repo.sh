#!/bin/bash
#
# add, delete, list, download, upload

repo_flag=false
list_flag=false
package_flag=false
add_flag=false
delete_flag=false
upload_flag=false
download_flag=false

function check_repodir {
  if [ ! -d "apt" ]
  then
    echo "First download the repo using -w."
    exit 1
  fi
}

function clean_repodir {
  if [ -d "apt" ]
  then
    echo "Repository is already downloaded."
    echo "Download a fresh one? (y/n)"
    read ans
    if [ "$ans" == "y" ] 
    then
      rm -rf apt/*
    fi
  fi
}

function check_repo {
  check_repodir
  if ! $repo_flag
  then
     echo "Option -r <reponame> is required."
     exit 1
  fi
}

function usage {
  echo "Script for maintaining dartsim apt repo"
  echo "$0 OPTIONS"
  echo "  -r repo"
  echo "  -l list debians in repo"
  echo "  -L list package info in apt"
  echo "  -a add debian in repo"
  echo "  -d delete debian in repo"
  echo "  -U upload repo to webserver"
  echo "  -D download repo from webserver"
  echo "  -h show this help"
  echo ""
  exit 0
}

if [ $# -eq 0 ] ; then
    usage
fi

while getopts ":r:a:d:L:lUDh" opt; do
  case $opt in
    r) repo_flag=true; repo=$OPTARG ;;
    l) list_flag=true ;;
    L) package_flag=true; package_arg=$OPTARG ;;
    a) add_flag=true; add_arg=$OPTARG ;;
    d) delete_flag=true; delete_arg=$OPTARG ;;
    U) upload_flag=true ;;
    D) download_flag=true ;;
    h) usage ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    :)  echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

if $list_flag
then
  check_repo
  echo $repo
  cd apt; reprepro list $repo
fi

if $package_flag
then
  check_repodir
  cd apt; reprepro ls $package_arg
fi

if $delete_flag
then
  check_repo
  cd apt; reprepro -Vb . remove $repo $delete_arg
fi

if $add_flag
then
  check_repo
  cd apt; reprepro -Vb . includedeb $repo $add_arg
fi

if $download_flag
then
  clean_repodir
  scp -r pushkar7@golems.org:~/dart.golems.org/apt ./
fi

if $upload_flag
then
  check_repodir
  #rsync -v -r -W apt/ pushkar7@golems.org:~/dart.golems.org/apt
  # hack because you can't run reprepro on dreamhost
  ssh pushkar7@dart.golems.org "cd dart.golems.org/apt/dists; rm precise/Release.gpg; gpg -abs -o precise/Release.gpg precise/Release; rm quantal/Release.gpg; gpg -abs -o quantal/Release.gpg quantal/Release; "
fi

