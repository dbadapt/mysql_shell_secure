#!/bin/sh

# call mysql client from shell script without 
# passing credentials on command line
#
# this version demonstrates queries read from
# standard input such as mysqldump output.
# It uses a temporary file with restrictive
# permissions to read config information.

# david . bennett @ percona . com - 9/24/2016

mysql_user=root
mysql_password=password
mysql_host=127.0.0.1
mysql_port=3306
mysql_database=test

mysql_exec_from_file() {
  local query_file="$1"
  local opts="$2"
  local tmpcnf="$(mktemp)"
  trap "EC=\$?; rm -f ${tmpcnf}; exit \$EC" EXIT INT TERM
  chmod 600 "${tmpcnf}"
  printf "%s\n" \
    "[client]" \
    "user=${mysql_user}" \
    "password=${mysql_password}" \
    "host=${mysql_host}" \
    "port=${mysql_port}" \
    "database=${mysql_database}" \
    > "${tmpcnf}" 
  mysql_exec_from_file_result=$(
      mysql --defaults-file="${tmpcnf}" "$opts" < "${query_file}"
  )
}

query_file="$(mktemp)"
echo "select 'Hello World' as Message;" > "${query_file}"
mysql_exec_from_file "${query_file}"
echo "${mysql_exec_from_file_result}"
rm "${query_file}"

