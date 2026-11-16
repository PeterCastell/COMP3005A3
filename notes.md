## memory

..-32+: function ptr storage, 8 cells each (index n is at -32 - 8n)

-24: socket storage

-16..-1: free

0 - 255: universal function caller

256..511: string space for calls (formats, names, sockaddr)

512..1023: working space

1024+: database client

## universal function caller

0: caller id
1-8: function address
9-16: return address (points at 200)
17-88: argument addresses 0-8 (point at 128, 136, ... 192)

104-111: cells set aside by arg_ptr
128-199: arguments 0-8, 8 cells each
200-207: return value
208+: message space for fail

Cells 0-88 are also used as string space by setup_functions,
which is why it has to run before create_func_caller.

## database client

Wiped after authentication:

1024: user
1280: database
1536: password

2048: client-first-message-bare ("n=,r=" then the nonce at 2053)
2112: nonce bytes (18)
2176: nonce from the server (client nonce + server nonce)
2304: salt, base64
2432: salt bytes
2496: salt byte count (u32)
2504: iteration count (u32, passed as a u64)
2520: HMAC-SHA-256 algorithm handle
2528: SHA-256 algorithm handle
2536: base64 length in and out (u32)
2560: salted password (32)
2592: client key (32)
2624: client signature (32)
2656: client proof (32)
2688-2727: xor working cells (8 cells, moving along 32 times)
2752: stored key (32)
2784: server key (32)
2816: server signature (32)
2848: client proof, base64
2912: server signature, base64
3072-4063: auth message

Messages:

4064-4067: payload length for sending (u32)
4068-4072: working cells for adding to it
4080-4084: received header (type, Int32 length)
4086: db_wait_ready loop flag
4088: type of the received message
4089-4090: working cells for testing it
4091: type of the message being sent
4092-4095: Int32 length of the message being sent
4096+: payload (65536 cells are cleared before every message)

Working space:

512-524: db_recv, payload length arithmetic
768-775: pointer into the payload, for printing results
776-780: byte read through the pointer, and cells for adding to it
784-786: columns left to print, separator, temporary
788-791: Int32 length of the value being printed

After authentication:

1024, 1280, 1536, 1792: the values that go into a query template
