import magic

blob = open('index.pck', 'rb').read()
m = magic.Magic(mime_encoding=True)
encoding = m.from_buffer(blob)
print(encoding)