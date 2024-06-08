#!/bin/bash

for script in *.sh; do
    echo "RUN $script..."
    chmod +x "$script"
   ./"$script"
done