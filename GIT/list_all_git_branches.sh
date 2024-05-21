#!/usr/bin/bash

export BASEDIR=$(dirname $0)
export CDIR=$PWD

export DIR=$1
[[ -z "${DIR}" ]] && export DIR=${PWD}

outfile=$(mktemp)

function gitBranchList()
{
for git in ${DIR}/*
do
  cd $git
  pwd >> ${outfile}
  pwd
  git stash
  git pull
  git remote prune origin
  #git for-each-ref  --sort=committerdate refs/  --format='%(refname:short) | %(authorname) | %(committerdate:short)' >> ${outfile}
  git for-each-ref  --sort=committerdate refs/  --format='%(refname) | %(authorname) | %(committerdate:short)'|grep -v refs/tags | grep -v HEAD >> ${outfile}
done
}

gitBranchList
cd $CDIR

sed -i 's/,/_/g' ${outfile}
sed -i 's/|/,/g' ${outfile}
sed -i -f ${BASEDIR}/all_committer.sed ${outfile}

ls -ld $outfile

echo git,refname,authorname,committerdate > ${outfile}.csv

awk '/^\//{nn=split($0,aa,"/");gitname=aa[nn];next}
     {print gitname "," $0}
' ${outfile} >> ${outfile}.csv

sed -i 's/ //g' ${outfile}.csv
sed -i '/,,/d' ${outfile}.csv
sed -i '/master,/d' ${outfile}.csv
sed -i '/USER/d' ${outfile}.csv

${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${outfile}.csv -o /tmp/all_git_branches.html

ls -ld ${outfile}* /tmp/all_git_branches.html
