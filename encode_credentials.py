import sys
import base64
import os
from dotenv import load_dotenv, set_key

def encode_credentials(username, password):
    credentials = f"{username}:{password}"
    encoded_credentials = base64.b64encode(credentials.encode()).decode()
    return encoded_credentials

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python encode_credentials.py <username> <password>")
        sys.exit(1)

    username = sys.argv[1]
    password = sys.argv[2]
    encoded_credentials = encode_credentials(username, password)
    
    # Загрузка текущего файла .env
    load_dotenv()
    
    # Добавление закодированных учетных данных в .env
    set_key(".env", "CREDS", encoded_credentials)
    
    print(f"Encoded credentials added to .env: {encoded_credentials}")
