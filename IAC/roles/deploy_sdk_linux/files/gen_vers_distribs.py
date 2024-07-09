import pwd
import os
import requests
from requests.exceptions import HTTPError
from bs4 import BeautifulSoup

# Where the data file with the list will be imported from
dest_path = '/home/ansible/ansible/projects/IAC/roles/deploy_sdk_linux/vars/vers_distribs.yml'

# Ranking lists in variables
centos = list(range(7, 10))
rhel = list(range(7, 10))
fedora = list(range(24, 41))

# Creating an empty dictionary for storing values
versions = {
    "centos_vers": centos,
    "rhel_vers": rhel,
    "fedora_vers": fedora
}

debian = 'https://download.docker.com/linux/debian/dists/'
ubuntu = 'https://download.docker.com/linux/ubuntu/dists/'

for url, key in [(debian, 'debian_vers'), (ubuntu, 'ubuntu_vers')]:
    try:
        response = requests.get(url)
        response.raise_for_status()
    except HTTPError as http_err:
        print(f'HTTP error occurred: {http_err}') # Python 3.6
    except Exception as err:
        print(f'Other error occurred: {err}') # Python 3.6
    else:
        # Create a BeautifulSoup object for parsing HTML
        soup = BeautifulSoup(response.text, 'html.parser')
        # Find all <a> tags inside the <body> tag
        a_tags = soup.find_all('a')
        # Create an empty list for storing values for the current URL
        values = []
        # Extract the text of each <a> tag and add it to the list if it does not contain characters '/', single quotes, and does not lead to the parent directory
        for a in a_tags:
            href = a.get('href')
            if href and not href.startswith('../'):
                # Remove unnecessary '/' characters and single quotes
                cleaned_href = href.replace('/', '').replace("'", "")
                values.append(cleaned_href)
        # Add the list of values to the dictionary with the key corresponding to the current URL
        versions[key] = values

# Manually format data for saving in a .yml file
formatted_data = ""
for key, values in versions.items():
    formatted_data += f"{key}: {values}\n"

# Save the formatted data in a .yml file
with open(dest_path, 'w') as file:
    file.write(formatted_data)

# Set permissions and owner of the data file
uid = pwd.getpwnam('ansible').pw_uid
gid = pwd.getpwnam('ansible').pw_gid

os.chown(dest_path, uid, gid)
os.chmod(dest_path, 0o755)
