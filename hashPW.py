import hashlib
import base64

username = 'pamellaaa.iracing@gmail.com'
password = 'k_pB-Hx+f2q5aF3'

def encode_pw(username, password):
    initialHash = hashlib.sha256((password + username.lower()).encode('utf-8')).digest()

    hashInBase64 = base64.b64encode(initialHash).decode('utf-8')

    return hashInBase64


pwValueToSubmit = encode_pw(username, password)

print(f'{username}\n{pwValueToSubmit}')