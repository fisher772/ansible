# This code sample uses the 'requests' library:
# http://docs.python-requests.org
import requests
import json
from dotenv import load_dotenv
import os


load_dotenv()

base_url = os.getenv('URL')
url = f"{base_url}/admin/groups/add-users"
access_data = os.getenv('CREDS')
group_name = os.getenv('GROUP')
add_users=os.getenv('USERS').split(',') 


headers = {
  "Authorization": f"Basic {access_data}",
  "Accept": "application/json",
  "Content-Type": "application/json"
}

payload = json.dumps( {
  "group": group_name,
  "users": add_users
} )

response = requests.request(
   "POST",
   url,
   data=payload,
   headers=headers
)

# Проверка статуса ответа

#print(json.dumps(json.loads(response.text), sort_keys=True, indent=4, separators=(",", ": ")))

''' if response.status_code == 200:
    try:
        # Попытка декодировать JSON
        data = json.loads(response.text)
        print(json.dumps(data, sort_keys=True, indent=4, separators=(",", ": ")))
    except json.JSONDecodeError:
        print(f"Ошибка декодирования JSON: {response.text}")
else:
    print(f"Ошибка запроса: {response.status_code} {response.text}")
'''

if response.status_code == 200:
    print("Запрос успешно обработан.")
else:
    print(f"Ошибка запроса: {response.status_code} {response.text}")

