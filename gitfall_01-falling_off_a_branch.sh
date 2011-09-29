#!/bin/bash

# some variables
demo_folder=sandbox/01
current_step=0

COL_NORM="$(tput setaf 9)"
COL_RED="$(tput setaf 1)"
COL_GREEN="$(tput setaf 2)"
COL_YELLOW="$(tput setaf 3)"
COL_BLUE="$(tput setaf 4)"
COL_MAGENTA="$(tput setaf 5)"
COL_CYAN="$(tput setaf 6)"
COL_WHITE="$(tput setaf 7)"


# main()
more -R <<INTRO
${COL_CYAN}#####################################################################

  ${COL_CYAN}+---------------------------------------------------------------+
  ${COL_CYAN}|  gitfall 01: Falling of a branch                              |
  ${COL_CYAN}+---------------------------------------------------------------+

  ${COL_CYAN}Context:
  ${COL_CYAN}--------
  You have two branches and are attempting to merge.
  There are no obvious reasons why there should be any issues
  with the merge.
  
  ${COL_CYAN}Problem:
  ${COL_CYAN}--------
  git merge fails with the (fairly scary) message:
  fatal: git write-tree failed to write a tree
  
  After cleaning up the failed merge and making a commit,
  it is the correct merge set, but the commit only
  has one parent and you've lost the reference in the
  commit history of the relation to the other branch
  (hence: falling off a branch)

  ${COL_CYAN}Cause:
  ${COL_CYAN}------
  While there are probably many other ways to get this error,
  we will explore a simple way of triggering it when:
  
  * one branch has a file named <whatever>
  * the other branch has introduced a folder named the same thing

  When these branches merge, the internal sequence of steps
  that git uses lead it to try and make a folder with the
  same name as an existing file (hence: write-tree failed)

  ${COL_CYAN}How to Avoid This Problem
  ${COL_CYAN}-------------------------
  Perhaps:
  * avoid reorganising folder structures using folder names
    that once were used by files (or vice versa)
  * if you must do such a reorganisation, immediately merge
    or cherry-pick to other active branches if you can. This
    avoids laying a trap for a co-worker to hit later on.

  ${COL_CYAN}Example:
  ${COL_CYAN}--------
  This script walks through the reproduction and resolution
  of this error:

  * cleanup the merge failure, then merge again
  * Also shows a trick to reconstitute a commit with the correct
    parentage in one step.
  
  It creates a demo repository in ${demo_folder} and leaves it in
  place after the test so you can inspect and play further.

  It should be innocent and safe, but caveat emptor. If you prefer,
  the script is set out in a way that should be easy enough to
  read and manually follow instead.

  ${COL_RED}Press any key when you are ready to begin the demo,
  ${COL_RED}or Ctrl-C to exit now
INTRO
read -sn 1

## Some boiler plate functions

# Run a line of script with explanation
runStep() {
  local cmd=${1}
  local msg=${2}
  let "current_step += 1"
  cat <<EOS

${COL_GREEN}#--------------------------------------------------------------------
# STEP ${current_step}: ${msg}${COL_NORM}

  ${cmd}

${COL_GREEN}# Output (if any):${COL_NORM}
EOS
  eval $cmd
  # read -sn 1 -p ".. press a key to continue"
}

# Startup
setup() {
  cat <<EOS

${COL_CYAN}#####################################################################
#
# Setting up our demo sandbox in ${demo_folder}
#${COL_NORM}
EOS
  # create a working space
  rm -fR ${demo_folder}
  mkdir -p ${demo_folder}
  runStep "cd ${demo_folder}" "Set the current working directory for our tests.."
  runStep 'git init' "Initialise a git repo.."
  runStep 'echo "my conf" > conf' "Creating a file called conf.."
  runStep 'git add conf ; git commit -m "added conf file"' "This commit will be our common starting point for all tests.."
  runStep 'git log --oneline --decorate' "Here is our first commit on the master branch.."
  runStep 'git ls-tree -rt master' "It contains the following objects in it's tree.."
}

# Cleanup
teardown() {
  cd ../..
  cat <<EOS

${COL_CYAN}#====================================================================
#
# Test complete! Remember, we've left the demo files in ${demo_folder}
#${COL_NORM}
EOS
}

# Run thru a standard merge
aNiceMerge() {
  cat <<EOS

${COL_CYAN}#====================================================================
#
# First let's do a normal, clean merge as a baseline test
#${COL_NORM}
EOS
  runStep 'git checkout master -b baseline_right' "Create a right branch.."
  runStep 'git mv conf my.conf' "Making a change: renaming a file"
  runStep 'git commit -m "on baseline_right: renamed conf to my.conf"' "Commiting the change.."
  runStep 'mkdir confs ; git mv my.conf confs/my.conf' "Another change: move the file into a folder"
  runStep 'git commit -m "baseline_right: reorganised my.conf into confs folder"' ".. and commit the result"

  runStep 'git checkout master -b baseline_left' "Start a left branch off master"
  runStep 'echo "other conf" > other.conf' "Create a new file.."
  runStep 'git add other.conf ; git commit -m "baseline_left: added other.conf"' "..and commit"

  runStep 'git merge baseline_right' "Now we merge the right branch.."
  runStep 'git log --graph' "..and the result is a nice clean merge"
  runStep 'git show --format=raw' "Note the head of our left branch has two parents as you would expect:"
  runStep 'git ls-tree -rt baseline_left' "And it contains the two files and one tree object as expected:"
}

# Break a merge with the fatal: git write-tree failed to write a tree
aFatalMerge() {
  cat <<EOS

${COL_CYAN}#====================================================================
#
# Now let's break a merge and cause the error:
#   fatal: git write-tree failed to write a tree
#${COL_NORM}
EOS
  runStep 'git checkout master -b fatal_right' "Create a right branch.."
  runStep 'git mv conf my.conf' "Making a change: renaming a file"
  runStep 'git commit -m "on fatal_right: renamed conf to my.conf"' "Commiting the change.."
  runStep 'mkdir conf ; git mv my.conf conf/my.conf' "Another change: move the file into a folder"
  runStep 'git commit -m "fatal_right: reorganised my.conf into conf folder"' ".. and commit the result"
  cat <<EOS

${COL_RED}# ^^^ THIS IS THE CRITICAL STEP: note that we've now created a folder
#     that has the same name as what the file _used_ to be called${COL_NORM}
EOS
  runStep 'git checkout master -b fatal_left' "Start a left branch off master"
  runStep 'echo "other conf" > other.conf' "Create a new file.."
  runStep 'git add other.conf ; git commit -m "fatal_left: added other.conf"' "..and commit"

  runStep 'git merge fatal_right' "Now we merge the right branch.. "
  echo -e "\n${COL_RED}# *** KABOOM! ***${COL_NORM}"
  runStep 'git status' "Messy contradtiction: delete a file and add a folder with the same name at the same time"
  runStep 'git reset HEAD conf/my.conf ; git checkout -- conf/my.conf' "One way I know how to fix this up (may be other/better ways)"
  runStep 'git commit -m "fatal_left: Merged branch '\''fatal_right'\'' into fatal_left"' "And commit the fixed merge"
  runStep 'git log --graph' "..but now we've fallen off the other branch"
  runStep 'git show --format=raw' "Note the head of our left branch only has one parent now:"
  runStep 'git ls-tree -rt fatal_left' "But it contains the two files and one tree object as expected:"

  runStep 'git merge fatal_right' "Simple way to fixup the parentage is to merge again:"
  runStep 'git log --graph' "..now are branches are back in correct relation to one another (but we have two merge commits, and one with only a single parent)"
  runStep 'git show --format=raw' "Note the head of our left branch now has two parents as you would expect:"
  runStep 'git ls-tree -rt fatal_left' "And it contains the two files and one tree object as expected:"

  cat <<EOS

${COL_CYAN}#====================================================================
#
# Let's go back and try and fix that merge and avoid creating the
# redundant merge commit that unexpectedly only has a single parent
#${COL_NORM}
EOS
  runStep 'git checkout $(echo "fatal_left_clean: Clean merge of branch '\''fatal_right'\'' into fatal_left" | git commit-tree $(git rev-parse fatal_left^{tree}) -p $(git rev-parse fatal_left^^) -p $(git rev-parse fatal_right) ) -b fatal_left_clean' "Use commit-tree to build a clean merge commit"
  cat <<EOS

${COL_YELLOW}#
# .. breaking down that long line:
#    git commit-tree borrows the tree created from our previous attempt to merge (fatal_left^{tree})
#    and adds two parents: one from fatal_right, and one from two commits back on fatal_right^^ (before our flunked merge)
#    echo sends in the commit message to commit-tree
#    git checkout takes the sha generated by the commit-tree and makes a new branch point to it
#${COL_NORM}
EOS
  runStep 'git log --graph' "..now the history of fatal_left_clean is nicely in order"
  runStep 'git show --format=raw' "Note the head of fatal_left_clean has two parents as you would expect:"
  runStep 'git ls-tree -rt fatal_left' "And it contains the two files and one tree object as expected:"

}

# main()
setup
aNiceMerge
aFatalMerge
teardown
# game over