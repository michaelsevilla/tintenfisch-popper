#!/bin/bash

rm -r _minted-paper paper.aux paper.bbl paper.blg paper.log paper.out paper.synctex.gz build.log >> /dev/null 2>&1
docker stop latex >> /dev/null 2>&1
docker rm latex >> /dev/null 2>&1
set -x
cp biblio/references.bib paper.bib

# Build the paper
docker run --rm \
  --name latex \
  --entrypoint=/bin/bash \
  -v `pwd`/:/mnt \
  michaelsevilla/texlive:acmart-popper -c \
    "cd /mnt ; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape paper; \
     bibtex paper; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape paper; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape paper;" &> build.log

ERR=$?
set +x
if [ $ERR != "0" ] ; then
  set +x
  echo "ERROR: $ERR"
  cat build.log
  exit 1
fi

rm -r _minted-paper paper.aux paper.bbl paper.blg paper.log paper.out paper.synctex.gz build.log sections/*.aux >> /dev/null 2>&1

echo "SUCCESS"

