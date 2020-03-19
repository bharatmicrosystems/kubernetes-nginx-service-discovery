#!/bin/sh
config_dir=config_dir_ph
domain=domain_ph
while inotifywait --exclude '/\.' -qqre close_write "$config_dir"; do
    for file in ${config_dir}*
    do
      if [ ${file: -5} == ".json" ]; then
        curl -X POST -H "Content-Type: application/json" -d @${file} http://discovery.${domain} 
      fi
    done
done
