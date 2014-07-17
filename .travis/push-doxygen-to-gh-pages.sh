#!/bin/bash

# Example taken from 
#   https://github.com/ReadyTalk/swt-bling/blob/master/.utility/push-javadoc-to-gh-pages.sh
#   http://benlimmer.com/2013/12/26/automatically-publish-javadoc-to-gh-pages-with-travis-ci/

if [ "$TRAVIS_REPO_SLUG" == "JoErNanO/icub-iaitabletop" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "master" ]; then

    echo -e "Publishing doxygen. \n"

    cd $PROJ_ROOT
    ls -al
    cp -R doc/html $HOME/html-latest

    cd $HOME
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "travis-ci"
    git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/JoErNanO/icub-iaitabletop gh-pages > /dev/null

    cd gh-pages
    git rm -rf *.html *.css *.png *.js search/
    cp -Rf $HOME/html-latest ./html
    git add -f .
    git commit -m "[DOC] Lastest doxygen on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"
    git push -fq origin gh-pages > /dev/null

    echo -e "Published doxygen to gh-pages. \n"

fi
