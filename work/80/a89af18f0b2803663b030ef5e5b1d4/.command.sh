#!/usr/bin/env bash

set -u

retry_with_backoff() {
    local max_attempts=${1}
    local delay=${2}
    local max_time=${3}
    local attempt=1
    local output=
    local status=

    # Remove the first three arguments to this function in order to access
    # the 'real' command with `${@}`.
    shift 3

    while [ ${attempt} -le ${max_attempts} ]; do
        output=$("${@}")
        status=${?}

        if [ ${status} -eq 0 ]; then
            break
        fi

        if [ ${attempt} -lt ${max_attempts} ]; then
            echo "Failed attempt ${attempt} of ${max_attempts}. Retrying in ${delay} s." >&2
            sleep ${delay}
        elif [ ${attempt} -eq ${max_attempts} ]; then
            echo "Failed after ${attempt} attempts." >&2
            return ${status}
        fi

        attempt=$(( ${attempt} + 1 ))
        delay=$(( ${delay} * 2 ))
        if [ ${delay} -ge ${max_time} ]; then
            delay=${max_time}
        fi
    done

    echo "${output}"
}

export NCBI_SETTINGS="$PWD/user-settings.mkfg"

retry_with_backoff 5 1 100 \
    prefetch \
     \
    ERR11202896

[ -f ERR11202896.sralite ] && vdb-validate ERR11202896.sralite || vdb-validate ERR11202896

cat <<-END_VERSIONS > versions.yml
"FETCHNGS:NFCORE_FETCHNGS:SRA:FASTQ_DOWNLOAD_PREFETCH_FASTERQDUMP_SRATOOLS:SRATOOLS_PREFETCH":
    sratools: $(prefetch --version 2>&1 | grep -Eo '[0-9.]+')
END_VERSIONS