#!/bin/bash

the_time() {
  echo $(date -u +"%Y-%m-%dT%H:%M:%S")
}

convert_image() {
  local f=$1
  local dest=$2
  local opts=$3
  local output

  local dir=$(dirname $f)
  mkdir -p "${dir}"
  local command="/usr/bin/convert ${f} ${opts} ${dest}"
  echo "${f} -> ${dest}" >&2
  output=$(${command}) 2>&1
  
  if [[ "${output}" != "" ]] ; then
    echo "command [${command}] produced output: [${output}]" >&2
    echo "${output}"
  else
    echo ""
  fi
}

log() {
  local message=$1
  echo "$(the_time) : ${message}" >> /tmp/convert.log
}

delete_log() {
  rm -f /tmp/convert.log
}

log_result() {
  local message=$1
  local f=$2
  local dest=$3

  if [[ "${message}" = "success" ]] ; then
    log "$(the_time) : converted $f -> ${dest}"
  else
    log "$(the_time) : failed converting $f -> ${dest} - [${message}]"
  fi
}

log_already_exists() {
  local f=$1
  local dest=$2

  echo "${dest} already exists"
  log "$(the_time) : did not convert $f -> ${dest} (already exists)"
}

dest_file() {
  local source_dir=$1
  local f=$2
  local source_type=$3
  local dest_type=$4

  local source_dir_size=${#source_dir}
  local dir=$(dirname $f | cut -c $((source_dir_size + 1))-)
  local file=$(basename $f)
  local file_no_ext=$(basename $f ".${source_type}")
  echo "${dest_dir}${dir}/${file_no_ext}.${dest_type}"
}

convert_images() {
  local source_dir=$1
  local dest_dir=$2
  local source_type=$3
  local dest_type=$4
  local opts=$5
  local message

  delete_log
  echo "Running convert on all '.${source_type}' files under '${source_dir}'"
  echo "with destination type: '${dest_type}'"
  if [[ -n ${opts} ]] ; then echo "and options: ${opts}" ; fi
  mkdir -p ${dest_dir}

  if [[ $? > 0 ]]; then
    echo "failed to create output dir"
  fi

  for f in $(find "${source_dir}" -iname "*${source_type}") ; do
    local dest=$(dest_file "${source_dir}" "$f" "${source_type}" "${dest_type}")

    if [[ -f "${dest}" ]] ; then
      log_already_exists "$f" "${dest}"
    else 
      local output=$(convert_image $f ${dest} "${opts}")

      if [[ "${output}" = "" ]] ; then
        message="success"
      else
        message="${output}"
      fi

      log_result "${message}" "$f" "${dest}"
    fi
  done;
}

source_dir=$1
dest_dir=$2
source_type=$3
dest_type=$4
o1=$5
o2=$6
o3=$7
o4=$8
o5=$9
o6=${10}
o7=${11}
o8=${12}
o9=${13}

opts=$(echo "${o1} ${o2} ${o3} ${o4} ${o5} ${o6} ${o7} ${o8} ${o9}" | xargs)

convert_images "${source_dir}" "${dest_dir}" "${source_type}" "${dest_type}" "${opts}"

