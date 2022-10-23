#!/usr/bin/env bash

export VETC_VERBOSE=1
export BIN="$(pwd)/vetc"

COLOR_LIGHT_GRAY='\033[0;37m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
NC='\033[0m'

PASS_LIST=()
FAILED_LIST=()
TOTAL_PASS=0
TOTAL_FAILED=0

get_tests () {
    if [[ ! -z "$@" ]]; then
        echo $"$@"
        return 0
    fi

    while read -r LINE; do
        echo "./testcases/$LINE"
    done < ./testcases/tests.txt
}

if [[ $EUID -ne 0 ]]; then
    error "You must be root to run this script"
fi

for FILE in $(get_tests "$@"); do
    echo -e "${COLOR_GREEN}TEST: ${FILE}${NC}"
    $SHELL "$FILE"
    code=$?
    if [[ $code -eq 0 ]]; then
        ((TOTAL_PASS++))
        PASS_LIST+=($FILE)
        echo -e "${COLOR_GREEN}PASS${NC}"
    else
        ((TOTAL_FAILED++))
        FAILED_LIST+=($FILE)
        echo -e "${COLOR_RED}FAILURE${NC}"
    fi
done

echo "Total tests, Passed: ${TOTAL_PASS}, Failed ${TOTAL_FAILED}."

for FILE in ${PASS_LIST[@]}; do
    echo -e "${COLOR_GREEN}$FILE${NC}"
done

for FILE in ${FAILED_LIST[@]}; do
    echo -e "${COLOR_RED}$FILE${NC}"
done
